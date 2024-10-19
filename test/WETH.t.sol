
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import { WETH } from "src/chapter-007/WETH.sol";

contract WETH_Invariant_Test is Test {

    WETH public weth;

    function setUp() public {
        weth = new WETH();
    }

    // forge-config: default.invariant.fail-on-revert = true
    function invariant_eth_balance_equal_weth_supply() public view {
        assertEq(address(weth).balance, weth.totalSupply());
    }

}

contract WETHHandler is Test {
    WETH public weth;

    constructor(WETH weth_) {
        weth = weth_;
        deal(address(this), 100000 ether);
    }

    function desposit(uint amount) public {
        vm.assume(amount > 0 && amount < 100000 ether);
        weth.deposit{value: amount}();
    }

    function withdraw(uint amount) public {
        vm.assume(amount > 0 && amount < 100000 ether);
        weth.withdraw(amount);
    }

}

contract WETH_Invariant_Test02 is Test {
    WETH public weth;
    WETHHandler public handler;

    function setUp() public {
        weth = new WETH();
        handler = new WETHHandler(weth);
        targetContract(address(handler));
    }

    // forge-config: default.invariant.fail-on-revert = true
    function invariant_eth_balance_equal_weth_supply() public view {
        assertEq(address(weth).balance, weth.totalSupply());
    }

}