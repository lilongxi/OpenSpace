// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import "oz_v4_9/contracts/token/ERC20/ERC20.sol";
import "oz_v4_9/contracts/utils/cryptography/ECDSA.sol";
import "oz_v4_9/contracts/utils/Counters.sol";

// 本质上是授权额度 授权 spender 可以消费 owner 多少代币
contract ERC20Permit is ERC20 {

    using Counters for Counters.Counter;
    using ECDSA for bytes32;
    
    mapping (address => Counters.Counter) private _nonces;
    bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public DOMAIN_SEPARATOR;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256(bytes("1")),
                block.chainid,
                address(this)
            )
        );
    }

    function nonces(address owner) public view returns(uint) {
        return _nonces[owner].current();
    }

    function permit(
        address owner,
        address spender,
        uint value,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
         require(block.timestamp <= deadline, "ERC20Permit: expired deadline");
         bytes32 hashStruct = keccak256(
            abi.encode(
                PERMIT_TYPEHASH,
                owner,
                spender,
                value,
                _nonces[owner].current(),
                deadline
            )
        );
        bytes32 hash = keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, hashStruct)
        );

        address signer = hash.recover(v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _nonces[owner].increment();
        _approve(owner, spender, value);
    }

}