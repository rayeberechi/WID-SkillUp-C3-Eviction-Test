// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/StakingContract.sol";
import "../src/StudyToken.sol";

contract StakingContractTest is Test {
    StakingContract public stakingContract;
    StudyToken public studyToken;

    // Test Users
    address owner; // This will be us, the deployer
    address user1 = vm.addr(1);
    address user2 = vm.addr(2);

    function setUp() public {
        // Set the 'owner' to this test contract's address
        owner = address(this);
        
        // 1. Deploy the token
        studyToken = new StudyToken();

        // 2. Deploy the staking contract (we are automatically the owner)
        stakingContract = new StakingContract(address(studyToken));

        // 3. Give tokens to our test users
        studyToken.transfer(user1, 1000 * 10**18);
        studyToken.transfer(user2, 1000 * 10**18);

        // 4. Fund the reward pool *as the owner*
        uint256 fundAmount = 500_000 * 10**18;
        // The owner (this test) already has tokens from the StudyToken constructor
        // We just need to approve and deposit
        studyToken.approve(address(stakingContract), fundAmount);
        stakingContract.depositRewardTokens(fundAmount);
    }

    // --- Test 1: Can a user stake? ---
    function test_Stake_UserCanStake() public {
        uint256 stakeAmount = 100 * 10**18;
        
        vm.startPrank(user1);
        studyToken.approve(address(stakingContract), stakeAmount);
        stakingContract.stake(stakeAmount);
        vm.stopPrank();

        // Check: Is the staker's info correct?
        (uint256 amount, uint256 stakeTime) = stakingContract.stakers(user1);
        assertEq(amount, stakeAmount, "Stake amount is incorrect");
        assertEq(stakeTime, block.timestamp, "Stake time is incorrect");

        // Check: Is the totalStaked correct?
        assertEq(stakingContract.totalStaked(), stakeAmount, "Total staked is incorrect");
    }

    // --- Test 2: Can a user "top up" their stake? ---
    function test_Stake_CanTopUp() public {
        uint256 firstStake = 100 * 10**18;
        uint256 secondStake = 50 * 10**18;

        // First stake
        vm.startPrank(user1);
        studyToken.approve(address(stakingContract), firstStake + secondStake); // Approve total
        stakingContract.stake(firstStake);
        vm.stopPrank();

        uint256 firstStakeTime = block.timestamp;

        // Fast forward 10 seconds
        vm.warp(block.timestamp + 10 seconds);

        // Second stake (top-up)
        vm.startPrank(user1);
        stakingContract.stake(secondStake);
        vm.stopPrank();
        
        // Check: Did the amount add up correctly?
        (uint256 amount, uint256 stakeTime) = stakingContract.stakers(user1);
        assertEq(amount, firstStake + secondStake, "Top-up amount is incorrect");
        
        // Check: Did the timer reset?
        assertEq(stakeTime, block.timestamp, "Stake time did not reset");
        assertEq(stakeTime, firstStakeTime + 10 seconds, "Stake time is wrong");
    }

    // --- Test 3: Does unstaking FAIL before time is up? ---
    function test_Unstake_RevertIf_PeriodNotOver() public {
        vm.startPrank(user1);
        studyToken.approve(address(stakingContract), 100 * 10**18);
        stakingContract.stake(100 * 10**18);
        
        // Don't time-travel
        
        vm.expectRevert("Staking: Period not over");
        stakingContract.unstake();
        vm.stopPrank();
    }

    // --- Test 4: Can a user unstake AFTER time is up? ---
    function test_Unstake_Success() public {
        uint256 stakeAmount = 100 * 10**18;

        vm.startPrank(user1);
        studyToken.approve(address(stakingContract), stakeAmount);
        stakingContract.stake(stakeAmount);
        vm.stopPrank();
        
        // Time travel past the staking period
        vm.warp(block.timestamp + 61 seconds);

        // Calculate expected reward *before* unstaking
        uint256 expectedReward = (stakeAmount * 10 * 61) / (100 * 365 days);

        vm.startPrank(user1);
        stakingContract.unstake();
        vm.stopPrank();

        // Check: Did user get their principal + reward back?
        uint256 expectedBalance = (1000 * 10**18) + expectedReward; // 1000 (start) - 100 (stake) + 100 (unstake) + reward
        assertEq(studyToken.balanceOf(user1), expectedBalance);

        // Check: Is their stake info deleted?
        (uint256 amount, ) = stakingContract.stakers(user1);
        assertEq(amount, 0);

        // Check: Did totalStaked go down?
        assertEq(stakingContract.totalStaked(), 0);
    }
    
    // --- Test 5: Does unstake FAIL if reward pool is empty? ---
    function test_Unstake_RevertIf_NoRewardPool() public {
        // user1 stakes 100 tokens
        vm.startPrank(user1);
        studyToken.approve(address(stakingContract), 100 * 10**18);
        stakingContract.stake(100 * 10**18);
        vm.stopPrank();

        // Owner (us) withdraws ALL reward tokens
        // This leaves 100 (staked) tokens in the contract
        stakingContract.withdrawLeftoverRewardTokens();
        assertEq(studyToken.balanceOf(address(stakingContract)), 100 * 10**18);

        // Now, the contract balance = totalStaked. The reward pool is 0.
        
        // Time travel
        vm.warp(block.timestamp + 61 seconds);

        // user1 tries to unstake. They are owed a reward, but pool is empty.
        vm.startPrank(user1);
        vm.expectRevert("Staking: Insufficient reward pool to pay reward");
        stakingContract.unstake();
        vm.stopPrank();
    }

    // --- Test 6: Can the owner withdraw leftover funds? ---
    // --- THIS TEST IS NOW FIXED ---
    function test_Owner_CanWithdrawLeftover() public {
        // 1. Get the owner's balance *before* withdrawing
        uint256 ownerBalanceBefore = studyToken.balanceOf(owner);

        // 2. Get the contract's balance *before* withdrawing
        uint256 contractBalanceBefore = studyToken.balanceOf(address(stakingContract));
        assertEq(contractBalanceBefore, 500_000 * 10**18, "Contract balance is not the reward pool amount");

        // 3. Owner calls withdraw
        stakingContract.withdrawLeftoverRewardTokens();

        // 4. Check: Owner's balance should go up by the amount in the contract
        uint256 ownerBalanceAfter = studyToken.balanceOf(owner);
        assertEq(ownerBalanceAfter, ownerBalanceBefore + contractBalanceBefore, "Owner did not receive correct amount");
        
        // 5. Check: Contract should be empty
        assertEq(studyToken.balanceOf(address(stakingContract)), 0, "Contract is not empty");
    }

    // --- Test 7: Does withdraw FAIL if there are no leftover funds? ---
    function test_Owner_RevertIf_NoLeftover() public {
        // user1 stakes 100 tokens
        vm.startPrank(user1);
        studyToken.approve(address(stakingContract), 100 * 10**18);
        stakingContract.stake(100 * 10**18); // totalStaked is now 100
        vm.stopPrank();
        
        // Owner withdraws the leftover 500,000
        stakingContract.withdrawLeftoverRewardTokens();
        
        // Now, balance (100) == totalStaked (100). There are 0 leftover.
        
        // Owner tries to withdraw again
        vm.expectRevert("Staking: No leftover tokens");
        stakingContract.withdrawLeftoverRewardTokens();
    }
}