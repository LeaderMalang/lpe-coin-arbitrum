# VisionX Smart Contracts - README

## Overview
VisionX is a **P2P microfinance platform** focusing on **secure peer-to-peer transactions, micro-lending, staking, fee reinvestment, and dispute resolution via a DAO**. The ecosystem uses **LPE tokens and USDC** for transactions and governance.

---

## Smart Contracts Deployment Order
1. **LPEToken:** The main token contract required for staking and governance.
2. **LPEEscrow:** Facilitates **P2P USDC transactions** with a **0.15% fee**.
3. **LPEMicroLending:** Enables **$25 micro-loans** with a **1.5% origination fee**.
4. **LPEStaking:** Allows users to **stake LPE for reduced fees**.
5. **LPEDAO:** Decentralized governance for dispute resolution.

---

## Smart Contracts Details

### 1. **LPE Token Contract (LPEToken.sol)**
#### **Features:**
- **ERC-20 Standard Token** with minting, burning, and pausing functionalities.
- **Staking Integration:** Reduces fees for staked users.
- **Burn Mechanism:** **1% annual burn** for unstaked LPE.
- **DAO Voting:** **1 LPE = 1 Vote** in disputes.

#### **Integration Guide:**
- Deploy **LPEToken** first.
- Use `mint(address to, uint256 amount)` for distribution.
- Use `burn(uint256 amount)` to reduce supply.
- Implement staking-based fee reductions.

---

### 2. **P2P Escrow Contract (LPEEscrow.sol)**
#### **Features:**
- **USDC Peer-to-Peer Transactions** with **0.15% fee**.
- **Secure escrow mechanism** to prevent fraud.
- **Admin-controlled escrow release**.
- **10% of fees reinvested as USDC gifts** (max **$5/user/year** for VisionX learning).

#### **Integration Guide:**
- Use `createEscrow(address receiver, uint256 amount)` to lock USDC in escrow.
- Use `releaseEscrow(uint256 escrowId)` (admin-only) to complete the trade.
- Implement `distributeGift(address user, uint256 amount)` for USDC rewards.

---

### 3. **Micro-Lending Escrow Contract (LPEMicroLending.sol)**
#### **Features:**
- **$25 micro-loans** via escrow.
- **1.5% origination fee** on loans.
- **Automated repayment tracking**.

#### **Integration Guide:**
- Use `createLoan(address borrower, uint256 amount)` to initiate a loan.
- Use `repayLoan(uint256 loanId)` to mark a loan as paid.
- Admins can **monitor active loans and enforce repayments**.

---

### 4. **Staking Contract (LPEStaking.sol)**
#### **Features:**
- **Reduces trading fees for stakers**.
- **0.15% fee for non-stakers, 0.1% for 50+ LPE stakers**.
- **Stake lock mechanism for consistent participation.**

#### **Integration Guide:**
- Use `stake(uint256 amount)` to lock LPE.
- Use `unstake(uint256 amount)` to withdraw staked tokens.
- Implement **discount logic** in P2P Escrow.

---

### 5. **Decentralized Autonomous Organization (DAO) (LPEDAO.sol)**
#### **Features:**
- **1 LPE = 1 Vote (Quadratic Voting)**.
- **51% majority required** to resolve disputes.
- **Transparent on-chain governance** for transactions and loans.

#### **Integration Guide:**
- Use `createDispute(uint256 escrowId or loanId, string reason)` to initiate a dispute.
- Use `voteOnDispute(uint256 disputeId, bool support)` for voting.
- Automatically **enforce majority decision** after voting.

---

## Liquidity & Fee Reinvestment
- **10% of fees → USDC gifts** (max **$5/user/year**) for VisionX learning.
- **40% of fees → audits & platform growth.**
- **50% of fees → platform reserves.**

---

## Security Measures
- **Multi-sig Security:** Minting and burning require **2/2 approval** (developer + founder).
- **AMM and liquidity pool disabled**.
- **Regular audits & compliance checks**.

---

## Deployment & Integration Guide
1. **Deploy LPEToken** first, as all other contracts depend on it.
2. **Deploy LPEEscrow, Micro-Lending, Staking, and DAO** contracts.
3. **Configure staking fee discounts in Escrow transactions**.
4. **Enable dispute resolution through DAO voting**.
5. **Test transactions and governance on a testnet** before mainnet deployment.



### **Prerequisites**
1. Install [Node.js](https://nodejs.org/) and npm.
2. Install Hardhat globally: `npm install --global hardhat`.
3. Set up a Binance Smart Chain wallet and obtain testnet/mainnet credentials.

### **Installation**
Clone the repository and install dependencies:
```bash
npm install
```

### **Compilation**
Compile the contract using Hardhat:
```bash
npx hardhat compile
```

### **Deployment**
Deploy the contract to BSC:
```bash
npx hardhat ignition deploy ignition/modules/LPESmartContracts.js --network arbi_testnet --parameters ignition/parameters.json --verify
```

---

## **Testing the Contract**

### **Testing Framework**
- **Deployment Tests:** Ensure correct owner assignment and initial supply allocation.
- **Transaction Tests:** Verify transfers, events, and blacklist functionality.

### **Run Tests**
Run the test suite:
```bash
npx hardhat test
```

### **Environment Variables**
Set up a `.env` file with the following values:
```plaintext

PRIVATE_KEY=YourPrivateKey
API_KEY=YourARBIScanAPIKey
```

---

## **Future Enhancements**



- NFT Collateral for Micro-Lending.



## **Contributors**
- **[Hassan Ali](mailto:hassanali5120@gmail.com)** – Development Lead

---

## **License**
This project is licensed under the [MIT License](LICENSE).

---

## **Get Involved**

Follow our progress or contribute to the project:
- 🌐 [Website](https://aasanhai.pk)
- 📧 [Contact Us](mailto:hassanali5120@gmail.com)
- 📧 [VisionX Partners](https://www.visionxecosystem.com/)


---

We appreciate your interest in building a stable and accessible digital economy!
For further queries or customization, reach out to the VisionX Dev Team. 🚀
**#VisionX #Crypto #Blockchain #DeFi #BinanceSmartChain #Web3 #Tokenization**

