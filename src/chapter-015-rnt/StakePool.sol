// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "oz_v5/contracts/utils/ReentrancyGuard.sol";

import "./esRNT.sol";

// TODO 时间计算有问题
contract StakePool is Ownable, ReentrancyGuard {
    IERC20 public rntToken;
    EsRNT public esrentToken;

    // 每个 RNT 每天的奖励
    uint256 public constant REWARD_RATE = 1; 
    struct StakeInfo {
        uint256 staked; // 质押RNT数量
        uint256 unclaimed;  // 未领取的奖励
        uint256 lastUpdateTime;  // 最后一次更新时间
    }

    mapping(address => StakeInfo) public stakes;
    event Redeemed(address indexed user, uint256 esRNTAmount, uint256 rntAmount);

    constructor(IERC20 _rntToken, EsRNT _esrntToken) Ownable(msg.sender) {
        rntToken = _rntToken;
        esrentToken = _esrntToken;
    }

    function _updateReward(address account) internal {
        StakeInfo storage stakeInfo = stakes[account];
        if (stakeInfo.lastUpdateTime > 0) {
            uint256 holdingTime = (block.timestamp - stakeInfo.lastUpdateTime) / 86400; // 持有时间按天计算
            stakeInfo.unclaimed += (stakeInfo.staked * REWARD_RATE * holdingTime) / 100; // 计算未领取的奖励
        }
        stakeInfo.lastUpdateTime = block.timestamp; // 更新最后一次更新时间
    }

    // 质押 从用户的账户转移 RNT 到 流动池
    function stake(uint256 amount) external nonReentrant {
         require(amount > 0, "Amount must be greater than zero");
        _updateReward(msg.sender);

         // 转账 RNT 到合约地址
        rntToken.transferFrom(msg.sender, address(this), amount);
        stakes[msg.sender].staked += amount;
    }

    // 解押RNT
    function unstake(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be greater than zero");
        _updateReward(msg.sender);

        StakeInfo storage stakeInfo = stakes[msg.sender];
        require(stakeInfo.staked >= amount, "Insufficient stake");

        stakeInfo.staked -= amount;
        rntToken.transfer(msg.sender, amount);
    }

    // 领取奖励
    function claim() external nonReentrant {
        _updateReward(msg.sender);
        uint256 reward = stakes[msg.sender].unclaimed;
        require(reward > 0, "No rewards available");
        
        // 清空奖励
        stakes[msg.sender].unclaimed = 0;
        
        // mint esRNT 奖励
        esrentToken.mint(msg.sender, reward);
    }

    // 兑换 esRNT 为 RNT
    function redeemEsRNT() external nonReentrant {
        (uint256 amount, uint256 collectionTime) = esrentToken.usersOfLock(msg.sender);
        require(amount > 0, "No locked tokens to redeem");

        uint256 unlockAmount = (block.timestamp - collectionTime) * amount / 86400;
        require(unlockAmount > 0, "Nothing to redeem");

        esrentToken.burn(msg.sender, amount); // 销毁 esRNT
        rntToken.transfer(msg.sender, unlockAmount); // 转回 RNT

        emit Redeemed(msg.sender, amount, unlockAmount);
    }


}