require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config(); // This is new

const { BASE_SEPOLIA_RPC_URL, PRIVATE_KEY } = process.env;

module.exports = {
  solidity: "0.8.28", // This is the compiler it downloaded
  networks: { // This section is new
    baseSepolia: {
      url: BASE_SEPOLIA_RPC_URL || "",
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [],
    },
  },
};