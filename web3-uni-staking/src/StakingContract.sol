// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract StakingContract {
    IERC20 public studyToken;

    struct Stake {
        uint256 amount;
        uint256 startTime;
        bool withdrawn;
    }

    mapping(address => Stake) public stakes;

    // Fixed staking period for simplicity
    uint256 public stakingPeriod = 7 days;

    // Flat reward rate, e.g. 10% (set as 10 for clarity)
    uint256 public rewardRate = 10;

    constructor(address _studyToken) {
        studyToken = IERC20(_studyToken);
    }

    // Stake STUDY tokens
    function stake(uint256 amount) external {
        require(amount > 0, "Cannot stake zero");
        require(stakes[msg.sender].amount == 0, "Already staking");

        // Transfer STUDY tokens to contract
        require(studyToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        stakes[msg.sender] = Stake({
            amount: amount,
            startTime: block.timestamp,
            withdrawn: false
        });
    }

    // Unstake and claim rewards after period
    function unstake() external {
        Stake storage userStake = stakes[msg.sender];
        require(userStake.amount > 0, "No stake found");
        require(!userStake.withdrawn, "Already withdrawn");
        require(block.timestamp >= userStake.startTime + stakingPeriod, "Too early to unstake");

        // Calculate reward
        uint256 reward = calculateReward(userStake.amount);

        // Mark as withdrawn
        userStake.withdrawn = true;

        // Transfer staked amount + reward back
        require(studyToken.transfer(msg.sender, userStake.amount + reward), "Transfer failed");
    }

    // Calculate reward (flat rate for simplicity)
    function calculateReward(uint256 amount) public view returns (uint256) {
        return (amount * rewardRate) / 100;
    }
}
