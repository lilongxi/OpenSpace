// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// TODO 多次所仓
contract EsRNT is ERC20, Ownable {
    
    string private constant NAME = "esRNT";
    IERC20 public RNTToken;
    struct LockInfo {
        uint256 amount;
        uint256 collectionTime;
    }

    mapping (address => LockInfo) public usersOfLock;

    event EsRNTMinted(address indexed to, uint256 indexed amount, LockInfo);
    event EsRNTBurned(address indexed to, uint256 indexed amount, LockInfo);

    error TransferNotAllowed();
    error ApprovalNotAllowed();

    constructor(IERC20 _tokenOfRNT) ERC20(NAME, NAME) Ownable(msg.sender) {
        RNTToken = _tokenOfRNT;
    }

    // 仅允许池子进行铸造和销毁
    function  mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
        LockInfo storage userOfLock = usersOfLock[to];
        userOfLock.amount += amount;
        userOfLock.collectionTime = block.timestamp;
        emit EsRNTMinted(to, amount, userOfLock);
    }

    // 仅允许池子进行铸造和销毁
    function burn(address from, uint256 amount) external onlyOwner {
        LockInfo storage userOfLock = usersOfLock[from];
         // 计算解锁金额，使用秒为单位而不是天数
        uint256 unlockAmount = (block.timestamp - userOfLock.collectionTime) * amount / 86400;

         // 确保解锁金额不会小于 1
        require(unlockAmount >= 1, "Insufficient unlock amount");

         // 更新锁仓时间
        userOfLock.collectionTime = block.timestamp;
        
         // 销毁解锁金额
        _burn(from, unlockAmount);

        emit EsRNTBurned(from, unlockAmount, userOfLock);
    }
    
    function getLockOfUser(address user) public view returns(LockInfo memory) {
        return usersOfLock[user];
    }

    // 禁用转账功能 禁止在市面流通
     // disable transfer -> this means the token is not tradable
    function transfer(address, uint256) public virtual override returns (bool) {
        revert TransferNotAllowed();
    }

    // disable transferFrom -> this means the token is not tradable
    function transferFrom(address, address, uint256) public virtual override returns (bool) {
        revert TransferNotAllowed();
    }

    // disable approve -> this means the token is not approveable
    function approve(address, uint256) public virtual override returns (bool) {
        revert ApprovalNotAllowed();
    }
   
}