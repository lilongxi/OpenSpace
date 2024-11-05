// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "oz_v5/contracts/access/Ownable.sol";
import "oz_v5/contracts/utils/cryptography/EIP712.sol";
import "oz_v5/contracts/utils/cryptography/ECDSA.sol";
import "oz_v5/contracts/utils/ReentrancyGuard.sol";

import { IDO } from "./IDO.sol";

contract IDO721 is IDO, EIP712 {

     using ECDSA for bytes32;
     mapping(bytes32 => bool) public usedSignatures;

      // 签名结构体的哈希，符合 EIP-712 标准
    bytes32 private constant PURCHASE_TYPEHASH = keccak256(
        "Purchase(address buyer,uint256 ethAmount,uint256 timestamp)"
    );

    string private constant NAME = "IDO721";
    string private constant VERSION = "1";

    constructor(
        address _token,
        uint256 _price,
        uint256 _goal,
        uint256 _cap,
        uint256 _duration
    ) IDO(_token, _price, _goal, _cap, _duration) EIP712(NAME, VERSION) {
    }

    function buyTokensWithSign(uint256 ethAmount, uint256 timestamp, uint8 v, bytes32 r, bytes32 s) public payable nonReentrant onlyWhileOpen {
        
        require(msg.value == ethAmount, "Incorrect ETH amount sent");

        // 确认签名合法性
        bytes32 structHash = keccak256(
            abi.encode(
                PURCHASE_TYPEHASH,
                msg.sender,
                ethAmount,
                timestamp
            )
        );

        bytes32 hash = _hashTypedDataV4(structHash);
        address signer = ecrecover(hash, v, r, s);

        require(signer == msg.sender, "Invalid signature");
        require(!usedSignatures[hash], "Signature already used");

        usedSignatures[hash] = true;
        
        buyTokens();

    }


}