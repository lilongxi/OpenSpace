// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import { TokenBankPermit2 } from "../src/chapter-012-permit2/TokenBankPermit2.sol";

contract TokenBankPermit2Script is Script {
    TokenBankPermit2 public tokenBankPermit2;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        tokenBankPermit2 = new TokenBankPermit2();

        vm.stopBroadcast();
    }
}
