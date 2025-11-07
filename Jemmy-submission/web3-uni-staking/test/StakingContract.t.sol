// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MockERC20.sol";
import "../src/StakingContract.sol";

contract StakingContractTest is Test {
    MockERC20 studyToken;
    StakingContract staking;
    address user = address(1);

    function setUp() public {
        studyToken = new MockERC20("StudyToken", "STUDY", 1000 ether);
        staking = new StakingContract(address(studyToken));
        studyToken.transfer(user, 100 ether);
        vm.prank(user);
        studyToken.approve(address(staking), 100 ether);
        studyToken.transfer(address(staking), 100 ether);
    }

    function testStakeAndUnstake() public {
        vm.prank(user);
        staking.stake(10 ether);
        vm.warp(block.timestamp + 8 days);
        vm.prank(user);
        staking.unstake();
        uint256 finalBalance = studyToken.balanceOf(user);
        assertEq(finalBalance, 101 ether);
    }

    function testUnstakeTooEarlyReverts() public {
        vm.prank(user);
        staking.stake(10 ether);

        vm.prank(user);
        vm.expectRevert("Too early to unstake");
        staking.unstake();
    }

    function testStakeZeroReverts() public {
        vm.prank(user);
        vm.expectRevert("Cannot stake zero");
        staking.stake(0);
    }

    function testDoubleStakeReverts() public {
        vm.prank(user);
        staking.stake(10 ether);

        vm.prank(user);
        vm.expectRevert("Already staking");
        staking.stake(5 ether);
    }

    function testMultipleUsersStakeAndUnstake() public {
        address user2 = address(2);
        studyToken.transfer(user2, 50 ether);
        vm.prank(user2);
        studyToken.approve(address(staking), 50 ether);

        vm.prank(user);
        staking.stake(10 ether);

        vm.prank(user2);
        staking.stake(20 ether);

        vm.warp(block.timestamp + 8 days);

        vm.prank(user);
        staking.unstake();
        assertEq(studyToken.balanceOf(user), 101 ether);

        vm.prank(user2);
        staking.unstake();
        assertEq(studyToken.balanceOf(user2), 52 ether); // 50 - 20 + 20 + 2 = 52
    }
}
