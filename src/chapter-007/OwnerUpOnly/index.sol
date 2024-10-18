// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import "oz_v5/contracts/utils/Context.sol";
import "oz_v5/contracts/token/ERC20/ERC20.sol";
import "oz_v5/contracts/utils/Base64.sol";

contract OwnerUpOnly {
     address public immutable owner;
     uint public counter;

    constructor() {
        owner = msg.sender;
    }

    function increment() external {
        require(msg.sender == owner, 'fk');
        counter++;
    }

}