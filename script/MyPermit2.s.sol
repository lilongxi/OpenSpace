// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Script, console} from "forge-std/Script.sol";
import { MyPermit2 } from "../src/chapter-012-permit2/MyPermit2.sol";

contract MyPermit2Script is Script {
    MyPermit2 public myPermit2;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        myPermit2 = new MyPermit2();

        vm.stopBroadcast();
    }
}
