// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.26;

contract MyWallet {

    string public name; // slot 0
    address public owner; // slot 1
    mapping (address => bool) privateApproved; // slot 2

    modifier auth {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(string memory _name) {
        name = _name;
        owner = msg.sender;
    }

    function transferOwnership(address _addr) public auth {
        require(_addr != address(0), "New owner is the 0 address");
        require(owner != _addr, "New owner is the same as the old owner");
        owner = _addr;
    }

}