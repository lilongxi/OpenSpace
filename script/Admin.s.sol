// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import { Admin } from "../src/Admin.sol";

contract CounterScript is Script {
    Admin public admin;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        admin = new Admin();

        vm.stopBroadcast();
    }
}
