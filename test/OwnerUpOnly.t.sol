// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import { Test, console } from "forge-std/Test.sol";
import { OwnerUpOnly } from "src/chapter-007/OwnerUpOnly/index.sol";

contract OwnerUpOnlyTest is Test {
    OwnerUpOnly upOnly;

    function setUp() public {
        upOnly = new OwnerUpOnly();
    }

    function test_1() public {
        assertEq(upOnly.counter(), 0);
        upOnly.increment();
        assertEq(upOnly.counter(), 1);
    }

    function test_2() public {
        address hacker = makeAddr('hacker');
        vm.expectRevert();
        vm.prank(hacker);
        upOnly.increment();
    }

}