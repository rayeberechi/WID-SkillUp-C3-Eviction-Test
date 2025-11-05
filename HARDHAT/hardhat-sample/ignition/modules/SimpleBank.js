const {buildModule } = require("@nomicfoundation/hardhat-ignition/modules");
const SimpleBankModule = buildModule("SimpleBankModule", (m) => {
    console.log("Deploying SimpleBank Contract...");

    const simpleBank = m.contract("SimpleBank", []);
  return { simpleBank };
})