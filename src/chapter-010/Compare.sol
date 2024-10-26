// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

// 对比分析
// 特性	ERC20 approve 和 transferFrom	ERC20Permit permit
// 链上交易次数	2次交易：approve + transferFrom	1次交易：permit + transferFrom
// Gas 费用	需支付两次链上交易的 Gas 费用	仅需支付一次交易的 Gas 费用，节省用户成本
// 用户体验	用户需先调用 approve 再调用 transferFrom，操作繁琐	用户生成签名后直接调用 permit，简化了操作流程
// 授权风险	可能出现授权额度超支风险	通过 nonce 和 deadline 防止重放和超支，安全性更高
// 兼容性	与其他合约兼容性较差	遵循 EIP-712 标准，增强与 DeFi 协议和钱包的互操作性


import "oz_v5/contracts/token/ERC20/ERC20.sol";
import "oz_v5/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract CompareERC20 is ERC20 {
    constructor() ERC20("", "") {
        _mint(msg.sender, 1000000 * 10 ** 18);
    }
}

contract UseERC20 {
    CompareERC20 erc20;
    function approveAndTransfer (address spender, uint amount) public {
        //  _allowances[owner][spender] = value;
        erc20.approve(spender, 1000); //  第一次链上交易
        // 由 spender 转移 500 个代币
        erc20.transferFrom(msg.sender, address(this), amount);  // 第二次链上交易
    }
}


contract CompareERC20Premit is ERC20Permit {
    constructor() ERC20("", "") ERC20Permit("") {
        _mint(msg.sender, 1000000 * 10 ** 18);
    }
}

contract UseERC20Premit {
    CompareERC20Premit erc20Premit;

    function permitAndTransfer (
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
         // 通过 permit 方法授权，不需要链上 approve
        //   _allowances[owner][spender] = value;
        erc20Premit.permit(msg.sender, spender, amount, deadline, v, r, s); // 一次链上交易
        // 由 spender 转移 500 个代币
        erc20Premit.transferFrom(msg.sender, address(this), 500); // 另一笔链上交易
    }
}
