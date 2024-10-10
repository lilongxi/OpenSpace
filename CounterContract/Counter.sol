// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

contract Counter {

    uint256 public counter;

    constructor() {
        counter = 0;
    }

    function get() public view returns (uint256) {
        return counter;
    }

    function add (uint256 x) public {
        require(x > 0, "x must be greater than 0");
        counter += x;
    }

}