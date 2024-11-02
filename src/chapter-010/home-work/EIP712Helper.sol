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

    function parseSignature(bytes memory signature) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(signature.length == 65, "Invalid signature length");

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF, "Invalid 's' value");
        require(v == 27 || v == 28, "Invalid 'v' value");
    }
}