// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import 'forge-std/Script.sol';
import '../src/StudyTokenStaking.sol';

contract DeployStudyTokenStaking is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint('PRIVATE_KEY');
        address studyTokenAddress = vm.envAddress('STUDY_TOKEN_ADDRESS');
        uint256 rewardRate = 1000; // 10% apr

        vm.startBroadcast(deployerPrivateKey);
        new StudyTokenStaking(IERC20(studyTokenAddress), rewardRate);
        vm.stopBroadcast();
    }
}