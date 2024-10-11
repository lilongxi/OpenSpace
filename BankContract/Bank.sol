// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

contract Bank {

    uint private constant TOP_NUMBERS = 3;
    
    address public owner;
    mapping (address => uint256) public deposits;
    address[3] public topUsers;
    uint256[3] public topDeposits;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(uint256 amount);

    constructor () {
        owner = msg.sender;
    }

    receive() external payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        deposits[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
        updateTopUsers(msg.sender, deposits[msg.sender]);
    }

    function updateTopUsers(address user, uint256 depositAmount) internal {
        for (uint i = 0; i < TOP_NUMBERS; i++) {
            if (depositAmount > topDeposits[i]) {
                for(uint k = TOP_NUMBERS - 1; k > i; k--) {
                    topDeposits[k] = topDeposits[k - 1];
                    topUsers[k] = topUsers[k - 1];
                }
                topDeposits[i] = depositAmount;
                topUsers[i] = user;
                break;
            }
        }
    }

    function withdraw(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Insufficient contract balance");
        payable(owner).transfer(amount);
        emit Withdraw(amount);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only administrators can call");
        _;
    }


}