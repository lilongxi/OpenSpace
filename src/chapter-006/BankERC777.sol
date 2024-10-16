// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "oz_v4_9/contracts/access/Ownable.sol";
import "oz_v4_9/contracts/token/ERC777/ERC777.sol";
import "oz_v4_9/contracts/utils/introspection/IERC1820Registry.sol";

// IERC777Recipient 实现 tokensReceived 
contract BankERC777 is Ownable, IERC777Recipient {
    
    IERC1820Registry private _erc1820 = IERC1820Registry(
         0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24
    );

    mapping(address => uint256) private balances;
    IERC777 private _token; 

    error NoEnoughBalance(address _owner, address _spender, uint amount);

    event Deposit(address indexed user, uint256 amount);  
    event Withdrawal(address indexed user, uint256 amount);

    modifier DespositInvalid(uint amount) {
        if (amount <= 0) revert NoEnoughBalance(_msgSender(), address(this), amount);
        _;
    }

    constructor(IERC777 tokenAddress) {
       _token = tokenAddress;
        //  通过一个 哈希表将当前合约的地址关联
       _erc1820.setInterfaceImplementer(
        address(this), // 为当前哪个合约注册
        keccak256("ERC777TokensRecipient"),
        address(this) // 具体实现方法的合约地址
       );
    }

    // 通过 send 执行此回调
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external override {
        require(msg.sender == address(_token), "Invalid token");
        balances[from] += amount;
        emit Deposit(from, amount);
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        _token.send(msg.sender, amount, "");
        emit Withdrawal(msg.sender, amount);
    }

    function balanceOf(address user) external view returns (uint256) {
        return balances[user];
    }


}