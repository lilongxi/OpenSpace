// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "forge-std/console.sol";
// import { MyWalletV1 } from "src/chapter-016-slot/MyWalletV1.sol";
import { MyWallet } from "src/chapter-016-slot/MyWallet.sol";

contract MyWalletOwnerTest is Test {

    MyWallet myWallet;

    address owner = address(0x123);
    address newOwner = address(0x456);
    address nonOwner = address(0x789);
    string walletName = "My Wallet";

    function setUp() public {
        myWallet = new MyWallet(walletName);
         // 验证部署时的初始 owner 是否为 address(0x123)
        assertEq(myWallet.owner(), owner);
    }

    function testTransferOwnership() public {
         vm.startPrank(owner);  // 模拟为 owner 地址进行操作
         myWallet.transferOwnership(newOwner);
         assertEq(myWallet.owner(), newOwner);
         vm.stopPrank();
    }

    // function testTransferOwnershipNonOwner() public {
    //     // 测试非 owner 调用 transferOwnership 的情况
    //     vm.startPrank(nonOwner);  // 模拟为非 owner 地址进行操作
    //     vm.expectRevert("Not authorized");  // 期望 revert
    //     myWallet.transferOwnership(newOwner);
    //     vm.stopPrank();
    // }

    // function testTransferOwnershipToZeroAddress() public {
    //     // 测试转移所有权到零地址
    //     vm.startPrank(owner);
    //     vm.expectRevert("New owner is the 0 address");  // 期望 revert
    //     myWallet.transferOwnership(address(0));
    //     vm.stopPrank();
    // }
}   