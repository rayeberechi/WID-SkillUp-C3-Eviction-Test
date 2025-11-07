// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {StudyToken, Staking} from "../src/Web3Uni.sol";

contract Web3UniScript is Script {
    function run() external {
        // Load private key from environment variable
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Start broadcasting (sends actual transactions)
        vm.startBroadcast(deployerPrivateKey);

        // 1️⃣ Deploy StudyToken
        uint256 initialSupply = 1_000_000; // 1 million tokens
        StudyToken studyToken = new StudyToken(initialSupply);
        console.log("StudyToken deployed at:", address(studyToken));

        // 2️⃣ Deploy Staking Contract
        uint256 stakingDuration = 30 days; // Lock period
        uint256 rewardRate = 10; // 10% reward
        Staking staking = new Staking(address(studyToken), stakingDuration, rewardRate);
        console.log("Staking contract deployed at:", address(staking));

        // 3️⃣ Transfer tokens to staking contract (for rewards)
        uint256 rewardPool = 100_000 * 1e18; // Optional: reserve reward tokens
        studyToken.transfer(address(staking), rewardPool);
        console.log("Reward pool funded with:", rewardPool, "tokens");

        vm.stopBroadcast();
    }
}
