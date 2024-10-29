// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "oz_v5/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "oz_v5/contracts/utils/Nonces.sol";
import { BaseERC20 } from "src/BaseERC20.sol";
import { BaseERC721 } from "src/chapter-006/MyERC721.sol";
import { NFTMarketPermit } from "src/chapter-010/home-work/NFTMarketPermit.sol";

contract NFTMarketPermitTestV2 is Test, Nonces {

    BaseERC20 public erc20;
    BaseERC721 public erc721;
    NFTMarketPermit public nftMarketPermit;

    address public seller = address(1);
    address public owner = address(this);

    // Define the private key for the whitelist signer
    uint privateBuyer191 = 0xBEEF;
    address buyer191 = vm.addr(privateBuyer191);

    uint256 public tokenId = 1;
    uint256 public price = 10000;
    uint256 public price_ = price * 2;

    // 设置攻击者
    uint public privateAttacker = 0xBADBAD;
    address attacker = vm.addr(privateAttacker);


    function setUp() public {
        erc20 = new BaseERC20("MyToken", "MTK");
        erc721 = new BaseERC721("MyNameNFT", "MyNameNFT", "ipfs://QmV9uPCxLngdDABdwYG8TNoXff3MPoTjvXyACDJ2wU2RqJ");
        nftMarketPermit = new NFTMarketPermit(address(erc721), address(erc20));
        _initNFT();
    }

    function _mintNFT(address user_, uint tokenId_) internal {
        erc721.mint(user_, tokenId_);
        assertEq(erc721.ownerOf(tokenId_), user_);
    }

    function _initNFT() internal {
         _mintNFT(seller, tokenId);

        vm.startPrank(seller);
        erc721.setApprovalForAll(address(nftMarketPermit), true);
        erc721.approve(address(nftMarketPermit), tokenId);
        assertEq(erc721.getApproved(tokenId), address(nftMarketPermit));
        nftMarketPermit.list(tokenId, price);
        (uint tokenId, address seller, uint price, bool isSold) = nftMarketPermit.listings(tokenId);
        vm.stopPrank();
    
        vm.prank(buyer191);
        erc20.approve(address(nftMarketPermit), price_);
        assertEq(erc20.allowance(buyer191, address(nftMarketPermit)), price_);
        deal(address(erc20), buyer191, price_);
        // 给 buyer 充值
        assertEq(erc20.balanceOf(buyer191), price_);

        nftMarketPermit.setWhiteisted(buyer191);
    }

    function testGetListingById() public view {
        NFTMarketPermit.Listing memory listing = nftMarketPermit.getListingById(tokenId);
        assertEq(listing.tokenId, tokenId);
        assertEq(listing.seller, seller);
        assertEq(listing.price, price);
        assertEq(listing.isSold, false);
    }

    function testWhiteListed() public {
      nftMarketPermit.setWhiteisted(seller);
      bool succeed = nftMarketPermit.getWhitelistedByAddr(seller);
      assertEq(succeed, true);
      nftMarketPermit.revokeWhitelisted(seller);
      bool revoke = nftMarketPermit.getWhitelistedByAddr(seller);
      assertEq(revoke, false);
    }

    function testPermitBuyEip191_ValidSignature() public {
        uint nonce = nonces(buyer191);
        uint256 deadline = block.timestamp + 1 hours;
        bytes32 hash = keccak256(abi.encodePacked(buyer191, nonce, deadline));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateBuyer191, hash);
      
        vm.startPrank(buyer191);
        // 授权
        // erc721.approve(address(nftMarketPermit), price_);
        // assertEq(erc20.allowance(buyer191, address(nftMarketPermit)), price_);
        // vm.expectRevert("You are not whitelisted for this purchase.");
        nftMarketPermit.permitBuyEip191(tokenId, nonce, deadline, v, r, s);
        // nftMarketPermit.permitBuyEip191(tokenId, nonce, deadline, v, r, s);

        assertEq(erc721.ownerOf(tokenId), buyer191);

        vm.stopPrank();

    }

    function testPermitBuyEip191_InvalidSignature() public {
        uint nonce = nonces(buyer191);
        uint256 deadline = block.timestamp + 1 hours;
        bytes32 hash = keccak256(abi.encodePacked(buyer191, nonce, deadline));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(0xBADBAD, hash);
        vm.startPrank(buyer191);
        vm.expectRevert("Invalid signature"); // 预期错误
        nftMarketPermit.permitBuyEip191(tokenId, nonce, deadline, v, r, s);
        vm.stopPrank();
    }

    function testPermitBuyEip191_NotWhitelistedUser() public {
        nftMarketPermit.revokeWhitelisted(buyer191);
         uint nonce = nonces(buyer191);
        uint256 deadline = block.timestamp + 1 hours;
        // 生成签名
        bytes32 hash = keccak256(abi.encodePacked(buyer191, nonce, deadline));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateBuyer191, hash);

        // 尝试调用 `permitBuyEip191`，应该失败
        vm.prank(buyer191);
        vm.expectRevert("You are not whitelisted for this purchase."); // 预期错误
        nftMarketPermit.permitBuyEip191(1, nonce, deadline, v, r, s);
    }

    // function testReentrancyAttack() public {
    //     nftMarketPermit.setWhiteisted(attacker);

    //     vm.prank(attacker);
    //     vm.expectRevert("ReentrancyGuard: reentrant call");
    //     nftMarketPermit.permitBuyEip191(
    //         1,
    //         0,
    //         block.timestamp + 1 hours,
    //         0,
    //         bytes32(0),
    //         bytes32(0)
    //     );
    // }

    function testInvalidSignatureReplayAttack() public {
        uint256 nonce = nonces(buyer191);
        uint256 deadline = block.timestamp + 1 hours;

        // 创建有效签名
        bytes32 hash = keccak256(abi.encodePacked(buyer191, nonce, deadline));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateBuyer191, hash);

        // 用户购买 NFT 成功
        vm.prank(buyer191);
        nftMarketPermit.permitBuyEip191(tokenId, nonce, deadline, v, r, s);

        // 重放攻击：使用相同的签名再次尝试购买
        vm.prank(buyer191);
        vm.expectRevert("This NFT is sold");
        nftMarketPermit.permitBuyEip191(tokenId, nonce, deadline, v, r, s);
    }

    function testInvalidNonceForReplayAttack() public {
        uint256 deadline = block.timestamp + 1 hours;
        // 使用无效的 nonce 创建签名（例如 nonce 1 而非当前的 0）
        bytes32 hash = keccak256(abi.encodePacked(buyer191, uint256(1), deadline));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateBuyer191, hash);

        // 尝试使用无效 nonce 的签名购买 NFT
        vm.prank(buyer191);
        vm.expectRevert("Invalid nonce");
        nftMarketPermit.permitBuyEip191(1, 1, deadline, v, r, s);
    }



}