// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import { HHMyToken } from "../src/MyToken.sol";

contract MyTokenScript is Script {
    HHMyToken public hhMyToken;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        hhMyToken = new HHMyToken(100_000_000);

        vm.stopBroadcast();
    }
}
