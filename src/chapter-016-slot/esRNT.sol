// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.26;

contract esRNT {

    struct LockInfo {
        address user; // 20 bytes
        uint64 startTime; // 8 bytes
        uint256 amount;  // 32 bytes
    }

    LockInfo[] private _locks;

    constructor() {
        for (uint i = 0; i < 11; i++) {
            /**
             * uint160(i+1) 强转 20 bytes
             */
            _locks.push(LockInfo(address(uint160(i+1)), uint64(block.timestamp*2-i), 1e18*(i+1)));
        }
    }

}