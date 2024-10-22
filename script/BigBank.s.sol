// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import { BigBank } from "../src/BigBank.sol";

contract BigBankScript is Script {
    BigBank public bigBank;

    function setUp() public {}

    function run() public {
        // vm.createSelectFork("sepolia");
        vm.startBroadcast();

        bigBank = new BigBank();
        vm.stopBroadcast();
    }
}
