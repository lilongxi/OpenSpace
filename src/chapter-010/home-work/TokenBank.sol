// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import "oz_v5/contracts/token/ERC20/extensions/ERC20Permit.sol";

// 0x052EFc2E00cc5968906B3767cC77b5C82018ED5F
contract TokenBank {
    // 使用 ERC20Permit 代币合约
    ERC20Permit public token;

    // 存款记录
    mapping(address => uint256) public deposits;

    constructor(address _token) {
        token = ERC20Permit(_token);
    }

    // 使用 permit 方法进行授权存款
    function permitDeposit(
        address owner,
        address spender,
        uint amount,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
         // 调用 permit 方法
        token.permit(owner, spender, amount, deadline, v, r, s);
        // 执行存款
        deposit(owner, amount);
    }

    function deposit(address from, uint amount) internal {
        token.transferFrom(from, address(this), amount);
        deposits[from] += amount;
    }

    // 查看存款余额
    function balanceOf(address account) external view returns (uint256) {
        return deposits[account];
    }

}