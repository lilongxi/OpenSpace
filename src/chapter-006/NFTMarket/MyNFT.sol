// https://learnblockchain.cn/article/8667
// https://app.pinata.cloud/
// 0x6cb4512ea31cd0728ed7aafdca4ee18a2182ceff
// https://testnets.opensea.io/assets/sepolia/0x6cb4512ea31cd0728ed7aafdca4ee18a2182ceff/0

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "oz_v5/contracts/token/ERC721/ERC721.sol";
import "oz_v5/contracts/access/Ownable.sol";
import "oz_v5/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


contract MyNFT is ERC721URIStorage, Ownable {
    uint256 public tokenCounter;

    constructor() ERC721("MyNameNFT", "EGAMA") Ownable(msg.sender) {
        tokenCounter = 0;
    }

    function createNFT(string memory tokenURI) public onlyOwner returns (uint256) {
        uint256 newTokenId = tokenCounter;
        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        tokenCounter++;
        return newTokenId;
    }

    // function mint(address to) external onlyOwner {
    //     uint tokenId = nextId;
    //     nextId++;
    //     _safeMint(to, tokenId);
    // }
}