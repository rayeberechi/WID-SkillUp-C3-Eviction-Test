// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Web3Uni.sol";  

contract StakingTest is Test {
    StudyToken token;
    Staking staking;
    address user = address(0x123);
    uint256 constant INITIAL_SUPPLY = 10000 ether;
    uint256 constant STAKE_AMOUNT = 100 ether;
    uint256 constant REWARD_RATE = 10; // 10%
    uint256 constant DURATION = 1 days;

    function setUp() public {
    token = new StudyToken(10000);
    staking = new Staking(address(token), DURATION, REWARD_RATE);

    // Give staking contract enough tokens for rewards
    token.transfer(address(staking), 1000 ether);

    // Give user some tokens to stake
    token.transfer(user, 1000 ether);

    vm.startPrank(user);
    token.approve(address(staking), type(uint256).max);
    vm.stopPrank();
}

 

   
    function testStake() public {
        vm.startPrank(user);
        staking.stake(STAKE_AMOUNT);
        vm.stopPrank();

        (uint256 amount,, bool withdrawn) = staking.stakes(user);
        assertEq(amount, STAKE_AMOUNT, "Stake amount incorrect");
        assertFalse(withdrawn, "Stake should not be withdrawn yet");
    }

  
function test_RevertIf_StakeZero() public {
    vm.startPrank(user);
    vm.expectRevert(); // expecting revert
    staking.stake(0);
    vm.stopPrank();
}


function test_RevertIf_StakeTwice() public {
    vm.startPrank(user);
    staking.stake(100 ether);
    vm.expectRevert(); // expecting revert on second stake
    staking.stake(200 ether);
    vm.stopPrank();
}


    
    function testRewardCalculation() public {
        vm.startPrank(user);
        staking.stake(STAKE_AMOUNT);
        vm.warp(block.timestamp + DURATION); // move time forward
        uint256 reward = staking.calculateReward(user);
        vm.stopPrank();

        assertEq(reward, (STAKE_AMOUNT * REWARD_RATE) / 100, "Incorrect reward");
    }

 
    function testCannotUnstakeEarly() public {
        vm.startPrank(user);
        staking.stake(STAKE_AMOUNT);
        vm.expectRevert("Lock period not over");
        staking.unstake();
        vm.stopPrank();
    }


    function testUnstakeAfterDuration() public {
        vm.startPrank(user);
        staking.stake(STAKE_AMOUNT);
        vm.warp(block.timestamp + DURATION); // simulate waiting period
        staking.unstake();
        vm.stopPrank();

        uint256 expectedBalance = 1000 ether + (STAKE_AMOUNT * REWARD_RATE) / 100;
        assertEq(token.balanceOf(user), expectedBalance, "Balance after unstake incorrect");

        (,, bool withdrawn) = staking.stakes(user);
        assertTrue(withdrawn, "Stake should be marked withdrawn");
    }

    function testCannotUnstakeTwice() public {
        vm.startPrank(user);
        staking.stake(STAKE_AMOUNT);
        vm.warp(block.timestamp + DURATION);
        staking.unstake();

        vm.expectRevert("Already withdrawn");
        staking.unstake();
        vm.stopPrank();
    }
}
