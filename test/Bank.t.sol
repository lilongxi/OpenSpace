// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import { Bank } from "src/chapter-007/Bank.sol";

contract FristBankTest is Test {

    Bank bank;

    function setUp() public {
        bank = new Bank();
    }

    event Deposit(address indexed user, uint amount);

    function testDepositETH() public {

    address user = address(0x123);
    uint initialDeposit = 1 ether;

    // 模拟用户地址调用
    vm.prank(user);

    // 预期事件的输出：设置预期捕获的事件
    vm.expectEmit(true, true, false, true);
    emit Deposit(user, initialDeposit);

    // 检查存款前余额
    assertEq(bank.balanceOf(user), 0, "Initial balance should be zero");

    // 执行存款逻辑
    bank.depositETH{value: initialDeposit}();

    // 检查存款后的余额是否正确更新
    assertEq(bank.balanceOf(user), initialDeposit, "Balance should be updated after deposit");
        

    }

    function testDeposit0ETH() public {
        address user = address(0x123);

        vm.prank(user);

        vm.expectRevert("Deposit amount must be greater than 0");

        bank.depositETH{value: 0}();
    }
}
