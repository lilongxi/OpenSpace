// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "oz_v5/contracts/utils/ReentrancyGuard.sol";
import "oz_v5/contracts/token/ERC20/IERC20.sol";
import "oz_v5/contracts/access/Ownable.sol";

contract IDO is ReentrancyGuard, Ownable {

    IERC20 public token;           // 预售的ERC20代币
    uint256 public price;          // 每个Token的预售价格（以ETH计价）
    uint256 public goal;           // 募集的目标ETH数量
    uint256 public cap;            // 募集的上限ETH数量
    uint256 public duration;       // 预售时长（以秒为单位）
    uint256 public startTime;      // 预售开始时间
    uint256 public totalRaised;    // 已募集的ETH数量
    bool public finalized;         // 标记是否已结束并进行处理

    mapping(address => uint256) public contributions; // 用户的ETH贡献
    mapping(address => uint256) public tokensPurchased; // 用户购买的Token数量

    event IDOStarted(uint256 startTime, uint256 duration);
    event TokenPurchased(address indexed buyer, uint256 ethAmount, uint256 tokenAmount);
    event RefundClaimed(address indexed buyer, uint256 ethAmount);
    event Withdrawn(uint256 amount);
    event TokensClaimed(address indexed buyer, uint256 tokenAmount);

    modifier onlyWhileOpen {
        require(isOpen(), "IDO is not open");
        _;
    }

    constructor(
        address _token,
        uint256 _price,
        uint256 _goal,
        uint256 _cap,
        uint256 _duration
    ) Ownable(_msgSender()) {
        token = IERC20(_token);
        price = _price;
        goal = _goal;
        cap = _cap;
        duration = _duration;
    }

    // 开始预售
    function startIDO() external onlyOwner {
         require(startTime == 0, "IDO has already started");
         startTime = block.timestamp;
         emit IDOStarted(startTime, duration);
    }

    // 活动范围区间
    function isOpen() public view returns (bool) {
        return (block.timestamp >= startTime && block.timestamp <= startTime + duration);
    }

    function isSuccessful() public view returns (bool) {
        return totalRaised >= goal;
    }

    // 购买代币：用户在预售期间可以通过 buyTokens 函数支付 ETH 购买 Token，Token 数量按指定的价格计算
    // payable 隐式接收 ETH
    function buyTokens() public payable virtual onlyWhileOpen nonReentrant {
        require(msg.value > 0, "Cannot purchase with zero ETH");
        uint256 tokenAmount = (msg.value * 1e18) / price; // Calculate tokens based on ETH contributed
        require(totalRaised + msg.value <= cap, "Purchase exceeds cap");

        contributions[msg.sender] += msg.value;
        tokensPurchased[msg.sender] += tokenAmount; // wgei
        totalRaised += msg.value;

        emit TokenPurchased(msg.sender, msg.value, tokenAmount);
    }

    // 领取代币：预售结束且达到募集目标后，用户可以通过 claimTokens 领取代币
    function claimTokens() external {
        require(block.timestamp > startTime + duration, "IDO not yet ended");
        require(isSuccessful(), "IDO was not successful");
        uint256 amount = tokensPurchased[msg.sender];
        require(amount > 0, "No tokens to claim");
        tokensPurchased[msg.sender] = 0;
        require(token.transfer(msg.sender, amount), "Token transfer failed");
        emit TokensClaimed(msg.sender, amount);
    }

    // 领取退款：预售结束未达到募集目标时，用户可以通过 claimRefund 领取退款。
    function claimRefund() external {
        require(block.timestamp > startTime + duration, "IDO not yet ended"); // 未开始
        require(!isSuccessful(), "IDO was successful, no refunds"); // 已经成功无法退款

        // 贡献了多少
         uint256 contributed = contributions[msg.sender];
         require(contributed > 0, "No contributions found");
         contributions[msg.sender] = 0;
         // 退回
        (bool success, ) = msg.sender.call{value: contributed}("");
        require(success, "Refund transfer failed");
        emit RefundClaimed(msg.sender, contributed);
    }

    // 提取募集资金：预售成功后，项目方可以调用 withdrawFunds 提取募集到的 ETH。
    function withdrawFunds() external onlyOwner nonReentrant {

        require(block.timestamp > startTime + duration, "IDO not yet ended");
        require(isSuccessful(), "IDO was not successful");
        require(!finalized, "Funds already withdrawn");

        finalized = true;
        // 获取当前合约中的 ETH 总量
        uint256 amount = address(this).balance;
        payable(owner()).transfer(amount);
        // (bool success, ) = owner().call{value: amount}("");
        // require(success, "Withdrawal failed");

        emit Withdrawn(amount);
    }

     receive() external payable {
        buyTokens();
    }
}