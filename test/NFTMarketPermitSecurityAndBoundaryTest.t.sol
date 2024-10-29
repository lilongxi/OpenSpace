// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "oz_v5/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "oz_v5/contracts/utils/Nonces.sol";
import { BaseERC20 } from "src/BaseERC20.sol";
import { BaseERC721 } from "src/chapter-006/MyERC721.sol";
import { NFTMarketPermit } from "src/chapter-010/home-work/NFTMarketPermit.sol";

contract NFTMarketPermitSecurityAndBoundaryTest is Test {
    NFTMarketPermit nftMarketPermit;
    BaseERC721 public erc721;
    address owner;
    address user;
    uint256 userPrivateKey;
    uint256 attackerPrivateKey;
    address attacker;

    function setUp() public {
        // 部署模拟的 NFT 和市场合约
        erc721 = new BaseERC721("MyNameNFT", "MyNameNFT", "ipfs://QmV9uPCxLngdDABdwYG8TNoXff3MPoTjvXyACDJ2wU2RqJ");
        nftMarketPermit = new NFTMarketPermit(address(erc721), address(0));

        owner = address(this);
        userPrivateKey = 0xBEEF; // 设置用户私钥
        user = vm.addr(userPrivateKey);

        attackerPrivateKey = 0xBADBAD; // 设置攻击者私钥
        attacker = vm.addr(attackerPrivateKey);

        // 铸造 NFT 并将用户添加到白名单
        erc721.mint(owner, 1); // 铸造 tokenId 为 1 的 NFT
        nftMarketPermit.setWhiteisted(user);
        nftMarketPermit.list(1, 1 ether);
    }

    // 安全性测试用例

    function testReentrancyAttack() public {
        // 尝试攻击者利用重入漏洞调用 `permitBuyEip191`
        vm.prank(attacker);
        vm.expectRevert("ReentrancyGuard: reentrant call");
        
        nftMarketPermit.permitBuyEip191(
            1,
            0,
            block.timestamp + 1 hours,
            0,
            bytes32(0),
            bytes32(0)
        );
    }

    function testInvalidSignatureReplayAttack() public {
        uint256 nonce = 0;
        uint256 deadline = block.timestamp + 1 hours;

        // 创建有效签名
        bytes32 hash = keccak256(abi.encodePacked(user, nonce, deadline));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, hash);

        // 用户购买 NFT 成功
        vm.prank(user);
        nftMarketPermit.permitBuyEip191(1, nonce, deadline, v, r, s);

        // 重放攻击：使用相同的签名再次尝试购买
        vm.prank(user);
        vm.expectRevert("Invalid nonce");
        nftMarketPermit.permitBuyEip191(1, nonce, deadline, v, r, s);
    }

    function testInvalidNonceForReplayAttack() public {
        uint256 deadline = block.timestamp + 1 hours;

        // 使用无效的 nonce 创建签名（例如 nonce 1 而非当前的 0）
        bytes32 hash = keccak256(abi.encodePacked(user, uint(1), deadline));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, hash);

        // 尝试使用无效 nonce 的签名购买 NFT
        vm.prank(user);
        vm.expectRevert("Invalid nonce");
        nftMarketPermit.permitBuyEip191(1, 1, deadline, v, r, s);
    }

    function testDeadlineExceeded() public {
        uint256 nonce = 0;
        uint256 deadline = block.timestamp - 1 hours; // 设置为过去的时间

        // 使用过期时间创建签名
        bytes32 hash = keccak256(abi.encodePacked(user, nonce, deadline));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, hash);

        // 由于签名过期，购买应失败
        vm.prank(user);
        vm.expectRevert("Signature expired");
        nftMarketPermit.permitBuyEip191(1, nonce, deadline, v, r, s);
    }

    function testAttackerWithValidSignatureButNotWhitelisted() public {
        // 攻击者签名并尝试购买，但未在白名单中
        uint256 nonce = 0;
        uint256 deadline = block.timestamp + 1 hours;

        bytes32 hash = keccak256(abi.encodePacked(attacker, nonce, deadline));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(attackerPrivateKey, hash);

        // 攻击者尝试购买 NFT，应该失败
        vm.prank(attacker);
        vm.expectRevert("You are not whitelisted for this purchase.");
        nftMarketPermit.permitBuyEip191(1, nonce, deadline, v, r, s);
    }

    // 边界条件测试用例

    function testBoundaryConditionForNonce() public {
        uint256 maxNonce = type(uint256).max; // 最大 uint256 值的 nonce
        uint256 deadline = block.timestamp + 1 hours;

        // 使用最大 nonce 创建签名
        bytes32 hash = keccak256(abi.encodePacked(user, maxNonce, deadline));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, hash);

        // 使用最大 nonce 进行调用，验证能否通过
        vm.prank(user);
        nftMarketPermit.permitBuyEip191(1, maxNonce, deadline, v, r, s);
        
        // 再次调用应失败，因为 nonce 已使用
        vm.prank(user);
        vm.expectRevert("Invalid nonce");
        nftMarketPermit.permitBuyEip191(1, maxNonce, deadline, v, r, s);
    }

    function testBoundaryConditionForZeroNonce() public {
        uint256 zeroNonce = 0; // 最小 nonce 值
        uint256 deadline = block.timestamp + 1 hours;

        // 使用零 nonce 创建签名
        bytes32 hash = keccak256(abi.encodePacked(user, zeroNonce, deadline));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, hash);

        // 使用零 nonce 进行调用，验证能否通过
        vm.prank(user);
        nftMarketPermit.permitBuyEip191(1, zeroNonce, deadline, v, r, s);

        // 再次使用零 nonce 应失败
        vm.prank(user);
        vm.expectRevert("Invalid nonce");
        nftMarketPermit.permitBuyEip191(1, zeroNonce, deadline, v, r, s);
    }

    function testBoundaryConditionForMaximumDeadline() public {
        uint256 nonce = 0;
        uint256 maxDeadline = type(uint256).max; // 最大时间戳

        // 使用最大时间戳创建签名
        bytes32 hash = keccak256(abi.encodePacked(user, nonce, maxDeadline));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, hash);

        // 使用最大 deadline 进行调用，验证能否通过
        vm.prank(user);
        nftMarketPermit.permitBuyEip191(1, nonce, maxDeadline, v, r, s);
    }
}
