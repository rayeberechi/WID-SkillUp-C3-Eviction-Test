async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contract with: ", deployer.address);
  const Bank = await ethers.getContractFactory("SimpleBank");
  const bank = await Bank.deploy();
  await bank.waitForDeployment();
  console.log("SimpleBank deployed to:", bank.target);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
