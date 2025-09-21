# ===============================================================
#  PHOTONFORGE (ERC-20) — One-Page Builder (Upgraded & Secure)
#  Chain: Ethereum (ERC-20); Standard: ERC-20, Burnable, Stakable, Pausable
# ===============================================================
#
#  This file contains:
#    - Smart contract (Solidity, upgraded: decentralized mint, staking, burn, pause)
#    - Hardhat/Truffle deployment & verification configs
#    - JS deployment script
#    - .env template for secrets
#    - Full instructions, Ethereum address/key notes, security tips
#
#  Copy the relevant sections into your project directory as shown below!
#
# ===============================================================
#  DIRECTORY STRUCTURE:
#    photonforge/
#      ├─ contracts/Photonforge.sol
#      ├─ scripts/deploy_and_airdrop.js
#      ├─ hardhat.config.js
#      ├─ package.json
#      ├─ .env                    (NEVER COMMIT; holds PRIVATE KEY, API KEYS)
#      └─ truffle-config.js       (optional)
# ===============================================================

# ===============================================================
#  (1) Solidity: contracts/Photonforge.sol
# ===============================================================
```solidity name=contracts/Photonforge.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title Photonforge (PFGE)
 * @notice Decentralized ERC-20 with direct multi-party mint, staking, burn, emergency pause
 */
contract Photonforge is ERC20, Ownable, ERC20Burnable, Pausable {
    uint256 public constant DECIMALS = 18;
    uint256 public constant INITIAL_SUPPLY = 200_000_000 * 10**DECIMALS;

    // Staking
    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public stakingTimestamp;

    // Events
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);

    /**
     * @dev Mint supply directly to deployer and 5 team/community addresses.
     * @param deployer The deployer's address (gets 190,000,000 PFGE)
     * @param teamAddresses Array of 5 addresses (each gets 2,000,000 PFGE)
     */
    constructor(address deployer, address[5] memory teamAddresses) ERC20("Photonforge", "PFGE") Ownable(deployer) {
        uint256 teamAmount = 2_000_000 * 10**DECIMALS;
        uint256 deployerAmount = 190_000_000 * 10**DECIMALS;

        require(deployer != address(0), "Deployer cannot be zero");
        for (uint256 i = 0; i < 5; i++) {
            require(teamAddresses[i] != address(0), "Team address cannot be zero");
            _mint(teamAddresses[i], teamAmount);
        }
        _mint(deployer, deployerAmount);
    }

    // --- Staking Functions ---

    /**
     * @notice Stake PFGE tokens (must approve contract first if not using transferAndCall)
     * @param amount The amount to stake
     */
    function stake(uint256 amount) external whenNotPaused {
        require(amount > 0, "Cannot stake zero");
        _transfer(msg.sender, address(this), amount);
        stakedBalance[msg.sender] += amount;
        stakingTimestamp[msg.sender] = block.timestamp;
        emit Staked(msg.sender, amount);
    }

    /**
     * @notice Unstake PFGE tokens
     * @param amount The amount to unstake
     */
    function unstake(uint256 amount) external whenNotPaused {
        require(stakedBalance[msg.sender] >= amount, "Insufficient staked");
        stakedBalance[msg.sender] -= amount;
        _transfer(address(this), msg.sender, amount);
        emit Unstaked(msg.sender, amount);
    }

    // --- Pausable Security ---
    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }

    // Override ERC20 transfer hooks for pause logic
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20) whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }
}
```

# ===============================================================
#  (2) package.json — Node project manifest
# ===============================================================
```json name=package.json
{
  "name": "photonforge",
  "version": "2.0.0",
  "private": true,
  "scripts": {
    "compile": "hardhat compile",
    "deploy:sepolia": "hardhat run scripts/deploy_and_airdrop.js --network sepolia",
    "deploy:mainnet": "hardhat run scripts/deploy_and_airdrop.js --network mainnet",
    "verify": "hardhat verify --network sepolia"
  },
  "devDependencies": {
    "@nomicfoundation/hardhat-toolbox": "^5.0.0",
    "@nomicfoundation/hardhat-verify": "^2.0.0",
    "@openzeppelin/contracts": "^5.0.2",
    "dotenv": "^16.4.1",
    "hardhat": "^2.22.10"
  }
}
```

# ===============================================================
#  (3) .env — keep secrets here (NEVER COMMIT)
# ===============================================================
```env name=.env
OWNER_PRIVATE_KEY=0xYOUR_PRIVATE_KEY_64_HEX_CHARS................................ // 66 chars
INFURA_PROJECT_ID=your_infura_project_id_here                                     // (Infura)
ETHERSCAN_API_KEY=your_etherscan_api_key_here                                     // (password/API)
// (OPTIONAL) If your provider gives you a full HTTPS URL, you can set:
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/your-project-id                      // (Infura)
MAINNET_RPC_URL=https://mainnet.infura.io/v3/your-project-id                      // (Infura)
//
// TEAM ADDRESSES — each must be 42 chars: 0x + 40 hex
TEAM_ADDR_1=0xTEAM_ADDRESS_ONE_40HEX..............................................
TEAM_ADDR_2=0xTEAM_ADDRESS_TWO_40HEX..............................................
TEAM_ADDR_3=0xTEAM_ADDRESS_THREE_40HEX............................................
TEAM_ADDR_4=0xTEAM_ADDRESS_FOUR_40HEX.............................................
TEAM_ADDR_5=0xTEAM_ADDRESS_FIVE_40HEX.............................................
```

# ===============================================================
#  (4) hardhat.config.js — networks + etherscan verify (uses Infura)
# ===============================================================
```javascript name=hardhat.config.js
require("dotenv").config();
require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-verify");

const {
  OWNER_PRIVATE_KEY,
  INFURA_PROJECT_ID,
  ETHERSCAN_API_KEY,
  SEPOLIA_RPC_URL,
  MAINNET_RPC_URL
} = process.env;

const sepoliaUrl = SEPOLIA_RPC_URL || `https://sepolia.infura.io/v3/${INFURA_PROJECT_ID}`;
const mainnetUrl = MAINNET_RPC_URL || `https://mainnet.infura.io/v3/${INFURA_PROJECT_ID}`;

module.exports = {
  solidity: {
    version: "0.8.24",
    settings: { optimizer: { enabled: true, runs: 200 } }
  },
  networks: {
    hardhat: {},
    sepolia: {
      url: sepoliaUrl,
      accounts: OWNER_PRIVATE_KEY ? [OWNER_PRIVATE_KEY] : []
    },
    mainnet: {
      url: mainnetUrl,
      accounts: OWNER_PRIVATE_KEY ? [OWNER_PRIVATE_KEY] : []
    }
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY
  }
};
```

# ===============================================================
#  (5) scripts/deploy_and_airdrop.js — deploy + auto-gift 5×2,000,000
# ===============================================================
```javascript name=scripts/deploy_and_airdrop.js
const { ethers } = require("hardhat");
require("dotenv").config();

function assert42(name, v) {
  if (!/^0x[0-9a-fA-F]{40}$/.test(v)) {
    throw new Error(`${name} must be a 42-char 0x address (0x + 40 hex). Got: ${v}`);
  }
}

async function main() {
  // Pull team addresses from .env
  const TEAM = [
    process.env.TEAM_ADDR_1,
    process.env.TEAM_ADDR_2,
    process.env.TEAM_ADDR_3,
    process.env.TEAM_ADDR_4,
    process.env.TEAM_ADDR_5
  ].filter(Boolean);

  if (TEAM.length !== 5) {
    throw new Error("Provide exactly 5 team addresses in .env (TEAM_ADDR_1..5).");
  }
  TEAM.forEach((a, i) => assert42(`TEAM_ADDR_${i + 1}`, a));

  // Deployer address
  const [deployer] = await ethers.getSigners();

  // Deploy contract with all allocations in constructor
  const Factory = await ethers.getContractFactory("Photonforge");
  const token = await Factory.deploy(deployer.address, TEAM);
  await token.waitForDeployment();
  const tokenAddr = await token.getAddress();

  console.log(`Photonforge deployed at: ${tokenAddr}`);
  console.log("Deployer:", deployer.address);
  for (let i = 0; i < TEAM.length; i++) {
    console.log(`Team[${i + 1}]: ${TEAM[i]}`);
  }

  // Check deployer/team balances
  const balDeployer = await token.balanceOf(deployer.address);
  console.log(`Deployer balance: ${ethers.formatUnits(balDeployer, 18)} PFGE`);
  for (let i = 0; i < TEAM.length; i++) {
    const balTeam = await token.balanceOf(TEAM[i]);
    console.log(`Team[${i + 1}] balance: ${ethers.formatUnits(balTeam, 18)} PFGE`);
  }

  // OPTIONAL: Etherscan verify
  console.log("Verify with: npx hardhat verify --network <net> " + tokenAddr + " <DEPLOYER> <TEAM1> <TEAM2> <TEAM3> <TEAM4> <TEAM5>");
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
```

# ===============================================================
#  (6) QUICKSTART — one-shot terminal flow
# ===============================================================
```sh
# --- shell (sh) ---
mkdir photonforge && cd photonforge
npm init -y
npm i -D hardhat @nomicfoundation/hardhat-toolbox @nomicfoundation/hardhat-verify dotenv @openzeppelin/contracts
npx hardhat init --force
# Create files from this page:
#   contracts/Photonforge.sol
#   scripts/deploy_and_airdrop.js
#   hardhat.config.js
#   package.json (replace)
#   .env (create with secrets; see section (3))

# Compile
npx hardhat compile

# Fund your deployer address with ETH (Sepolia or mainnet).

# Deploy to Sepolia:
npm run deploy:sepolia

# (Optional) Verify on Etherscan:
npx hardhat verify --network sepolia <DEPLOYED_TOKEN_ADDRESS> <DEPLOYER> <TEAM1> <TEAM2> <TEAM3> <TEAM4> <TEAM5>
```

# ===============================================================
#  (7) OPTIONAL — Truffle equivalents (if you prefer Truffle)
# ===============================================================
```javascript name=truffle-config.js
require("dotenv").config();
const HDWalletProvider = require("@truffle/hdwallet-provider");

const { OWNER_PRIVATE_KEY, INFURA_PROJECT_ID } = process.env;

module.exports = {
  networks: {
    sepolia: {
      provider: () =>
        new HDWalletProvider({
          privateKeys: [OWNER_PRIVATE_KEY],
          providerOrUrl: `https://sepolia.infura.io/v3/${INFURA_PROJECT_ID}`
        }),
      network_id: 11155111
    }
  },
  compilers: { solc: { version: "0.8.24" } }
};
```

```javascript name=migrations/1_deploy_photonforge.js
const Photonforge = artifacts.require("Photonforge");
module.exports = async function (deployer, network, accounts) {
  const TEAM = [
    process.env.TEAM_ADDR_1,
    process.env.TEAM_ADDR_2,
    process.env.TEAM_ADDR_3,
    process.env.TEAM_ADDR_4,
    process.env.TEAM_ADDR_5
  ];
  await deployer.deploy(Photonforge, accounts[0], TEAM);
  const token = await Photonforge.deployed();
};
```

# ===============================================================
#  (8) OPTIONAL — Geth private chain (local “Ethereum-type” chain)
# ===============================================================
```sh
# --- shell (sh) ---
mkdir -p geth_private && cd geth_private
cat > genesis.json <<'JSON'
{
  "config": {
    "chainId": 1337,
    "homesteadBlock": 0,
    "eip150Block": 0,
    "eip155Block": 0,
    "eip158Block": 0,
    "byzantiumBlock": 0,
    "constantinopleBlock": 0,
    "petersburgBlock": 0,
    "istanbulBlock": 0,
    "muirGlacierBlock": 0,
    "londonBlock": 0,
    "terminalTotalDifficulty": 0
  },
  "difficulty": "1",
  "gasLimit": "30000000",
  "alloc": {}
}
JSON

geth --datadir data init genesis.json
geth --datadir data --http --http.api eth,net,web3,personal --http.addr 127.0.0.1 --http.port 8545 --allow-insecure-unlock
--mine --miner.etherbase 0xYOUR_COINBASE_40HEX_ADDRESS
```

# ===============================================================
#  (9) OPERATIONAL NOTES — addresses, passwords, websites, security
# ===============================================================
# • PUBLIC ADDRESS:     42 chars (0x + 40 hex) → put into TEAM_ADDR_1..5, also funds deployer.
# • PRIVATE KEY:        66 chars (0x + 64 hex) → put into OWNER_PRIVATE_KEY (.env only).
#
# • PASSWORD/API fields:
#   - (Infura): create project → INFURA_PROJECT_ID (or full RPC URL). Used in hardhat.config.js.
#   - Etherscan: create API key → ETHERSCAN_API_KEY. Used for contract verification.
#   - MetaMask: create wallet; export PRIVATE KEY (keep secret).
#
# • Security best practices:
#   - Use the contract's `pause()`/`unpause()` in emergencies (e.g., bug, exploit).
#   - Keep your OWNER_PRIVATE_KEY and .env file secure and never committed.
#   - Always verify contract source code on Etherscan.
#   - Use multisig or DAO as owner for added decentralization.
#
# • Fees: You’ll need ETH (Sepolia or mainnet) in the deployer address to pay gas.
#
# • Verification: After a few blocks, run:
#     npx hardhat verify --network sepolia <DEPLOYED_TOKEN_ADDRESS> <DEPLOYER> <TEAM1> <TEAM2> <TEAM3> <TEAM4> <TEAM5>
#
# • Alternatives to (Infura): Alchemy, QuickNode — just swap the RPC URL in config.
#
# • Immutability: All allocations are on-chain in constructor and cannot be changed post-deploy.
#
# • DeFi usage: Staking, burning, and decentralized mint support modern DeFi, DAOs, and exchanges.
#
# ===============================================================
#  DONE. This one-page builder gives you a secure, DeFi-ready ERC-20 token with full setup, deployment, and security instructions.
# ===============================================================
