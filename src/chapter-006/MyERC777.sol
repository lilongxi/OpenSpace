// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "oz_v4_9/contracts/token/ERC777/ERC777.sol";

contract MyERC777 is ERC777 {
    constructor(uint initialSupply, address[] memory defaultOperators_) ERC777('MY777', "M777", defaultOperators_) {
        address owner = _msgSender();
        _mint(owner, initialSupply * 10 ** decimals(), "", "");
    }
}