// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import "oz_v5/contracts/token/ERC20/ERC20.sol";
import "oz_v5/contracts/utils/Base64.sol";

contract Counter {
    uint public number;

    function setNumber(uint newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }

}