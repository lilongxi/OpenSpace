// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "../TokenBank.sol";
import "./ERC20WithCallback.sol";

contract TokenBankV2 is TokenBank, IERC20WithCallback {
    constructor(address _addr) TokenBank(_addr) {}
    
    function tokensReceived(address account, uint amount) external DespositInvalid(amount) returns (bool) {
        require(msg.sender == address(token), "Invalid sender");
        balances[account] += amount;
        return true;
    }
}



