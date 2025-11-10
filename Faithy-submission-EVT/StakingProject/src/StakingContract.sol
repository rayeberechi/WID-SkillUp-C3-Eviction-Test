// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol"; // For owner features
import "openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol"; // For better security

// Inherit from Ownable and ReentrancyGuard
contract StakingContract is Ownable, ReentrancyGuard {
    IERC20 public studyToken;
    uint256 public constant STAKING_PERIOD = 60 seconds; 
    uint256 public constant REWARD_RATE = 10; 

    // Keep track of total funds to prevent rug pull
    uint256 public totalStaked;

    struct StakerInfo {
        uint256 amount;
        uint256 stakeTime;
    }

    mapping(address => StakerInfo) public stakers;

    constructor(address _tokenAddress) Ownable(msg.sender) {
        studyToken = IERC20(_tokenAddress);
    }

    // --- FIXED stake() function ---
    function stake(uint256 _amount) public nonReentrant {
        require(_amount > 0, "Staking: Amount must be > 0");
        require(msg.sender != address(0), "Staking: Cannot stake from zero address");

        studyToken.transferFrom(msg.sender, address(this), _amount);

        StakerInfo storage staker = stakers[msg.sender];

        // If they are staking for the first time, or adding to it
        staker.amount = staker.amount + _amount; 
        staker.stakeTime = block.timestamp; // Timer resets

        // Update the totalStaked amount
        totalStaked = totalStaked + _amount;
    }

    // --- FINAL FIXED unstake() function ---
    function unstake() public nonReentrant {
        StakerInfo storage staker = stakers[msg.sender];
        
        // --- CHECKS ---
        require(staker.amount > 0, "Staking: No stake found");
        require(block.timestamp >= staker.stakeTime + STAKING_PERIOD, "Staking: Period not over");

        uint256 stakeAmount = staker.amount;
        uint256 reward = calculateReward(msg.sender); // Calls the internal function

        // --- FINAL SECURITY FIX ---
        // This is the critical check your tutor was looking for.
        // It checks that the reward pool (balance - totalStaked) can cover the reward.
        // This prevents paying rewards with other users' staked principal.
        if (reward > 0) {
            require(studyToken.balanceOf(address(this)) - totalStaked >= reward, "Staking: Insufficient reward pool to pay reward");
        }

        // --- EFFECTS (Update state *before* transfer) ---
        totalStaked = totalStaked - stakeAmount;
        staker.amount = 0;
        staker.stakeTime = 0;

        // --- INTERACTIONS (Send funds last) ---
        // We can safely send both stake + reward in one transfer for gas efficiency
        studyToken.transfer(msg.sender, stakeAmount + reward);
    }

    // --- NEW: Function to let Owner add reward tokens ---
    function depositRewardTokens(uint256 _amount) public onlyOwner {
        require(_amount > 0, "Staking: Must add more than 0");
        studyToken.transferFrom(msg.sender, address(this), _amount);
    }

    // --- NEW: Function to let Owner withdraw *leftover* reward tokens ---
    function withdrawLeftoverRewardTokens() public onlyOwner {
        uint256 contractBalance = studyToken.balanceOf(address(this));
        
        // This is correct: Owner can only withdraw the *surplus* (rewards)
        require(contractBalance > totalStaked, "Staking: No leftover tokens");
        
        uint256 leftover = contractBalance - totalStaked;
        studyToken.transfer(owner(), leftover);
    }

    // --- FIXED calculateReward() ---
    function calculateReward(address _user) internal view returns (uint256) {
        StakerInfo storage staker = stakers[_user];
        
        // This check is 100% correct and necessary
        if (staker.amount == 0) return 0;

        uint256 timeStaked = block.timestamp - staker.stakeTime;
        // Simple 10% APR calculation
        return (staker.amount * REWARD_RATE * timeStaked) / (100 * 365 days);
    }
}