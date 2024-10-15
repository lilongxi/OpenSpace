// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import "./BaseERC20.sol";

interface ITokenBank {
    function deposit(uint256 amount) external;
    function withdraw(uint amount) external;
    function getBalance() external view returns (uint);
}

contract TokenBank is ITokenBank, Context, IERC20Errors {
    mapping (address => uint256) private balances;

    BaseERC20 private token;

    error NoEnoughBalance();

     modifier ERC20Invalid(address _address) {
        if (_address == address(0)) revert ERC20InvalidSender(address(0));
        _;
    }

    modifier DespositInvalid(uint amount) {
        if (amount <= 0) revert NoEnoughBalance();
        _;
    }

    constructor(address tokenAddr) ERC20Invalid(tokenAddr) {
        token = BaseERC20(tokenAddr);
    }

    function deposit (uint256 amount) public DespositInvalid(amount) {
        address owner = _msgSender();
        bool isValid = token.transferFrom(owner, address(this), amount);
        require(isValid, "TransferFrom Failed");
        unchecked {
            balances[owner] += amount;
        }
    }

    function withdraw(uint amount) public DespositInvalid(amount) {
        address owner = _msgSender();
        uint256 balance = balances[owner];
        if (balance < amount) revert ERC20InsufficientBalance(owner, balance, amount);
        unchecked {
            balances[owner] -= amount;
        }
    }

    function getBalance() public view returns (uint256) {
        address owner = _msgSender();
        return balances[owner];
    }

    function testRevert(uint amount) public pure {
        if(amount < 250)  revert ERC20InsufficientBalance(address(0), 250, 250);
    }

    function testRevertRequire(uint amount) public pure {
        // if(amount < 250)  revert ERC20InsufficientBalance(address(0), 250, 250);
        require(amount >= 250, "fuck ERC20InsufficientBalance");
    }

}

