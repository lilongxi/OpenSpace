// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import { Test, console } from "forge-std/Test.sol";
import { Counter } from "src/chapter-007/Counter/index.sol";

contract CounterTest is Test {
    Counter public counter;

    function setUp() public {
        counter = new Counter();
        counter.setNumber(0);
    }

    function test_Increment() public {
        counter.increment();
        assertEq(counter.number(), 1);
    }

    function testFuzz_SetNumber(uint x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }

}