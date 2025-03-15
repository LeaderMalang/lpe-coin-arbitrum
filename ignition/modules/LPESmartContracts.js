const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const LPESmartContractsModule = buildModule("LPESmartContracts", (m) => {
  
  // Parameters for contract deployment
  const usdcAddress = m.getParameter(
    "usdcAddress",
    "0xf3C3351D6Bd0098EEb33ca8f830FAf2a141Ea2E1" // Placeholder USDC address
  );

  // Deploy LPE Token Contract first
  const LPEToken = m.contract("LPEToken", [], { id: "LPEToken" });

  // Deploy P2P Escrow Contract (after LPE Token)
  const LPEEscrow = m.contract("LPEEscrow", [usdcAddress], { id: "LPEEscrow", after: [LPEToken] });

  // Deploy Micro-Lending Contract (after LPE Token)
  const LPEMicroLending = m.contract("LPEMicroLending", [usdcAddress], { id: "LPEMicroLending", after: [LPEToken] });

  // Deploy Staking Contract (after LPE Token)
  const LPEStaking = m.contract("LPEStaking", [LPEToken], { id: "LPEStaking", after: [LPEToken] });

  // Deploy DAO Contract for dispute resolution (after LPE Token)
  const LPEDAO = m.contract("LPEDAO", [LPEToken], { id: "LPEDAO", after: [LPEToken] });

  return { LPEToken, LPEEscrow, LPEMicroLending, LPEStaking, LPEDAO };
});

module.exports = LPESmartContractsModule;
