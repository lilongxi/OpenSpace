// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/console.sol";

import "oz_v5/contracts/utils/Context.sol";
import "oz_v5/contracts/utils/ReentrancyGuard.sol";
import "../../chapter-006/NFTMarket/NFTMarket.sol";
import "./EIP712Helper.sol";

contract NFTMarketPermit is NFTMarket, ReentrancyGuard {
    
    using EIP712Helper for bytes32;

    mapping (address => bool) public whitelisted;
    mapping (address => uint256) public nonces;

    string private constant NAME = "NFTMarketPermit";
    string private constant VERSION = "1";

   constructor(address _nftAddr, address _tokenAddr) NFTMarket(_nftAddr, _tokenAddr) {}

  function setWhiteisted(address user) external onlyOwner returns(bool) {
    whitelisted[user] = true;
    return whitelisted[user];
  }

  function revokeWhitelisted(address user) external onlyOwner {
    whitelisted[user] = false;
  }

  function getWhitelistedByAddr(address addr) public view returns(bool) {
    return whitelisted[addr];
  }

  function permitBuyEip191(uint tokenId, uint nonce, uint deadline, uint8 v, bytes32 r, bytes32 s) public nonReentrant { 

    address buyer = _msgSender();
    // require(whitelisted[buyer], "You are not whitelisted for this purchase.");

    bytes32 hash = keccak256(abi.encodePacked(buyer, nonce, deadline));
    address signer = ecrecover(hash, v, r, s);
    require(signer == _msgSender(), "Invalid signature");

    // 验证是否在截止日期内
    require(block.timestamp <= deadline, "Signature expired");

    nonces[buyer]++;

    buyNFT(tokenId);

  }

  function permitBuyEip712(
    uint256 tokenId,
    uint256 nonce,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public nonReentrant {

    address buyer = _msgSender();
    // require(whitelisted[buyer], "You are not whitelisted for this purchase.");

    bytes32 structHash = keccak256(
        abi.encode(
            keccak256("Permit(address buyer,uint256 nonce,uint256 deadline)"),
            buyer,
            nonce,
            deadline
        )
        
    );

    bytes32 digest = EIP712Helper.hashTypedDataV4(structHash);
     // 验证签名
    address signer = ecrecover(digest, v, r, s);
    require(signer == _msgSender(), "Invalid signature");

     // 验证是否在截止日期内
    require(block.timestamp <= deadline, "Signature expired");

    nonces[buyer]++;

    buyNFT(tokenId);

  }

  function list(uint tokenId, uint price) public virtual override returns(bool, Listing memory) {
    return super.list(tokenId, price);
  }

}