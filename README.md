# Ethereum Foundry 2026

## TODO

ERC 20, 741, 3643, 1400
Add formatting in git-precommit and CICD: <https://www.getfoundry.sh/forge/formatting#pre-commit-integration>

## Installation

Install Foundry: <https://getfoundry.sh/introduction/installation/>

Follow the doc: <https://getfoundry.sh/introduction/getting-started>

Use Sepolia network for testing smart contracts until 2027
```bash
forge install Openzeppelin/openzeppelin-contracts
forge remappings > remappings.txt
```

Fix VS Code linting: <https://ethereum.stackexchange.com/questions/142459/forge-std-test-sol-imported-and-working-but-vscode-marks-an-error>

## Environment Variables

Implement the .env file and run `source .env` before you run any package.json script that requires environment variables.

Make `.env` file from `.env.example`.

Then fill out the following in that .env file:

```env
MAINNET_RPC_URL=
SEPOLIA_RPC_URL=
GOERLI_RPC_URL=
ANVIL_RPC=http://127.0.0.1:8545
ETHERSCAN_API_KEY=

# Live Network Contracts
TOKEN_ADDR=
NFT_ADDR=
PoolAddressesProviderAaveV3Sepolia=

# Deploy Properties
MNEMONIC=
SIGNER=
PRIVATE_KEY=
ANVIL4=
ANVIL4_PRIVATE_KEY=
```

## Run Tests

```bash
forge test -vvv
forge test --match-path test/Counter.t.sol -vv
```

## Deploy Contracts

Deploy the USDX(ERC20), ERC721, and the ERC721 Sales smart contracts onto the Anvil Local Ethereum network:

```bash
forge script script/LocalDeploymt.s.sol:AnvilDeploymtScript --fork-url $ANVIL_RPC --broadcast -vvvv; echo erc721sales_makeabi
```

Copy the compiled Solidity ABI files with deployment contract addresses into this frontend project repository: `bun run erc721sales_makeabi
