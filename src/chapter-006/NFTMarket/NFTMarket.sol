// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "oz_v5/contracts/utils/Context.sol";
import "oz_v5/contracts/access/Ownable.sol";
import "oz_v5/contracts/token/ERC721/IERC721Receiver.sol";
// import "oz_v5/contracts/token/ERC721/ERC721.sol";
import "../ERC20WithCallback.sol";
import "../MyERC721.sol";

// import "oz_v5/contracts/token/ERC20/ERC20.sol";

/**
 * @title 
 * @author 
 * @notice
 * 编写一个简单的 NFTMarket 合约，使用自己发行的ERC20 扩展 Token 来买卖 NFT， NFTMarket 的函数有：

list() : 实现上架功能，NFT 持有者可以设定一个价格（需要多少个 Token 购买该 NFT）并上架 NFT 到 NFTMarket，上架之后，其他人才可以购买。

buyNFT() : 普通的购买 NFT 功能，用户转入所定价的 token 数量，获得对应的 NFT。

实现ERC20 扩展 Token 所要求的接收者方法 tokensReceived  ，在 tokensReceived 中实现NFT 购买功能。
贴出你代码库链接。 
 */

// 继承 IERC721Receiver 实现 onERC721Received 表明可处理 NFT 防止锁死
// 

contract NFTMarketEvent {
    event NFTListed(uint256 indexed tokenId, uint256 price, address indexed seller);
    event NFTPurchased(uint256 indexed tokenId, uint256 price, address indexed buyer);
}

contract NFTMarket is IERC721Receiver, Ownable, IERC20WithCallback, NFTMarketEvent {

    ERC20WithCallback public tkContact;
    BaseERC721 public nftContract;

    struct Listing {
        uint tokenId;
        address seller;
        uint price;
        bool isSold;
    }

    mapping (uint => Listing) public listings; 
    
    constructor(address _nftAddr, address _tokenAddr) Ownable(_msgSender()) {
        nftContract = BaseERC721(_nftAddr);
        tkContact = ERC20WithCallback(_tokenAddr);
    }

    // NFT持有者上架NFT，设置价格
    function list(uint tokenId, uint price) external {
        address owner = _msgSender();
        require(nftContract.ownerOf(tokenId) == owner, "You are not the owner of this NFT");
        require(price > 0, "Price must be greater than zero");
        
        // 授权给 markert 地址
        require(nftContract.isApprovedForAll(owner, address(this)) || nftContract.getApproved(tokenId) == address(this), "NFT not approved");

        // nftContract.setApprovalForAll(address(this), true);
        listings[tokenId] = Listing(tokenId, owner, price, false);
        
         emit NFTListed(tokenId, price, owner); 
    }

    function tokensReceived(address from, uint256 amount, bytes calldata data) external returns (bool) {
        require(_msgSender() == address(tkContact), "Invalid sender");
        uint256 tokenId = abi.decode(data, (uint256));
        Listing memory listing = listings[tokenId];
        require(listing.price > 0, "This NFT is not for sale.");
        require(amount >= listing.price, "Insufficient token amount sent.");
        require(tkContact.transferFrom(from, listing.seller, listing.price), "Token transfer failed.");

        nftContract.safeTransferFrom(listing.seller, from, tokenId);

        listings[tokenId] = Listing(listing.tokenId, listing.seller, listing.price, true);

        emit NFTPurchased(tokenId, listing.price, from);

        return true;
    }

    function buyNFT (uint tokenId) external {
        Listing memory listing = listings[tokenId];
        address owner = _msgSender();
        
        require(listing.price > 0, "This NFT is not for sale.");
        require(!listing.isSold, "This NFT is sold");
        require(listing.seller != owner,"Cannot purchase NFTs that are self listed");
        require(tkContact.balanceOf(owner) >= listing.price, "Insufficient token balance.");
        require(tkContact.allowance(owner, address(this)) >= listing.price, "Insufficient allowance.");
        require(tkContact.transferFrom(owner, listing.seller, listing.price), "Token transfer failed.");

        nftContract.safeTransferFrom(listing.seller, owner, tokenId);
        
        listings[tokenId] = Listing(listing.tokenId, listing.seller, listing.price, true);

        emit NFTPurchased(tokenId, listing.price, owner);
    }

    //  要求实现避免锁死
    function onERC721Received(address operator,
        address from,
        uint256 tokenId,
        bytes calldata data) external override returns (bytes4) {
            return this.onERC721Received.selector;
    }

}