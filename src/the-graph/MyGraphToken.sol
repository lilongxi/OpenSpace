// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC20} from "oz_v5/contracts/token/ERC20/ERC20.sol";

// 0xBFa9BD1D21709F215664a4959fCdFB9fA0387425
contract MyGraphToken is ERC20 {
    constructor() ERC20('MyGraphToken', "MGT") {
        _mint(msg.sender, 1e9 * 1e18); // 1 billion
    }
}