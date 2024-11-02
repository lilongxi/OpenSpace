// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "../chapter-010/home-work/NFTMarketPermit.sol";
import "../chapter-010/home-work/EIP712Helper.sol";

contract NFTRentMarket is NFTMarketPermit {
    using EIP712Helper for bytes32;
    constructor(address _nftAddr, address _tokenAddr) NFTMarketPermit(_nftAddr, _tokenAddr) {}

    struct Sale {
        address seller;
        uint256 tokenId;
        uint256 price;
        uint256 nonce;
        uint256 deadline;
    }

    function buyWithPermit(Sale memory sale, uint8 v, bytes32 r, bytes32 s) public payable nonReentrant {
        // address buyer = _msgSender();
        require(nonces[sale.seller] == sale.nonce, "Invalid nonce"); // 验证nonce
        require(block.timestamp <= sale.deadline, "Sale expired");
        require(msg.value >= sale.price, "Insufficient funds");

        bytes32 structHash = keccak256(
            abi.encode(
                keccak256("Sale(address seller,uint256 tokenId,uint256 price,uint256 nonce,uint256 deadline)"),
                sale.seller,
                sale.tokenId,
                sale.price,
                sale.nonce,
                sale.deadline
            )
        );

        bytes32 digest = EIP712Helper.hashTypedDataV4(structHash);
        address signer = ecrecover(digest, v, r, s);
        require(signer == sale.seller, "Invalid seller signature");

        nonces[sale.seller]++; // 更新nonce，防止重放攻击
        
        buyNFT(sale.tokenId);

        // 向卖家转款
        payable(sale.seller).transfer(sale.price);

    }
}