// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import "OpenSpace/BankContract/Bank.sol";

contract BigBank is Bank {
    uint public constant MIN_DEPOSIT = 0.001 ether;

    error NotGreaterThanMinDeposit();
    error isZeroAddress();

    modifier minDeposit() {
        if (msg.value < MIN_DEPOSIT) revert NotGreaterThanMinDeposit();
        _;
    }

    // 重写存款方法
    function deposit() public payable override minDeposit {
        super.deposit();  // 调用父合约的存款方法
    }

    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert isZeroAddress();
        owner = newOwner;
    }
    

}