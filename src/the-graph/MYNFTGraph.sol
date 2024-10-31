// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { ERC721 } from "oz_v5/contracts/token/ERC721/ERC721.sol";

// 0x2EA7D6f1b6Df8Ca3829DD41A6f30c848F2D47CBC.
contract OSGraphNFT is ERC721("OpenSpaceGraphNFT", "OSGraphNFT") {
    address public owner;

    constructor() {
        owner = msg.sender;
        mint(0);
        mint(1);
        mint(2);
    }

    function mint(uint256 tokenId) public {
        require(tokenId < 2024, "tokenId must be less than 2024");
        _safeMint(msg.sender, tokenId);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://data.debox.pro/dgs/meta/";
    }
}