// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import "oz_v5/contracts/token/ERC20/ERC20.sol";
import "oz_v5/contracts/utils/Context.sol";

// 直接转账
contract MyTokenSignEIP712 is ERC20("MyTokenSign", "MTYS") {

    mapping (address => uint) public nonces;
    bytes32 public constant TRANSFER_TYPEHASH = keccak256("Transfer(address from,address to,uint256 amount,uint256 nonce,uint256 deadline)");
    bytes32 public DOMAIN_SEPARATOR;

    constructor() {
        _mint(msg.sender, 1000000 * 1e18);
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes("MyTokenSign")),
                keccak256(bytes("1")),
                block.chainid,
                 address(this)
            )
        );
    }

    // 签名验证实现授权
    function transferWithSignature(
        address from,
        address to,
        uint amount,
        uint nonce,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        require(block.timestamp <= deadline, "expired");
        require(nonces[from] == nonce, "invalid nonce");

        bytes32 hashStruct = keccak256(
             abi.encode(
                TRANSFER_TYPEHASH,
                from,
                to,
                amount,
                nonce,
                deadline
            )
        );

         bytes32 hash = keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, hashStruct)
        );

        // ecrecover 的作用是从签名中恢复出签名者的地址
        address signer = ecrecover(hash, v, r, s);
        require(signer == from, "Invalid signature");

        nonces[from]++;
        _transfer(from, to, amount);

    }

}