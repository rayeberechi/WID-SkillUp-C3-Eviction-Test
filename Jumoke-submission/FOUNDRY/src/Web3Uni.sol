// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract StudyToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("StudyToken", "STUDY") {
        _mint(msg.sender, initialSupply * 1e18);
    }
}


contract Staking {
    IERC20 public immutable studyToken;
    uint256 public immutable stakingDuration; 
    uint256 public rewardRate; 

    struct Stake {
        uint256 amount;
        uint256 startTime;
        bool withdrawn;
    }

    mapping(address => Stake) public stakes;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount, uint256 reward);

    constructor(address _studyToken, uint256 _duration, uint256 _rewardRate) {
        studyToken = IERC20(_studyToken);
        stakingDuration = _duration;
        rewardRate = _rewardRate;
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Cannot stake zero");
        require(stakes[msg.sender].amount == 0, "Already staked");

        studyToken.transferFrom(msg.sender, address(this), amount);

        stakes[msg.sender] = Stake({
            amount: amount,
            startTime: block.timestamp,
            withdrawn: false
        });

        emit Staked(msg.sender, amount);
    }

    function calculateReward(address user) public view returns (uint256) {
        Stake memory stakeInfo = stakes[user];
        if (stakeInfo.amount == 0 || stakeInfo.withdrawn) return 0;
        if (block.timestamp < stakeInfo.startTime + stakingDuration) return 0;


        return (stakeInfo.amount * rewardRate) / 100;
    }

    function unstake() external {
        Stake storage stakeInfo = stakes[msg.sender];
        require(stakeInfo.amount > 0, "No stake found");
        require(!stakeInfo.withdrawn, "Already withdrawn");
        require(block.timestamp >= stakeInfo.startTime + stakingDuration, "Lock period not over");

        uint256 reward = calculateReward(msg.sender);
        uint256 totalAmount = stakeInfo.amount + reward;

        stakeInfo.withdrawn = true;

        studyToken.transfer(msg.sender, totalAmount);

        emit Unstaked(msg.sender, stakeInfo.amount, reward);
    }
}
