// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "oz_v5/contracts/utils/Context.sol";
import "oz_v5/contracts/token/ERC721/ERC721.sol";
import "oz_v5/contracts/token/ERC721/IERC721Receiver.sol";
import "oz_v5/contracts/token/ERC20/ERC20.sol";

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
contract NFTMarket is IERC721Receiver {

    address public admin;
    IERC20 public tkContact;
    IERC721 public nftContract;

    struct  MarketItem {
        uint tokenId;
        uint price;
        address seller;
        bool isSold;
    }

    MarketItem[] public marketItems;

    event MarketItemListed( address indexed seller,  
        uint256 indexed tokenId,  
        uint256 price,  
        address nftAddress );
    
    event MarketItemPurchased(  
        address buyer,  
        address seller,  
        uint256 tokenId,  
        uint256 price,  
        address nftAddress  
    );  

    constructor(address _nftAddr, address _tokenAddr) {
        admin = msg.sender;
        nftContract = IERC721(_nftAddr);
        tkContact = IERC20(_tokenAddr);
    }

    //  要求实现避免锁死
    function onERC721Received(address operator,
        address from,
        uint256 tokenId,
        bytes calldata data) external override returns (bytes4) {
            return this.onERC721Received.selector;
        }

}