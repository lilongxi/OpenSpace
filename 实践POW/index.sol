// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProofOfWork {
    constructor() {
    }

    function pow(string memory data, uint256 difficulty) public pure returns (uint256 nonce, bytes32 hash) {
        nonce = 0;
        hash = sha256(abi.encodePacked(data, nonce));
        while (uint256(hash) >> (256 - difficulty) != 0) {
            nonce++;
            hash = sha256(abi.encodePacked(data, nonce));
        }
        return (nonce, hash);
    }
    
}