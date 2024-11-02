// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "oz_v5/contracts/utils/cryptography/ECDSA.sol";
import { NFTMarketPermit } from "../chapter-010/home-work/NFTMarketPermit.sol";
import "../chapter-010/home-work/EIP712Helper.sol";

contract NFTMarket is NFTMarketPermit {
    using EIP712Helper for bytes32;
    using ECDSA for bytes32;

    constructor(address _nftAddr, address _tokenAddr) NFTMarketPermit(_nftAddr, _tokenAddr) {}

    struct ListingOfSign {
        uint256 nonce;
        uint256 deadline;
        bytes signature;
        Listing nft;
    }

    // 存储最新的上架清单
    uint256[] public recentListings;
    mapping(uint256 => ListingOfSign) public listingsOfSign;

       // 使用离线签名验证和上架 NFT
    //    不需要 中间存储 直接从用户转走
    function listNFT(
        uint256 tokenId,
        uint256 price,
        uint256 deadline,
        bytes memory signature
    ) external returns(bool) {
        address owner = _msgSender();
        require(block.timestamp <= deadline, "Listing expired");

        // 生成要签名的哈希，包含上架信息和 nonce
        bytes32 structHash = keccak256(
            abi.encodePacked(
                keccak256("Listing(uint256 tokenId,address seller,uint256 price,uint256 nonce,uint256 deadline)"),
                tokenId,
                owner,
                price,
                nonces[owner],
                deadline
            )
        );
        bytes32 hash = EIP712Helper.hashTypedDataV4(structHash);
        address signer = ECDSA.recover(hash, signature);
        require(signer == owner, "Invalid signature");

        uint256 nonce = nonces[owner];

        // nonce 更新，防止重放攻击
        nonces[owner]++;

        // 调用父合约的 list 函数完成上架逻辑
        (bool succeed, Listing memory nft) = super.list(tokenId, price);
        if (succeed) {
            recentListings.push(tokenId);
            listingsOfSign[tokenId] = ListingOfSign(nonce, deadline, signature, nft);
        }

        return succeed;
    }

    // 展示最新的NFT上架清单
    function getRecentListings() external view returns (uint256[] memory) {
        return recentListings;
    }

    function buyNFT(uint256 tokenId) public override {
        // 这个地方的签名是 seller
        ListingOfSign memory listOfSign = listingsOfSign[tokenId];
        (uint8 v, bytes32 r, bytes32 s) = EIP712Helper.parseSignature(listOfSign.signature);
        super.permitBuyEip712(tokenId, listOfSign.nonce, listOfSign.deadline, v, r, s);
        // Listing memory listing = listings[tokenId];
        // listingsOfSign[tokenId].nft = listing;
    }


    
}