// ===============================================================
//  PHOTONFORGE (ERC-20) — One-Page A→Z Builder
//  Chain: Ethereum (ERC-Blockchain); Standard: ERC-20
// import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
//  contract Photonforge is ERC20, Ownable, ERC20Burnable {
//Supply: 200,000,000 PFGE (18 decimals)
contract Photonforge is ERC20, Ownable {contract Photonforge is ERC20, Ownable, ERC20Burnable {
//1: pragma solidity ^0.8.24;
    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public stakingTimestamp;
2:import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
3:import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
4: import "@openzeppelin/contracts/access/Ownable.sol";
    // Stake tokens
    function stake(uint256 amount) public {
        require(amount > 0, "Cannot stake zero");
        _transfer(msg.sender, address(this), amount);
        stakedBalance[msg.sender] += amount;
        stakingTimestamp[msg.sender] = block.timestamp;
    }

    // Unstake tokens
    function unstake(uint256 amount) public {
        require(stakedBalance[msg.sender] >= amount, "Insufficient staked");
        stakedBalance[msg.sender] -= amount;
        _transfer(address(this), msg.sender, amount);
    }
5:import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol"; // [INSERTED HERE]
6:    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public stakingTimestamp;

    // Stake tokens
    function stake(uint256 amount) public {
        require(amount > 0, "Cannot stake zero");
        _transfer(msg.sender, address(this), amount);
        stakedBalance[msg.sender] += amount;
        stakingTimestamp[msg.sender] = block.timestamp;
    }

    // Unstake tokens
    function unstake(uint256 amount) public {
        require(stakedBalance[msg.sender] >= amount, "Insufficient staked");
        stakedBalance[msg.sender] -= amount;
        _transfer(address(this), msg.sender, amount);
    }
7: contract Photonforge is ERC20, Ownable, ERC20Burnable {                   // [MODIFIED LINE]
8:     uint256 public constant INITIAL_SUPPLY = 200_000_000 * 10**18; // 200M PFGE
9:
10:    constructor() ERC20("Photonforge", "PFGE") Ownable(msg.sender) {
11:        _mint(msg.sender, INITIAL_SUPPLY); // Mint all to deployer/owner
12:    }
13:
14:    // (Optional) owner utilities could go here (pause, burn, etc.). Keeping lean.
15: }
//  Post-deploy: Auto-gift 5 team addresses, 2,000,000 PFGE each
// ===============================================================
//
//  You’ll see multiple languages in one page (.sol, .js, .sh, .json)
//  with clear “DO THIS NEXT” markers. Keep this whole page as notes,
//  then copy each labeled block into the correct project file.
//
//  ──────────────────────────────────────────────────────────────
//  0x LENGTH CHEATSHEET (Ethereum):
//    • Externally Owned Account (EOA) ADDRESS: 42 chars  = "0x" + 40 hex
//    • PRIVATE KEY (never commit):         66 chars  = "0x" + 64 hex
//    • TX HASH / KECCAK256 hex:            66 chars  = "0x" + 64 hex
//  (You’ll “need two 0x” in practice: one PUBLIC address (42 chars)
//   and one PRIVATE KEY (66 chars). Keep the private key in .env only.)
//  ──────────────────────────────────────────────────────────────
//
//  EXTERNAL SITES / ACCOUNTS NEEDED (password/API areas labeled):
//    • Wallet: MetaMask (create your address; export PRIVATE KEY — 66 chars)
//    • RPC Provider: (Infura) or Alchemy/QuickNode
//        (Create project; note PROJECT_ID / HTTPS URL)   (password/API area)
//    • Etherscan account + API key for verification       (password/API area)
//    • Optional: GitHub (repo), NPM (node), and Geth (local chain)
//  ──────────────────────────────────────────────────────────────
//
//  DIRECTORY (after you split files):
//    photonforge/
//      ├─ contracts/Photonforge.sol
//      ├─ scripts/deploy_and_airdrop.js
//      ├─ hardhat.config.js
//      ├─ package.json
//      ├─ .env                    (NEVER COMMIT; holds PRIVATE KEY, API KEYS)
//      └─ truffle-config.js       (optional, if you prefer Truffle)
//
// ===============================================================
//  (1) Solidity: contracts/Photonforge.sol
// ===============================================================
// File: contracts/Photonforge.sol  (Solidity ^0.8.24)
pragma solidity ^0.8.24;

// Using OpenZeppelin (battle-tested) for ERC20 + Ownable
// npm i @openzeppelin/contracts
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Photonforge is ERC20, Ownable {
    // Decimals default to 18 in ERC20, so total supply must scale by 10**18
    uint256 public constant INITIAL_SUPPLY = 200_000_000 * 10**18; // 200M PFGE

    constructor() ERC20("Photonforge", "PFGE") Ownable(msg.sender) {
        _mint(msg.sender, INITIAL_SUPPLY); // Mint all to deployer/owner
    }

    // (Optional) owner utilities could go here (pause, burn, etc.). Keeping lean.
}

// ===============================================================
//  (2) package.json (minimal) — Node project manifest
// ===============================================================
// File: package.json
{
  "name": "photonforge",
  "version": "1.0.0",
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

// ===============================================================
//  (3) .env — keep secrets here (NEVER COMMIT)
// ===============================================================
// File: .env
// Replace the placeholders with your values. Do not include quotes.
// OWNER_PRIVATE_KEY must be your 66-char hex (0x + 64 hex).
OWNER_PRIVATE_KEY=0xYOUR_PRIVATE_KEY_64_HEX_CHARS................................ // 66 chars
INFURA_PROJECT_ID=your_infura_project_id_here                                     // (Infura)
ETHERSCAN_API_KEY=your_etherscan_api_key_here                                     // (password/API)
// (OPTIONAL) If your provider gives you a full HTTPS URL, you can set:
// SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/your-project-id                    // (Infura)
// MAINNET_RPC_URL=https://mainnet.infura.io/v3/your-project-id                    // (Infura)
//
// TEAM ADDRESSES — each must be 42 chars: 0x + 40 hex
TEAM_ADDR_1=0xTEAM_ADDRESS_ONE_40HEX..............................................
TEAM_ADDR_2=0xTEAM_ADDRESS_TWO_40HEX..............................................
TEAM_ADDR_3=0xTEAM_ADDRESS_THREE_40HEX............................................
TEAM_ADDR_4=0xTEAM_ADDRESS_FOUR_40HEX.............................................
TEAM_ADDR_5=0xTEAM_ADDRESS_FIVE_40HEX.............................................

// ===============================================================
//  (4) hardhat.config.js — networks + etherscan verify (uses Infura)
// ===============================================================
// File: hardhat.config.js
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

// Build RPCs (Infura) if full URLs aren’t provided
const sepoliaUrl =
  SEPOLIA_RPC_URL || `https://sepolia.infura.io/v3/${INFURA_PROJECT_ID}`; // (Infura)
const mainnetUrl =
  MAINNET_RPC_URL || `https://mainnet.infura.io/v3/${INFURA_PROJECT_ID}`; // (Infura)

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
    apiKey: ETHERSCAN_API_KEY // (password/API)
  }
};

// ===============================================================
//  (5) scripts/deploy_and_airdrop.js — deploy + auto-gift 5×2,000,000
// ===============================================================
// File: scripts/deploy_and_airdrop.js
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

  // Deploy contract
  const Factory = await ethers.getContractFactory("Photonforge");
  const token = await Factory.deploy();
  await token.waitForDeployment();
  const tokenAddr = await token.getAddress();

  console.log(`Photonforge deployed at: ${tokenAddr}`);

  // Airdrop: 2,000,000 PFGE (with 18 decimals)
  const amount = ethers.parseUnits("2000000", 18);

  // Safety: ensure deployer has enough (initial supply is 200M; airdrop is 10M total)
  const signer = await ethers.getSigner();
  const balBefore = await token.balanceOf(signer.address);
  console.log(`Deployer balance before: ${ethers.formatUnits(balBefore, 18)} PFGE`);

  // Transfer to each team address
  for (const addr of TEAM) {
    const tx = await token.transfer(addr, amount);
    console.log(`Transferring 2,000,000 PFGE → ${addr} (tx: ${tx.hash})`);
    await tx.wait();
  }

  const balAfter = await token.balanceOf(signer.address);
  console.log(`Deployer balance after: ${ethers.formatUnits(balAfter, 18)} PFGE`);

  // OPTIONAL: Etherscan verify (wait a few blocks before running `npm run verify`)
  console.log("Next (optional): verify → `npx hardhat verify --network <net> " + tokenAddr + "`");
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});

// ===============================================================
//  (6) QUICKSTART — one-shot terminal flow
// ===============================================================
// Copy-paste to a terminal (Node 18+). Replace <…> where labeled.
# --- shell (sh) ---
mkdir photonforge && cd photonforge
npm init -y
npm i -D hardhat @nomicfoundation/hardhat-toolbox @nomicfoundation/hardhat-verify dotenv @openzeppelin/contracts
npx hardhat init --force                    # accept defaults
# Create files from this page:
#   contracts/Photonforge.sol
#   scripts/deploy_and_airdrop.js
#   hardhat.config.js
#   package.json (replace)
#   .env (create with secrets; see section (3))

# Compile
npx hardhat compile

# Fund your deployer address with ETH on chosen network (Sepolia test ETH or mainnet).

# Deploy to Sepolia (using (Infura) RPC):
npm run deploy:sepolia

# (Optional) Verify on Etherscan (needs ETHERSCAN_API_KEY):
npx hardhat verify --network sepolia <DEPLOYED_TOKEN_ADDRESS>

// ===============================================================
//  (7) OPTIONAL — Truffle equivalents (if you prefer Truffle)
// ===============================================================
// File: truffle-config.js
require("dotenv").config();
const HDWalletProvider = require("@truffle/hdwallet-provider");

const { OWNER_PRIVATE_KEY, INFURA_PROJECT_ID } = process.env;

module.exports = {
  networks: {
    sepolia: {
      provider: () =>
        new HDWalletProvider({
          privateKeys: [OWNER_PRIVATE_KEY],                // 66-char 0x private key
          providerOrUrl: `https://sepolia.infura.io/v3/${INFURA_PROJECT_ID}` // (Infura)
        }),
      network_id: 11155111
    }
  },
  compilers: { solc: { version: "0.8.24" } }
};

// File: migrations/1_deploy_photonforge.js
const Photonforge = artifacts.require("Photonforge");
module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(Photonforge);
  const token = await Photonforge.deployed();

  // Post-deploy airdrop (2,000,000 PFGE × 5)
  const toUnits = (n) => web3.utils.toWei(n, "ether"); // 18 decimals assumes 1 token == 1e18
  const TEAM = [
    process.env.TEAM_ADDR_1,
    process.env.TEAM_ADDR_2,
    process.env.TEAM_ADDR_3,
    process.env.TEAM_ADDR_4,
    process.env.TEAM_ADDR_5
  ];
  for (const a of TEAM) {
    if (!/^0x[0-9a-fA-F]{40}$/.test(a)) throw new Error("Bad 42-char 0x address: " + a);
    await token.transfer(a, toUnits("2000000"));
  }
};

// ===============================================================
//  (8) OPTIONAL — Geth private chain (local “Ethereum-type” chain)
// ===============================================================
// If you want an Ethereum-like chain via Geth and deploy PFGE there:
//
// # --- shell (sh) ---
// # Install geth (Go-Ethereum). Then:
// mkdir -p geth_private && cd geth_private
// cat > genesis.json <<'JSON'
// {
//   "config": {
//     "chainId": 1337,
//     "homesteadBlock": 0,
//     "eip150Block": 0,
//     "eip155Block": 0,
//     "eip158Block": 0,
//     "byzantiumBlock": 0,
//     "constantinopleBlock": 0,
//     "petersburgBlock": 0,
//     "istanbulBlock": 0,
//     "muirGlacierBlock": 0,
//     "londonBlock": 0,
//     "terminalTotalDifficulty": 0
//   },
//   "difficulty": "1",
//   "gasLimit": "30000000",
//   "alloc": {}
// }
// JSON
//
// geth --datadir data init genesis.json
// geth --datadir data --http --http.api eth,net,web3,personal --http.addr 127.0.0.1 --http.port 8545 --allow-insecure-unlock --mine --miner.etherbase 0xYOUR_COINBASE_40HEX_ADDRESS
//
// In hardhat.config.js add a “local” network:
//   local: { url: "http://127.0.0.1:8545", accounts: [OWNER_PRIVATE_KEY] }
//
// Then deploy with:
//   npx hardhat run scripts/deploy_and_airdrop.js --network local
//
// (Note: modern public Ethereum is PoS; this private dev net uses trivial mining.)

// ===============================================================
//  (9) OPERATIONAL NOTES — addresses, passwords, websites
// ===============================================================
// • Where do I insert my “0x”? (and how many characters?)
//   - PUBLIC ADDRESS:     42 chars (0x + 40 hex) → put into TEAM_ADDR_1..5, also funds deployer.
//   - PRIVATE KEY:        66 chars (0x + 64 hex) → put into OWNER_PRIVATE_KEY (.env only).
//
// • PASSWORD/API fields you must create on external sites:
//   - (Infura): create a project → INFURA_PROJECT_ID (or full RPC URL). Used in hardhat.config.js.
//   - Etherscan: create API key → ETHERSCAN_API_KEY. Used for contract verification.
//   - MetaMask: create wallet; export PRIVATE KEY (keep secret).
//
// • Is there any limit to how many addresses/tokens you can gift?
//   - No protocol limit; you’re limited by your token balance and gas costs per transfer.
//   - This script gifts 5×2,000,000 PFGE (total 10,000,000) from the deployer’s 200,000,000.
//     The rest remains with the deployer.
//
// • Fees: You’ll need ETH (on Sepolia or mainnet) in the deployer address to pay gas.
//
// • Verification: After a few blocks, run
//     npx hardhat verify --network sepolia <DEPLOYED_TOKEN_ADDRESS>
//
// • Alternatives to (Infura): Alchemy, QuickNode — just swap the RPC URL in config.

// ===============================================================
//  DONE. You now have: Solidity token, Hardhat deploy, (Infura) RPC,
//  Etherscan verify, auto-gifting to 5 team addresses, plus Truffle/Geth options.
// ===============================================================
