// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import "oz_v5/contracts/token/ERC20/extensions/ERC20Permit.sol";

// 0xe7C288Bb298277543481085193B495945BbE1661
contract MyCustomToken is ERC20Permit {
    constructor() ERC20("MyCustomToken", "MCT") ERC20Permit("MyCustomToken") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}