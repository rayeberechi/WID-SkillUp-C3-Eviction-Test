require("dotenv").config();
const { ethers } = require("hardhat");

async function main() {
  const SimpleBank = await ethers.getContractFactory("SimpleBank");
  console.log("Deploying SimpleBank...");

  const simpleBank = await SimpleBank.deploy();
  await simpleBank.waitForDeployment();

  console.log("SimpleBank deployed to:", await simpleBank.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
