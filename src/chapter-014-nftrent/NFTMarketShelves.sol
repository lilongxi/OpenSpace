// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "oz_v5/contracts/token/ERC721/IERC721.sol";
import "oz_v5/contracts/access/Ownable.sol";
import "oz_v5/contracts/utils/cryptography/EIP712.sol";
import "oz_v5/contracts/utils/cryptography/ECDSA.sol";
import "oz_v5/contracts/utils/ReentrancyGuard.sol";

import "../chapter-010/home-work/EIP712Helper.sol";

contract NFTMarketShelves is EIP712, Ownable, ReentrancyGuard {

    using ECDSA for bytes32;
    using EIP712Helper for bytes32;
    
    struct Listing {
        address nftContract;
        uint256 tokenId;
        uint256 price;
        address seller;
        bool isSold;
    }
    
    mapping(bytes32 => Listing) public listings;
    mapping(bytes32 => bool) public usedSignatures;

    event NFTListed(
        address indexed nftContract,
        uint256 indexed tokenId,
        uint256 price,
        address indexed seller,
        bytes32 listingId
    );

    event NFTPurchased(
        address indexed nftContract,
        uint256 indexed tokenId,
        address indexed buyer,
        uint256 price,
        bytes32 listingId
    );

    constructor() EIP712("NFTMarketShelves", "1") Ownable(msg.sender) {}

    bytes32 private constant LISTING_TYPEHASH = keccak256(
        "Listing(address nftContract,uint256 tokenId,uint256 price,address seller)"
    );

    function listNFT (address nftContract, uint256 tokenId, uint256 price, bytes memory signature) external {
         bytes32 structHash = keccak256(
            abi.encode(
                LISTING_TYPEHASH,
                nftContract,
                tokenId,
                price,
                msg.sender
            )
        );
        bytes32 hash = EIP712Helper.hashTypedDataV4(structHash);
        address signer = ECDSA.recover(hash, signature);
        require(signer == msg.sender, "Invalid signature");
        require(!usedSignatures[hash], "Signature already used");

        usedSignatures[hash] = true;

        bytes32 listingId = keccak256(abi.encodePacked(nftContract, tokenId, msg.sender, block.timestamp));

        listings[listingId] = Listing({
            nftContract: nftContract,
            tokenId: tokenId,
            price: price,
            seller: msg.sender,
            isSold: false
        });

        emit NFTListed(nftContract, tokenId, price, msg.sender, listingId);

    }

    function buyNFT(bytes32 listingId) external payable nonReentrant {
        Listing memory listing = listings[listingId];
        require(!listing.isSold, "Listing is Sold");
        require(msg.value >= listing.price, "Insufficient ETH sent");

        listings[listingId].isSold = true;
        IERC721(listing.nftContract).safeTransferFrom(listing.seller, msg.sender, listing.tokenId);

        // 支付卖家
        (bool success, ) = payable(listing.seller).call{value: listing.price}("");
        require(success, "Transfer failed");

        emit NFTPurchased(listing.nftContract, listing.tokenId, msg.sender, listing.price, listingId);
    }

     // 获取上架清单
    function getListing(bytes32 listingId) external view returns (Listing memory) {
        return listings[listingId];
    }

}