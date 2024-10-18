// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "../TokenBank.sol";
import "./ERC20WithCallback.sol";

abstract contract TokenBankV2 is TokenBank, IERC20WithCallback {
    constructor(address _addr) TokenBank(_addr) {}
    
    /**
     * 当接收到代币时调用此函数。
     * 
     * @param account 接收代币的账户地址。
     * @param amount 接收的代币数量。
     * ERC20WithCallback 先调用 _transfer 成功后执行这个回调
     */
    function tokensReceived(address account, uint amount) external returns (bool) {
        require(msg.sender == address(token), "Invalid sender");
        balances[account] += amount;
        return true;
    }

}



