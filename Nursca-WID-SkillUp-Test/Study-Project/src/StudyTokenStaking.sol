// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract StudyTokenStaking {
  IERC20 public immutable studyToken;
  uint256 public rewardRate;
  uint256 public stakingPeriod = 30 days;

  struct Stake {
    uint256 amount;
    uint256 stakedAt;
    uint256 unlockedAt;
    bool claimed;
  }
  
  mapping(address => Stake) public stakes;

  event Staked(address indexed user, uint256 amount, uint256 indexed unlockedAt);
  event Claimed(address indexed user, uint256 amount, uint256 reward);

  constructor(IERC20 _studyToken, uint256 _rewardRate) {
    studyToken = _studyToken;
    rewardRate = _rewardRate;
  }

  function stake(uint256 _amount) external {
    require(_amount > 0, "Cannot stake zero");
    require(stakes[msg.sender].amount == 0, "Already staking");
    
    studyToken.transferFrom(msg.sender, address(this), _amount);

    stakes[msg.sender] = Stake({
      amount: _amount,
      stakedAt: block.timestamp,
      unlockedAt: block.timestamp + stakingPeriod,
      claimed: false
    });
    
    emit Staked(msg.sender, _amount, block.timestamp + stakingPeriod);
  }

  function claim() external {
    Stake storage userStake = stakes[msg.sender];
    require(userStake.amount > 0, "No stake");
    require(block.timestamp >= userStake.unlockedAt, "Not unlocked");
    require(!userStake.claimed, "Already claimed");

    uint256 reward = (userStake.amount * rewardRate * stakingPeriod) / (365 days * 10000);
    uint256 total = userStake.amount + reward;

    userStake.claimed = true;

    studyToken.transfer(msg.sender, total);

    emit Claimed(msg.sender, userStake.amount, reward);
  }
}   