// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/StakingContract.sol";
import "../src/StudyToken.sol";

contract StakingContractTest is Test {
    StakingContract public stakingContract;
    StudyToken public studyToken;

    address user1 = vm.addr(1); // A fake test user
    uint256 stakeAmount = 100 * 10**18; // 100 tokens

    function setUp() public {
        // 1. Deploy the token (we become the 'owner' in this test)
        studyToken = new StudyToken();

        // 2. Deploy the staking contract, telling it the token's address
        stakingContract = new StakingContract(address(studyToken));

        // 3. Give our test user 1000 tokens
        studyToken.transfer(user1, 1000 * 10**18);

        // 4. Send the Staking Contract 500k tokens to pay out rewards
        studyToken.transfer(address(stakingContract), 500_000 * 10**18);
    }

    // Test 1: Can a user stake?
    function testUserCanStake() public {
        // Switch to being 'user1'
        vm.startPrank(user1);

        // User1 approves the staking contract to spend 100 tokens
        studyToken.approve(address(stakingContract), stakeAmount);
        
        // User1 calls stake()
        stakingContract.stake(stakeAmount);
        
        // Check: Is the user's staked balance now 100?
        (uint256 amount, ) = stakingContract.stakers(user1);
        assertEq(amount, stakeAmount);

        // Check: Did the contract receive the 100 tokens?
        assertEq(studyToken.balanceOf(address(stakingContract)), (500_000 * 10**18) + stakeAmount);

        vm.stopPrank();
    }

    // Test 2: Does unstaking FAIL before the time is up?
    // --- THIS LINE IS FIXED ---
    function test_RevertIf_UnstakeBeforePeriod() public {
    // --------------------------
        // Stake first (like in Test 1)
        vm.startPrank(user1);
        studyToken.approve(address(stakingContract), stakeAmount);
        stakingContract.stake(stakeAmount);
        
        // Expect the *next command* to fail with this *exact* error message
        vm.expectRevert("Staking period not over");
        stakingContract.unstake();

        vm.stopPrank();
    }

    // Test 3: Can a user unstake AFTER the time is up?
    function testUserCanUnstakeAfterPeriod() public {
        // Stake first
        vm.startPrank(user1);
        studyToken.approve(address(stakingContract), stakeAmount);
        stakingContract.stake(stakeAmount);

        // --- TIME TRAVEL ---
        // Fast-forward the blockchain clock by 61 seconds (1 sec past the period)
        vm.warp(block.timestamp + 61 seconds);
        // -------------------

        uint256 expectedReward = stakingContract.calculateReward(user1);

        // Now, unstake
        stakingContract.unstake();

        // Check: Did the user get their original 100 tokens back?
        // (They started with 1000, staked 100 (so 900), now get 100 + reward back)
        uint256 expectedBalance = (900 * 10**18) + stakeAmount + expectedReward;
        assertEq(studyToken.balanceOf(user1), expectedBalance);

        // Check: Is the user's stake info deleted?
        (uint256 amountAfter, ) = stakingContract.stakers(user1);
        assertEq(amountAfter, 0);

        vm.stopPrank();
    }
}