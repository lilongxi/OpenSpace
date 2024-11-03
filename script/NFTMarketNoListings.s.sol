// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Script, console} from "forge-std/Script.sol";
import { NFTMarketNoListings } from "../src/chapter-014-nftrent/NFTMarketNoListings.sol";

contract NFTMarketNoListingsScript is Script {
    NFTMarketNoListings public market;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        market = new NFTMarketNoListings();

        vm.stopBroadcast();
    }
}
