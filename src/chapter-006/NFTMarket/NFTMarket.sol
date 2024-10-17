// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "oz_v5/contracts/token/ERC721/ERC721.sol";
import "oz_v5/contracts/token/ERC721/IERC721Receiver.sol";
import "oz_v5/contracts/token/ERC20/ERC20.sol";


// 继承 IERC721Receiver 实现 onERC721Received 表明可处理 NFT 防止锁死
// 
contract NFTMarket is IERC721Receiver {

    IERC20 public payment;
    IERC721 public nftContract;

}