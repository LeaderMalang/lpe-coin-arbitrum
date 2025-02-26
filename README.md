# VisionX Smart Contracts

## Overview
VisionX is a decentralized ecosystem that integrates **peer-to-peer transactions, micro-lending, staking rewards, and liquidity reinvestment mechanisms** powered by the LPE token. This document provides an overview of the smart contracts and guidelines for integrating them into external systems.

---

## Smart Contracts

### 1. **LPE Token Contract (LPEToken.sol)**
#### **Features:**
- **ERC-20 Standard Token** with minting, burning, and pausing functionalities.
- **Supply Cap:** Maximum supply is enforced.
- **Scheduled Token Drops:** Users can claim daily rewards.
- **Referral System:** Users can earn rewards by referring others.
- **Ownership Transfer:** Admins can transfer ownership.
- **Streak-Based Rewards:** Users get bonus tokens for daily claims.
- **Random Drops:** Admins can distribute additional tokens.

#### **Integration Guide:**
- Deploy the contract and initialize it with a max supply.
- Use `mint()` to distribute tokens (requires MINTER_ROLE).
- Use `claimScheduledDrop()` for daily token drops.
- Use `referUser(address newUser)` to implement referral rewards.
- Use `burn(uint256 amount)` to allow token burning.
- Implement **pausing/unpausing** with `pause()` and `unpause()` functions.

---

### 2. **Wrapped LPE (wLPE.sol)**
#### **Features:**
- **1:1 Wrapping** of LPE into wLPE for DeFi use.
- **Unwrapping Mechanism:** Convert wLPE back to LPE.
- **Admin Recovery:** The owner can recover stuck LPE tokens.

#### **Integration Guide:**
- Deploy the contract with the LPE token address.
- Use `wrap(uint256 amount)` to convert LPE into wLPE.
- Use `unwrap(uint256 amount)` to redeem LPE tokens.
- Admins can use `recoverStuckLPE(uint256 amount)` to retrieve misplaced tokens.

---

### 3. **P2P Escrow Contract (LPEEscrow.sol)**
#### **Features:**
- **Peer-to-Peer Transactions:** Secure escrow-based transfers.
- **Fee Deduction:** Charges a **0.15% fee** on each transaction.
- **Liquidity Reinvestment:** **50% of fees are sent to the liquidity pool.**
- **Admin-Controlled Escrow Release.**

#### **Integration Guide:**
- Deploy the contract with **LPE token and liquidity pool address**.
- Use `createEscrow(address receiver, uint256 amount)` to lock funds in escrow.
- Use `releaseEscrow(uint256 escrowId)` (admin-only) to complete a transaction.
- Call `reinvestFees()` to send fees to the liquidity pool.

---

### 4. **Micro-Lending Escrow Contract (LPEMicroLendingEscrow.sol)**
#### **Features:**
- **Loan System:** Users can lend and borrow LPE tokens.
- **1.5% Origination Fee:** Deducted on loan creation.
- **Secured Repayments:** Borrowers must repay directly to the contract.

#### **Integration Guide:**
- Deploy the contract with **LPE token address**.
- Use `createLoan(address borrower, uint256 amount)` to initiate a loan.
- Use `repayLoan(uint256 loanId)` to repay the loan.
- Admins can **monitor active loans and liquidate defaults.**

---

### 5. **Staking Contract (LPEStaking.sol)**
#### **Features:**
- **Stake LPE for Fee Discounts:** Reduces transaction fees.
- **Staking Tiers:** More LPE staked = Lower fees.
- **Flexible Unstaking:** Users can unstake anytime.

#### **Integration Guide:**
- Deploy the contract with **LPE token address**.
- Use `stake(uint256 amount)` to lock LPE tokens.
- Use `unstake(uint256 amount)` to withdraw staked tokens.
- Implement logic to apply **discounts based on staking levels.**

---

## Liquidity Pool Reinvestment Mechanism
- **50% of all fees collected from transactions and lending are automatically reinvested into the liquidity pool.**
- Helps build **organic liquidity** and **improves token stability.**

## Security Considerations
- Ensure **proper role management** (MINTER, PAUSER, ADMIN roles).
- Use **multi-sig wallets** for high-risk operations.
- Regular **audits** are recommended before deployment.

## Deployment Steps
1. Deploy **LPEToken** and note its contract address.
2. Deploy **WrappedLPE**, linking it to the **LPEToken address**.
3. Deploy **LPEEscrow**, **MicroLendingEscrow**, and **LPEStaking**, linking them to **LPEToken**.
4. Configure liquidity pools and admin accounts.
5. Integrate staking fee discounts into transaction logic.
6. Test transactions on a testnet before launching on the mainnet.

---

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
npx hardhat ignition deploy ignition/modules/StableCoin.js --network arbi_mainnet --parameters ignition/parameters.json --verify
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

- Governance System: Enable community voting for liquidity decisions.

- Auto-compounding Staking Rewards.

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
- 📧 [VisionX Partners](https://partners.circle.com/partner/vxchange)


---

We appreciate your interest in building a stable and accessible digital economy!
For further queries or customization, reach out to the VisionX Dev Team. 🚀
**#VisionX #Crypto #Blockchain #DeFi #BinanceSmartChain #Web3 #Tokenization**

