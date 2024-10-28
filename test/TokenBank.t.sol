// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "oz_v5/contracts/token/ERC20/extensions/ERC20Permit.sol";
import { TokenBank } from "src/chapter-010/home-work/TokenBank.sol";

contract MockToken is ERC20Permit {
    constructor() ERC20Permit("Test Token") ERC20("Test Token", "TTK") {
        _mint(msg.sender, 1000000 * 10 ** decimals()); // 初始化 1000000 代币
    }
}


contract TokenBankTest is Test {
    TokenBank public tokenBank;
    MockToken public mockToken;
    address public owner;
    uint256 public amount = 100 * 10 ** 18; // 设置存款数量
    uint256 private constant userPrivateKey = 0xA11CE; // 示例有效私钥

    function setUp() public {
        // 部署 Mock Token
        mockToken = new MockToken();
        // 部署 TokenBank
        tokenBank = new TokenBank(address(mockToken));

        owner = vm.addr(userPrivateKey);

        vm.startPrank(address(this));
        mockToken.transfer(owner, amount);
        vm.stopPrank();
    }

    function testPermitDeposit() public {
        // uint256 initialBalance = tokenBank.balanceOf(owner);
        uint256 deadline = type(uint256).max;
         // Retrieve the current nonce for the owner from the token contract
        uint256 nonce = mockToken.nonces(owner);

        // 使用有效的私钥生成签名
        (uint8 v, bytes32 r, bytes32 s) = getPermitSignature(
            owner,               // Owner's address
            address(tokenBank),  // Spender's address (TokenBank contract)
            amount,     // Amount to approve
            nonce,               // Current nonce
            deadline             // Deadline for the permit
        );

         // 执行 permit 授权并进行存款
        vm.startPrank(owner);
        tokenBank.permitDeposit(owner, address(tokenBank), amount, deadline, v, r, s);
        uint256 bankBalance = tokenBank.balanceOf(owner);
        assertEq(bankBalance, amount, "Deposit amount match");

        uint256 contractBalance = mockToken.balanceOf(address(tokenBank));

        assertEq(contractBalance, amount, "Deposit amount match");

        uint256 ownerBalance = mockToken.balanceOf(owner);
        assertEq(ownerBalance, 0, "Owner balance mismatch");

        uint256 ownerBalanceV2 = tokenBank.balanceOf(owner);
        console.log(ownerBalanceV2);

        uint256 remainingAllowance = mockToken.allowance(owner, address(tokenBank));

        console.log(remainingAllowance);

        vm.stopPrank();

    }

   function getPermitSignature(
        address owner_,
        address spender_,
        uint256 value_,
        uint256 nonce_,
        uint256 deadline_
    ) internal  view returns (uint8, bytes32, bytes32) {
        // Retrieve the EIP-712 domain separator from the token contract
        bytes32 DOMAIN_SEPARATOR = mockToken.DOMAIN_SEPARATOR();

        // Define the EIP-712 Permit typehash
        bytes32 PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

        // Compute the struct hash for the Permit struct
        bytes32 structHash = keccak256(
            abi.encode(
                PERMIT_TYPEHASH,
                owner_,
                spender_,
                value_,
                nonce_,
                deadline_
            )
        );

        // Compute the final EIP-712 digest by combining the domain separator and struct hash
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash)
        );

        // Sign the digest using the owner's private key to generate the signature components
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, digest);

        // Return the signature components
        return (v, r, s);
    }
}