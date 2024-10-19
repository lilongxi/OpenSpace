// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "oz_v5/contracts/utils/Context.sol";
import "oz_v5/contracts/interfaces/draft-IERC6093.sol";

contract BaseERC20 is Context, IERC20Errors {

    string private name; 
    string private symbol; 
    uint256 public totalSupply;
    uint8 public decimals = 18; 

    mapping (address => uint256) balances; 

    mapping (address => mapping (address => uint256)) allowances; 

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    function _mint(address account, uint value) internal ERC20Invalid(account)  {
        // 提供初始化代币
        // totalSupply =  100_000_000 * 10 ** decimals;
        totalSupply = value;
        unchecked {
            balances[msg.sender] = totalSupply;
        }
    }

    modifier ERC20Invalid(address _address) {
        if (_address == address(0)) revert ERC20InvalidSender(address(0));
        _;
    }

    function _transfer(address from, address to, uint256 value) internal ERC20Invalid(from) ERC20Invalid(to) {
        uint256 fromBalance = balances[from];
        if (fromBalance < value) {
            revert ERC20InsufficientBalance(from, fromBalance, value);
        }
        // 不做溢出检查
        unchecked {
            balances[from] = fromBalance - value;
        }
        unchecked {
            balances[to] += value;
        }
    }

    function _approve(address owner, address spender, uint256 value) internal virtual ERC20Invalid(owner) ERC20Invalid(spender) {
        allowances[owner][spender] = value;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        address owner = _msgSender();
        _transfer(owner, _to, _value);
        emit Transfer(msg.sender, _to, _value);  
        return true;   
    }

    function _burn(address account, uint value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        unchecked {
            totalSupply -= value;
        }
    }

    // 代理转账：允许被授权的地址从一个账户向另一个账户转移代币
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        address spender = _msgSender();
        // 减掉被授权账户的可用额度
        // _from -> user msg.sender
        // spender -> bank address
        _spendAllowance(_from, spender, _value);
        // 从当前账户转出
        _transfer(_from, _to, _value);
        emit Transfer(_from, _to, _value);
        return true; 
    }

    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        // 不可以是无上限授权
        if (currentAllowance != type(uint256).max) {
            // 减掉可转移的额度
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value);
            }
        }
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        address owner = _msgSender();
        _approve(owner, _spender, _value);
        emit Approval(msg.sender, _spender, _value); 
        return true; 
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {   
        return allowances[_owner][_spender];
    }
}