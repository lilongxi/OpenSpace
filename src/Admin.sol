// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import "OpenSpace/BankContract/Bank.sol";

contract Admin {
    address public owner;

    error NotOwner();
    error NoEnoughBalance();
    error isZeroAddress();

    constructor() {
        owner = msg.sender;
    }

    function adminWithdraw(IBank bank) external onlyOwner {
        uint balance = address(bank).balance;
        if (balance <= 0) revert NoEnoughBalance();
        bank.withdraw(balance);
    }

    function transferOwnership(address newOwner) external onlyOwner zeroAddress(newOwner) {
        owner = newOwner;
    }

     modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    modifier zeroAddress(address newOwner) {
        if (newOwner == address(0)) revert isZeroAddress();
        _;
    }

}