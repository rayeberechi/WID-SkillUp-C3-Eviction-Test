const hre = require("hardhat");

async function main() {
  const simpleBank = await hre.ethers.deployContract("SimpleBank");
  await simpleBank.waitForDeployment();
  console.log(`SimpleBank deployed to: ${simpleBank.target}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});