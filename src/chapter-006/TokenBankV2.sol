// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "oz_v4_9/contracts/access/Ownable.sol";
import "./ERC20WithCallback.sol";


contract TokenBankV2 is Ownable, IERC20WithCallback {
    ERC20WithCallback public token;
    mapping(address => uint256) public balances;

    constructor(ERC20WithCallback token) {
        token = token;
    }

    event Deposit(address indexed from, uint256 amount);

    function tokensReceived(address from, uint amount, bytes calldata data) external override {
        require(msg.sender == address(token), "TokenBankV2: Invalid token sender");
        balances[from] += amount;
        emit Deposit(from, amount);
    }

    function getBalance(address user) public view returns (uint256) {
        return balances[user];
    }

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "TokenBankV2: Insufficient balance");
        balances[msg.sender] -= amount;
        token.transfer(msg.sender, amount);
    }

}


