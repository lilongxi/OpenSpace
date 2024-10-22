// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/***
 * 成员变量可见性
 * 1. 合约外部(链上 + 其他合约)
 * 2. 本合约
 * 3. 子合约
 * 
 * public：完全可见
 * private： 对本合约可见 其他合约不可见
 * internal：对继承子合约可见 类似 protected 不做任何修饰是 internal
 * extrenal：只可以修饰函数的可见性
 * 
 * 可见性 + 交易相关
 * 
 * 合约函数的交易属性
 * view：合约状态读操作
 * pure：与合约状态无关的函数
 * 默认写操作：全网广播 共识确认
 * 
 *  涉及到 transcation 逻辑
 */

contract IndexContract {

    function named() internal pure returns (bool) {
        return true;
    }

    function extrenalNamed() external pure returns (bool) {
        return false;
    }

    function readContractVar() external view {

    }


}