// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import "oz_v5/contracts/token/ERC20/ERC20.sol";
import "oz_v5/contracts/utils/Context.sol";

contract MyTokenSign is ERC20("MyTokenSign", "MTYS") {

    mapping (address => uint) public nonces;

    constructor() {
        _mint(_msgSender(), 1000000 * 1e18);
    }

    function transferWithSignature(
        address from,
        address to,
        uint amount,
        uint nonce,
        uint deadline,
        uint8 v,
        bytes32 r,  // deadline：签名有效的截止时间（以区块时间戳表示）。
        bytes32 s   // v、r、s：ECDSA签名的组成部分。
    ) public {
        
        require(block.timestamp <= deadline, "expired");

        // 确保和传入的 nonce 相同
        require(nonces[from] == nonce, "invalid nonce");
        // 完成后自增 确保不会再次被使用
        nonces[from]++;

        bytes32 hash = keccak256(abi.encodePacked(from, to, amount, nonce, deadline));
        address signer = ecrecover(hash, v, r, s);
        require(signer == from, "Invalid signature");
        _transfer(from, to, amount);


    }

}