// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import "forge-std/console.sol";
import "oz_v5/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "oz_v5/contracts/token/ERC20/IERC20.sol";

// 0x052EFc2E00cc5968906B3767cC77b5C82018ED5F
contract TokenBank {
    // 使用 ERC20Permit 代币合约
    ERC20Permit public permitToken;
    // IERC20 public token;

    // 存款记录
    mapping(address => uint256) public balances;

    // event Deposit(address indexed user, address indexed bank, uint amount);
    // event DepositV2(uint v2, uint amount);
    // event PermitDeposit( address owner,
    //     address spender,
    //     uint amount,
    //     uint deadline,
    //     uint8 v,
    //     bytes32 r,
    //     bytes32 s);

    constructor(address _token) {
        permitToken = ERC20Permit(_token);
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
        permitToken.permit(owner, spender, amount, deadline, v, r, s);
        // _approve();
        // 执行存款
        deposit(owner, amount);
    }

    function deposit(address owner, uint amount) internal {
        bool success = permitToken.transferFrom(owner, address(this), amount);
        require(success, "Transfer failed");
        console.log(amount, owner);
        balances[owner] += amount;
        console.log(balances[owner], owner);
    }

    // 查看存款余额
    function balanceOf(address account) external view returns (uint256) {
        console.log(account, balances[account]);
        return balances[account];
    }

}