// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "oz_v4_9/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "oz_v4_9/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "oz_v4_9/contracts/utils/Counters.sol";

/**
 * tokenId -> tokenURI -> meta -> 链接其他资源
 * meta 链接链上和链下数据
 * @title 
 * @author 
 * @notice 
 */
contract ArtistNFT is ERC721URIStorage, ERC721Enumerable {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    event NFTMinted(address indexed artist, uint256 indexed tokenId, string tokenURI);
    event NFTBurned(address indexed owner, uint256 indexed tokenId);

    constructor() ERC721("ArtistNFT", "AN") {
    }

    function mint(address artist, string memory _tokenURI)
        public
        returns (uint256)
    {
        uint256 newItemId = _tokenIds.current();
        _mint(artist, newItemId);
        _setTokenURI(newItemId, _tokenURI);

        emit NFTMinted(artist, newItemId, _tokenURI);

        _tokenIds.increment();
        return newItemId;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, firstTokenId,batchSize);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        address owner = ownerOf(tokenId);
        super._burn(tokenId);
        emit NFTBurned(owner, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return ERC721URIStorage.tokenURI(tokenId);
    }
}