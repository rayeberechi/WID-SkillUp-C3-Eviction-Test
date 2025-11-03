// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract StakingContract {
    IERC20 public studyToken;

    // We set a 60 second (1 minute) staking period for easy testing
    uint256 public constant STAKING_PERIOD = 60 seconds; 

    // We set a 10% Annual Reward Rate (APR)
    uint256 public constant REWARD_RATE = 10; 

    // A "box" to hold info about each staker
    struct StakerInfo {
        uint256 amount;
        uint256 stakeTime;
    }

    // A "database" (mapping) linking a staker's address to their "box" of info
    mapping(address => StakerInfo) public stakers;

    constructor(address _tokenAddress) {
        studyToken = IERC20(_tokenAddress);
    }

    // Function to stake tokens
    function stake(uint256 _amount) public {
        require(_amount > 0, "Amount must be > 0");
        require(stakers[msg.sender].amount == 0, "Already staked");

        // 1. Pull the tokens from the user into this contract
        // (This requires the user to 'approve' first!)
        studyToken.transferFrom(msg.sender, address(this), _amount);

        // 2. Save the user's info
        stakers[msg.sender] = StakerInfo({
            amount: _amount,
            stakeTime: block.timestamp
        });
    }

    // A "view" function to calculate pending rewards
    function calculateReward(address _user) public view returns (uint256) {
        StakerInfo storage staker = stakers[_user];
        if (staker.amount == 0) return 0;

        // Simple Interest: (Principal * Rate * Time) / (100 * 365 days)
        // We use 100 for the 10% rate.
        uint256 timeStaked = block.timestamp - staker.stakeTime;
        return (staker.amount * REWARD_RATE * timeStaked) / (100 * 365 days);
    }

    // Function to unstake tokens and claim rewards
    function unstake() public {
        StakerInfo storage staker = stakers[msg.sender];
        require(staker.amount > 0, "No stake found");

        // Check if the 60-second period has passed
        require(block.timestamp >= staker.stakeTime + STAKING_PERIOD, "Staking period not over");

        uint256 stakeAmount = staker.amount;
        uint256 reward = calculateReward(msg.sender);

        // 1. Delete the user's info first to prevent re-entrancy attacks
        delete stakers[msg.sender];

        // 2. Send their original tokens back
        studyToken.transfer(msg.sender, stakeAmount);

        // 3. Send their rewards (if any)
        if (reward > 0) {
            // This assumes the contract *has* tokens to pay rewards.
            // For a real app, we'd need a separate reward pool.
            // For this test, we just send from the contract's balance.
            studyToken.transfer(msg.sender, reward);
        }
    }
}