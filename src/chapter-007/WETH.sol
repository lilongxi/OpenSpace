// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import "../BaseERC20.sol";

/**
 * @title 
 * @author 
 * @notice
 * 
 * Wrapped Ether（WETH）是一种将原生的以太币（ETH）包装成符合 ERC20 标准的代币。
 * 由于原生的 ETH 并不完全遵循 ERC20 标准 
 */
contract WETH is BaseERC20 {
    
    constructor() BaseERC20("Wrapped Ether", "WETH") {}

    function deposit() external payable {
        _mint(msg.sender, msg.value);
    }

    function withdraw(uint amount) external {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        _burn(_msgSender(), amount);
        payable(_msgSender()).transfer(amount);
    }

}