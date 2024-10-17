// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./ERC20WithCallback.sol";

contract MyTokenCallback is ERC20WithCallback {
     constructor(uint initialSupply) ERC20WithCallback("MyTokenCallback", "MTCK") {
        address owner = _msgSender();
        _mint(owner, initialSupply * 10 ** decimals);
    }
}