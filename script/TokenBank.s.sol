// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import { TokenBank } from "../src/TokenBank.sol";

contract TokenBankScript is Script {
    TokenBank public tokenBank;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        tokenBank = new TokenBank(0xb93F55bc228E9ceB278B2018b650fe2732312476);

        vm.stopBroadcast();
    }
}
