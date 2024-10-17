// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "./Bank.sol";

contract BankTest is Test {

    Bank bank;

    function setUp() public {
        bank = new Bank();
    }

    function testDepositETH() public payable {

        address user = address(1);
        uint depositAmount = 1 ether;

        // 发送 ETH 到 depositETH 方法
        vm.deal(user, depositAmount);
        vm.startPrank(user);

        vm.expectEmit(true, true, false, true);
        
         // 执行存款
        bank.depositETH{value: depositAmount}();

        // 断言存款额更新
        uint256 expectedBalance = depositAmount;
        uint256 actualBalance = bank.balanceOf(user);
        assertEq(actualBalance, expectedBalance, "User balance should be updated correctly");

        vm.stopPrank(); // 停止以用户的身份

    }

    // 额外的测试用例: 确保存款金额大于0的要求
    function testDepositZeroAmount() public {
        vm.expectRevert("Deposit amount must be greater than 0");
        bank.depositETH{value: 0}();
    }

}