// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "oz_v4_9/contracts/access/Ownable.sol";
import "oz_v4_9/contracts/token/ERC777/ERC777.sol";

contract BankERC777 is Ownable, IERC777Recipient {
    
    mapping(address => uint256) private balances;
    address public erc777TokenAddress;
    IERC777 public erc777Token;

    error NoEnoughBalance(address _owner, address _spender, uint amount);

    event Deposit(address indexed user, uint256 amount);  
    event Withdrawal(address indexed user, uint256 amount);

    modifier DespositInvalid(uint amount) {
        if (amount <= 0) revert NoEnoughBalance(_msgSender(), address(this), amount);
        _;
    }

    constructor(address _erc777TokenAddress) {
        erc777TokenAddress = _erc777TokenAddress;
        erc777Token = IERC777(_erc777TokenAddress);
    }

}