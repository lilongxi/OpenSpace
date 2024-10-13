// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

interface IBank {
    function  desposit() external payable;
    function withdraw(uint amount) external;
    function getBalance() external view returns (uint);
}

