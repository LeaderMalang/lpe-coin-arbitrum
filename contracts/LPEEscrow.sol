// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LPEEscrow is Ownable {
    IERC20 public lpeToken;
    uint256 public constant TRANSACTION_FEE = 15; // 0.15% fee (15 / 10000)
    uint256 public constant LIQUIDITY_REINVEST_PERCENT = 50; // 50% of fees reinvested

    address public liquidityPool;
    mapping(uint256 => Escrow) public escrows;
    uint256 public escrowCount;

    struct Escrow {
        address sender;
        address receiver;
        uint256 amount;
        bool completed;
    }

    event EscrowCreated(uint256 escrowId, address indexed sender, address indexed receiver, uint256 amount);
    event EscrowCompleted(uint256 escrowId, address indexed receiver, uint256 amount);
    event FeeReinvested(uint256 amount);

    constructor(address _lpeToken, address _liquidityPool) Ownable(msg.sender) {
        lpeToken = IERC20(_lpeToken);
        liquidityPool = _liquidityPool;
    }

    function createEscrow(address _receiver, uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than zero");
        uint256 fee = (_amount * TRANSACTION_FEE) / 10000;
        uint256 netAmount = _amount - fee;

        lpeToken.transferFrom(msg.sender, address(this), _amount);

        escrows[escrowCount] = Escrow(msg.sender, _receiver, netAmount, false);
        emit EscrowCreated(escrowCount, msg.sender, _receiver, netAmount);
        escrowCount++;
    }

    function releaseEscrow(uint256 _escrowId) external onlyOwner {
        Escrow storage esc = escrows[_escrowId];
        require(!esc.completed, "Escrow already completed");

        esc.completed = true;
        lpeToken.transfer(esc.receiver, esc.amount);
        emit EscrowCompleted(_escrowId, esc.receiver, esc.amount);
    }

    function reinvestFees() external onlyOwner {
        uint256 contractBalance = lpeToken.balanceOf(address(this));
        uint256 reinvestAmount = (contractBalance * LIQUIDITY_REINVEST_PERCENT) / 100;
        lpeToken.transfer(liquidityPool, reinvestAmount);
        emit FeeReinvested(reinvestAmount);
    }
}