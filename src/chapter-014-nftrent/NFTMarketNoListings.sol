// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// import "forge-std/Test.sol";
// import "forge-std/console.sol";
import "oz_v5/contracts/token/ERC721/IERC721.sol";
import "oz_v5/contracts/access/Ownable.sol";
import "oz_v5/contracts/utils/cryptography/EIP712.sol";
import "oz_v5/contracts/utils/cryptography/ECDSA.sol";
import "oz_v5/contracts/utils/ReentrancyGuard.sol";
import "oz_v5/contracts/token/ERC721/IERC721Receiver.sol";

contract NFTMarketNoListingsEvents {
    event NFTListed(
        address indexed nftContract,
        uint256 indexed tokenId,
        address indexed seller,
        uint256 price,
        bytes32 listingId,
        string ipfsHash
    );

    event NFTPurchased(
        address indexed nftContract,
        uint256 indexed tokenId,
        address indexed buyer,
        uint256 price,
        bytes32 listingId
    );
}


contract NFTMarketNoListings is EIP712, Ownable, ReentrancyGuard, IERC721Receiver, NFTMarketNoListingsEvents {
    using ECDSA for bytes32;

    mapping(bytes32 => bool) public usedSignatures;

    // 定义上架 NFT 的结构体哈希，用于生成 EIP-712 签名
    bytes32 public constant LISTING_TYPEHASH = keccak256(
        "Listing(address nftContract,uint256 tokenId,uint256 price,address seller,string ipfsHash)"
    );

    string private constant NAME = "NFTMarketNoListings";
    string private constant VERSION = "1";
    constructor() EIP712(NAME, VERSION) Ownable(_msgSender()) {}

    function listNFT(
        address nftContract,
        uint256 tokenId,
        uint256 price,
        string memory ipfsHash, // 链外存储的 IPFS 哈希
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        address owner = _msgSender();
        // 创建 listing 哈希
        bytes32 structHash = keccak256(
            abi.encode(
                LISTING_TYPEHASH,
                nftContract,
                tokenId,
                price,
                owner,
                keccak256(bytes(ipfsHash))
            )
        );
        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ecrecover(hash, v, r, s);
        require(signer == owner, "Invalid signature");
        require(!usedSignatures[hash], "Signature already used");

        usedSignatures[hash] = true;

        bytes32 listingId = keccak256(abi.encodePacked(nftContract, tokenId, owner, block.timestamp));
        // 发出上架事件
        emit NFTListed(nftContract, tokenId, owner, price, listingId, ipfsHash);

    }

    // 购买 NFT
    function buyNFT(
        address nftContract,
        uint256 tokenId,
        uint256 price,
        address seller,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable nonReentrant {
        // 确认发送的 ETH 是否足够
        require(msg.value >= price, "Insufficient ETH sent");
        address owner = _msgSender();
        // 生成待验证的哈希数据
        bytes32 structHash = keccak256(
            abi.encode(
                LISTING_TYPEHASH,
                nftContract,
                tokenId,
                price,
                seller,
                keccak256("")
            )
        );
        bytes32 hash = hashTypedDataV4(structHash);

        // 确认签名
        address signer = ecrecover(hash, v, r, s);
        require(signer == seller, "Invalid signature");
        require(!usedSignatures[hash], "Signature already used");

        usedSignatures[hash] = true;

        // 转移 NFT 给买家
        IERC721(nftContract).safeTransferFrom(seller, owner, tokenId);

        // 支付卖家
        (bool success, ) = payable(seller).call{value: price}("");
        require(success, "Transfer failed");

        bytes32 listingId = keccak256(abi.encodePacked(nftContract, tokenId, seller, block.timestamp));
        emit NFTPurchased(nftContract, tokenId, owner, price, listingId);
    }

    function hashTypedDataV4(bytes32 structHash) public view returns (bytes32) {
        return _hashTypedDataV4(structHash);
    }

     //  要求实现避免锁死
    function onERC721Received(address operator,
        address from,
        uint256 tokenId,
        bytes calldata data) external override returns (bytes4) {
            return this.onERC721Received.selector;
    }
}