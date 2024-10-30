// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import "oz_v5/contracts/token/ERC20/extensions/ERC20Permit.sol";

// 0xe170C93a66d497802195575dd0ef3207aE73E076
// https://sepolia.etherscan.io/tx/0xc91d4ff2821d1a10784ee6fe9b837b3c5b712c2c986ded2d46f21126b5fabffe
contract MyERC20Permit is ERC20Permit {
   constructor() ERC20Permit("MyERC20PermitToken") ERC20("MyERC20PermitToken", "MEPT") {
        _mint(msg.sender, 1000000 * 10 ** decimals()); // 初始化 1000000 代币
    }
}
