// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

library  EIP712Helper {
    string private constant NAME = "NFTMarketPermit";
    string private constant VERSION = "1";

    function hashTypedDataV4(bytes32 structHash) internal view returns (bytes32) {
        return keccak256(abi.encodePacked(
            "\x19\x01",
            domainSeparatorV4(),
            structHash
        ));
    }

    function domainSeparatorV4() internal view returns (bytes32) {
        return keccak256(abi.encode(
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
            keccak256(bytes(NAME)),
            keccak256(bytes(VERSION)),
            block.chainid,
            address(this)
        ));
    }
}