// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import "oz_v5/contracts/utils/Strings.sol";

contract PersonSign {
    function hashPersonal(bytes memory message) public pure returns (bytes32) {
        return keccak256(bytes.concat("\x19Ethereum Signed Message:\n", bytes(Strings.toString(message.length)), message));
    }
}