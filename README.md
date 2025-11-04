# SimpleBank

SimpleBank is a small Hardhat example project that implements a minimal Solidity "bank" contract. It demonstrates the common developer workflow:

write a contract in contracts/

write tests in test/

compile with Hardhat and inspect artifacts in artifacts/

use simple deployment scripts in scripts/

This repository is intended for learning and testing only — it is not production-ready.

## Contents

```

contracts/SimpleBank.sol — the bank contract (deposit, withdraw, balances)
test/SimpleBank.js — JavaScript tests using Hardhat + ethers.js
scripts/deploy.js — simple deployment script
hardhat.config.js — Hardhat configuration

```

## Prerequisites

Node.js (>= 16 recommended)
npm or yarn

## Quick start

Install dependencies
```
cd SimpleBank
npm install
```

Run tests
```
npx hardhat test
```

Run a local node (optional)
```
npx hardhat node
```

Deploy to a network (example: Hardhat local or testnet)

# Local (uses the first Hardhat node account)
```
npx hardhat run scripts/deploy.js --network localhost
```

# To deploy to a testnet, set RPC/keys in your hardhat config or use env vars
```
npx hardhat run scripts/deploy.js --network goerli
```

Contract details

Open contracts/SimpleBank.sol to inspect the public API. The contract includes functions to:

deposit Ether

withdraw Ether

check account balance

Tests

See test/SimpleBank.js for simple unit tests. Tests use Hardhat's built-in network and ethers.js. Run them with 
```
npx hardhat test.
```

Artifacts

Build artifacts and ABIs are in the artifacts/ folder after compilation. 
The compiled JSON for SimpleBank.sol is at artifacts/contracts/SimpleBank.sol/SimpleBank.json.

Notes and next steps

This project is intentionally small — consider extending it with events, access control, and more tests to learn more.
Do not use this contract as-is in production. It's for educational purposes.
License

Check the repository root for license information.

