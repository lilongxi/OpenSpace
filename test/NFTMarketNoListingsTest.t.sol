// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "oz_v5/contracts/token/ERC721/ERC721.sol";
import { NFTMarketNoListings, NFTMarketNoListingsEvents } from "src/chapter-014-nftrent/NFTMarketNoListings.sol";

contract MockNFT is ERC721 {
    uint256 public currentTokenId;

    constructor() ERC721("MockNFT", "MNFT") {}

    function mint() external {
        currentTokenId++;
        _mint(msg.sender, currentTokenId);
    }
}

contract NFTMarketNoListingsTest is Test, NFTMarketNoListingsEvents {
    NFTMarketNoListings market;
    MockNFT nft;

    uint privateSeller = 0xBEEF;
    address public seller = vm.addr(privateSeller);

    event NFTListedV2(uint256 indexed tokenId, uint256 price, address indexed seller);

    function setUp() public {
        // 创建市场合约
        market = new NFTMarketNoListings();
        // 创建 NFT 合约
        nft = new MockNFT();
        vm.deal(seller, 10 ether); // 给卖家账户一定的 ETH
        vm.startPrank(seller); // 切换到卖家的账户
        nft.mint(); // 铸造一个 NFT
        vm.stopPrank();
    }

    function testListNFT() public {
        
        uint256 tokenId = 1; // 使用铸造的 tokenId
        uint256 price = 100;
        string memory ipfsHash = "QmExampleIpfsHash";

        // 使用 seller 的地址签名数据
        bytes32 structHash = keccak256(
            abi.encode(
                market.LISTING_TYPEHASH(),
                address(nft),
                tokenId,
                price,
                seller,
                keccak256(bytes(ipfsHash))
            )
        );
        bytes32 digest = market.hashTypedDataV4(structHash);
        // console.log(digest);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateSeller, digest);

        bytes32 listingId = keccak256(abi.encodePacked(address(nft), tokenId, seller, block.timestamp));

        // // 开始上架 NFT
        vm.prank(seller); // 切换到卖家的账户
        vm.expectEmit(true, true, true, true);
        emit NFTListed(address(nft), tokenId, seller, price, listingId, ipfsHash); // 已经修改为符合事件定义的格式
        market.listNFT(address(nft), tokenId, price, ipfsHash, v, r, s);
        // vm.stopPrank();

        // 验证上架事件是否触发
        // 在这里可以根据需要添加断言，检查事件是否被正确触发等

    }

    function _generateListingSignature(
        address nftContract,
        uint256 _tokenId,
        uint256 _price,
        string memory _ipfsHash,
        address _seller
    ) internal view returns (bytes memory) {
        bytes32 structHash = keccak256(
            abi.encode(
                market.LISTING_TYPEHASH(),
                nftContract,
                _tokenId,
                _price,
                _seller,
                keccak256(bytes(_ipfsHash))
            )
        );
        bytes32 hash = market.hashTypedDataV4(structHash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(uint256(uint160(_seller)), hash);
        return abi.encodePacked(r, s, v);
    }

}