// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "oz_v5/contracts/token/ERC20/extensions/ERC20Permit.sol";
import { BaseERC20 } from "src/BaseERC20.sol";
import { BaseERC721 } from "src/chapter-006/MyERC721.sol";
import { NFTMarketPermit } from "src/chapter-010/home-work/NFTMarketPermit.sol";

contract NFTMarketPermitTest is Test {

    BaseERC20 public erc20;
    BaseERC721 public erc721;
    NFTMarketPermit public nftMarketPermit;

    address public seller = address(1);
    address public buyer = address(2);

    // Define the private key for the whitelist signer
    uint256 whitelistPrivateKey = 0xA11CE;


    function setUp() public {
        erc20 = new BaseERC20("MyToken", "MTK");
        erc721 = new BaseERC721("MyNameNFT", "MyNameNFT", "ipfs://QmV9uPCxLngdDABdwYG8TNoXff3MPoTjvXyACDJ2wU2RqJ");
        nftMarketPermit = new NFTMarketPermit(address(erc721), address(erc20));
    }

    function _mintNFT(address user_, uint tokenId_) internal {
        erc721.mint(user_, tokenId_);
        assertEq(erc721.ownerOf(tokenId_), user_);
    }

    function testListNFT() public {
       _mintNFT(seller, 1);
       _mintNFT(seller, 2);
    }

}