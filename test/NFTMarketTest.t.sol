
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import { NFTMarket, NFTMarketEvent } from "src/chapter-006/NFTMarket/NFTMarket.sol";
import { BaseERC20 } from "src/BaseERC20.sol";
import { BaseERC721 } from "src/chapter-006/MyERC721.sol";

/**
 * @title 
 * @author 
 * @notice
 * 测试 NFTMarket 合约：测试Case
❖ 上架NFT：测试上架成功和失败情况，要求断言错误信息和上架事件。
❖ 购买NFT：测试购买成功、自己购买自己的NFT、NFT被重复购买、支付Token过多或者过少情况，要求断言错误信息和购买事件。
❖ 模糊测试：测试随机使用 0.01-10000 Token价格上架NFT，并随机使用任意Address购买NFT
❖ 「可选」不可变测试：测试无论如何买卖，NFTMarket合约中都不可能有 Token 持仓 
 */

contract NFTMarketTest is Test, NFTMarketEvent {

    BaseERC20 public erc20;
    BaseERC721 public erc721;
    NFTMarket public nftMarket;

    uint private constant TOKENID = 0;
    uint private constant PRICE = 100;
    uint private constant RECHARGE = 1000;


    function setUp() public {
        erc20 = new BaseERC20("MyToken", "MTK");
        erc721 = new BaseERC721("MyNameNFT", "MyNameNFT", "ipfs://QmV9uPCxLngdDABdwYG8TNoXff3MPoTjvXyACDJ2wU2RqJ");
        nftMarket = new NFTMarket(address(erc721), address(erc20));
    }

    function _approveTokenIdByNftMarket() internal {
        erc721.setApprovalForAll(address(nftMarket), true);
    }

    function _recharge(address user_, uint amount_) internal {
        address v = address(erc20);
        deal(v, user_, amount_);
        assertEq(erc20.balanceOf(user_), amount_);
    }

    function _mintNFT(address user_, uint tokenId_) internal {
        erc721.mint(user_, tokenId_);
        assertEq(erc721.ownerOf(tokenId_), user_);
    }

    function _listedNFT(address user_, uint tokenId, uint price, bool isEmitter) internal {
        if (isEmitter) {
            vm.expectEmit(false, false, false, true);
            emit NFTListed(tokenId, price, user_);
        }
        nftMarket.list(tokenId, price);
    }

    function _listedRepeatNFT(uint tokenId, uint price) internal {
        vm.expectRevert("You are not the owner of this NFT");
        nftMarket.list(tokenId, price);
    }

    function _listingByTokenId (address user_,  uint tokenId_, uint price_, bool isLog_) internal view {
        (uint tokenId, address seller, uint price, bool isSold) = nftMarket.listings(tokenId_);
        if (isLog_) {
            console.log(tokenId, erc721.ownerOf(tokenId), seller, isSold);
        }
        assertEq(tokenId, tokenId_);
        assertEq(seller, user_);
        assertEq(price, price_);
    }

    function _update(address user_, uint tokenId_, uint price_, bool isLog_) internal {
        // 测试创建合约
        _mintNFT(user_, tokenId_);
        // 设置NFT市场权限
        _approveTokenIdByNftMarket();
        // 测试上架
        _listedNFT(user_, tokenId_, price_, true);
        // token 是否成功上架
        _listingByTokenId(user_, tokenId_, price_, isLog_);
    }

    function testListedBySucceed() public {
        address user = address(1);
        vm.startPrank(user);
        _update(user, TOKENID, PRICE, false);
        vm.stopPrank();
    }

    /**
     * 1. 没有给 nftMarker 授权
     * 2. 上架人不是发行人
     * 3. 重复上架同一个 nft
     */
    function testListedByFailed() public {

        address userIsMint = address(1);
        address userNotMint = address(2);
        vm.startPrank(userIsMint);
        _mintNFT(userIsMint, TOKENID);

        vm.expectRevert('NFT not approved');
        _listedNFT(userIsMint, TOKENID, PRICE, false);

        _approveTokenIdByNftMarket();

        vm.startPrank(userNotMint);
        vm.expectRevert('You are not the owner of this NFT');
        _listedNFT(userIsMint, TOKENID, PRICE, false);
        vm.stopPrank();

         // 重复上架
        _listedRepeatNFT(TOKENID, PRICE);

        vm.stopPrank();
    }



    function _purchaser(address purchaser, uint token_, bool buySelf_, bool buyRepeat_) internal {
        vm.startPrank(purchaser);
        
        _recharge(purchaser, RECHARGE);
        erc20.approve(address(nftMarket), PRICE);
        assertEq(erc20.allowance(purchaser, address(nftMarket)), PRICE);

        uint balance = erc721.balanceOf(purchaser);

        if (buySelf_) {
            vm.expectRevert('Cannot purchase NFTs that are self listed');
            nftMarket.buyNFT(token_);
            return;
        } else if (token_ != TOKENID) {
            vm.expectRevert('This NFT is not for sale.');
            nftMarket.buyNFT(token_);
            return;
        } else {
            vm.expectEmit(false, false, false, true);
            emit NFTPurchased(token_, PRICE, purchaser);
            nftMarket.buyNFT(token_);
        }

        if (buyRepeat_) {
              // 重复购买
            vm.expectRevert('This NFT is sold');
            nftMarket.buyNFT(token_);
        }

        assertEq(erc721.ownerOf(token_), purchaser);
        assertEq(erc721.balanceOf(purchaser), balance + 1);
        assertEq(erc20.balanceOf(purchaser), RECHARGE - PRICE);

        (, , , bool isSold) = nftMarket.listings(token_);
        assertEq(isSold, true);
        vm.stopPrank();
    }

    /**
     * 1 用户购买已上架 nft
     * 2 查看用户名下是否有这个 nft
     * 3 nft 市场这个 nft 的 isSold 状态
     */
    function testNftBuyBySucceed() public {
        address seller = address(1);
        address purchaser = address(2);
         vm.startPrank(seller);
         _update(seller, TOKENID, PRICE, true);
         _purchaser(purchaser, TOKENID, false, false);
         assertEq(erc721.balanceOf(seller), 0);
         assertEq(erc20.balanceOf(seller), PRICE);
         vm.stopPrank();
    }

    function testNftBuyByMyself() public {
         address seller = address(1);
         vm.startPrank(seller);
         _update(seller, TOKENID, PRICE, true);
         _purchaser(seller, TOKENID, true, false);
         assertEq(erc721.balanceOf(seller), 1);
         assertEq(erc20.balanceOf(seller), RECHARGE);
         vm.stopPrank();
    }

    /**
     * 3. 购买没有的 NFT
     * 4. 重复购买 NFT
     */
    function testNftFailedByRepeatBuy() public {
        address seller = address(1);
        address purchaser = address(2);
         vm.startPrank(seller);
         _update(seller, TOKENID, PRICE, true);
         _purchaser(purchaser, TOKENID, false, true);
         assertEq(erc721.balanceOf(seller), 0);
         assertEq(erc20.balanceOf(seller), PRICE);
         vm.stopPrank();
    }

    function testNftFailedByNotThisNft() public {
        address seller = address(1);
        address purchaser = address(2);
        vm.startPrank(seller);
        _update(seller, TOKENID, PRICE, true);
        _purchaser(purchaser, TOKENID + 1, false, true);
        assertEq(erc721.balanceOf(seller), 1);
        assertEq(erc20.balanceOf(seller), PRICE - PRICE);
        vm.stopPrank();
    }

    /** 
     * 单文件配置
     * forge-config: default.fuzz.runs = 100
     */
    function testFuzz_RandomListedNft(uint tokenId, uint price, address user) public pure   {
        console.log(tokenId, price, user);
    }

}
