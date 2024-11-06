// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.26;

contract MyWalletV1 {

    string public name; // slot 0
    address public owner; // slot 1
    mapping (address => bool) privateApproved; // slot 2

    modifier auth {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(string memory _name) {
        name = _name;
        address _owner = msg.sender;
        // assembly {
        //     sstore(1, caller())
        // }
        assembly {
            sstore(owner.slot, _owner)
        }
    }

    function transferOwnership(address _addr) public auth {
        require(_addr != address(0), "New owner is the 0 address");

        address _owner;
        assembly {
             _owner := sload(1)
        }
        require(_owner != _addr, "New owner is the same as the old owner");

        // owner = _addr;
        assembly {
            sstore(owner.slot, _addr)
        }
    }

}