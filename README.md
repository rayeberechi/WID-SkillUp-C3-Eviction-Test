# SimpleBank

SimpleBank is a small Hardhat example project that implements a minimal Solidity "bank" contract. It demonstrates the common developer workflow:

- write a contract in `contracts/`
- write tests in `test/`
- compile with Hardhat and inspect artifacts in `artifacts/`
- use simple deployment scripts in `scripts/`

This repository is intended for learning and testing only — it is not production-ready.

Contents
 - `contracts/SimpleBank.sol` — the bank contract (deposit, withdraw, balances)
 - `test/SimpleBank.js` — JavaScript tests using Hardhat + ethers.js
 - `scripts/deploy.js` — simple deployment script
 - `hardhat.config.js` — Hardhat configuration

Prerequisites
 - Node.js (>= 16 recommended)
 - npm or yarn

Quick start

1. Install dependencies

```powershell
cd SimpleBank
npm install
```

2. Run tests

```powershell
npx hardhat test
```

3. Run a local node (optional)

```powershell
npx hardhat node
```

4. Deploy to a network (example: Hardhat local or testnet)

```powershell
# Local (uses the first Hardhat node account)
npx hardhat run scripts/deploy.js --network localhost

# To deploy to a testnet, set RPC/keys in your hardhat config or use env vars
npx hardhat run scripts/deploy.js --network goerli
```

Contract details

Open `contracts/SimpleBank.sol` to inspect the public API. The contract includes functions to:
- deposit Ether
- withdraw Ether
- check account balance

Tests

See `test/SimpleBank.js` for simple unit tests. Tests use Hardhat's built-in network and ethers.js. Run them with `npx hardhat test`.

Artifacts

Build artifacts and ABIs are in the `artifacts/` folder after compilation. The compiled JSON for `SimpleBank.sol` is at `artifacts/contracts/SimpleBank.sol/SimpleBank.json`.

Notes and next steps

- This project is intentionally small — consider extending it with events, access control, and more tests to learn more.
- Do not use this contract as-is in production. It's for educational purposes.

License

Check the repository root for license information.


# Study-Project — StudyTokenStaking

This repository is a Foundry-based Solidity project that implements a token staking contract used for study/demo purposes. It contains source code, tests, scripts, and broadcasted runs produced by `forge`.

Key files
 - `src/StudyTokenStaking.sol` — main staking contract
 - `script/DeployStudyTokenStaking.s.sol` — Foundry deployment script
 - `test/StudyTokenStaking.t.sol` — Solidity tests (Forge)
 - `broadcast/` — recorded broadcast runs (useful to inspect prior deployments)

Prerequisites
 - Foundry (forge, anvil, cast). Install instructions: https://book.getfoundry.sh/
 - Alternatively: `curl -L https://foundry.paradigm.xyz | bash` then `foundryup`

Quick start

1. Build

```bash
cd Study-Project
forge build
```

2. Run tests

```bash
forge test
```

3. Run anvil (local node)

```bash
anvil
```

4. Deploy with a script and broadcast to record the run

```bash
# Example: run the DeployStudyTokenStaking script and record the broadcast
forge script script/DeployStudyTokenStaking.s.sol:DeployStudyTokenStaking --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> --broadcast
```

Notes

- Tests are written for Forge and live in the `test/` directory. Use `forge test -vv` for verbose output.
- The `broadcast/` directory stores JSON runs emitted by `forge` when scripts are run with `--broadcast`. These are handy for auditing what happened during a deployment.
- If you need to interact with deployed contracts, use `cast` or write small scripts using `forge script`.

Troubleshooting

- If you get compiler errors, run `forge update` and ensure remappings (if any) are correct.
- Use `forge fmt` to format code and `forge snapshot` for gas snapshots.

License

Check repository root files for license det
