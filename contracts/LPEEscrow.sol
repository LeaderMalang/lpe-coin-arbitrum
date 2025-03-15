// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title VisionX P2P Escrow Smart Contract
contract LPEEscrow is Ownable {
    IERC20 public usdcToken;
    uint256 public constant TRANSACTION_FEE = 15; // 0.15% fee
    uint256 public constant GIFT_PERCENTAGE = 10; // 10% of fees for VisionX learning
    uint256 public constant MAX_GIFT_AMOUNT = 5 * 10**6; // $5 cap per user per year (assuming 6 decimal USDC)

    struct Escrow {
        address sender;
        address receiver;
        uint256 amount;
        bool completed;
    }

    mapping(uint256 => Escrow) public escrows;
    mapping(address => uint256) public yearlyGiftReceived;
    uint256 public escrowCount;

    event EscrowCreated(uint256 escrowId, address indexed sender, address indexed receiver, uint256 amount);
    event EscrowCompleted(uint256 escrowId, address indexed receiver, uint256 amount);
    event GiftDistributed(address indexed user, uint256 amount);

    constructor(address _usdcToken) Ownable(msg.sender) {
        usdcToken = IERC20(_usdcToken);
    }

    function createEscrow(address _receiver, uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than zero");
        uint256 fee = (_amount * TRANSACTION_FEE) / 10000;
        uint256 giftAmount = (fee * GIFT_PERCENTAGE) / 100;
        uint256 netAmount = _amount - fee;

        usdcToken.transferFrom(msg.sender, address(this), _amount);
        escrows[escrowCount] = Escrow(msg.sender, _receiver, netAmount, false);
        emit EscrowCreated(escrowCount, msg.sender, _receiver, netAmount);
        escrowCount++;

        _distributeGift(msg.sender, giftAmount);
    }

    function releaseEscrow(uint256 _escrowId) external onlyOwner {
        Escrow storage esc = escrows[_escrowId];
        require(!esc.completed, "Escrow already completed");

        esc.completed = true;
        usdcToken.transfer(esc.receiver, esc.amount);
        emit EscrowCompleted(_escrowId, esc.receiver, esc.amount);
    }

    function _distributeGift(address _user, uint256 _amount) internal {
        if (yearlyGiftReceived[_user] < MAX_GIFT_AMOUNT) {
            uint256 remainingCap = MAX_GIFT_AMOUNT - yearlyGiftReceived[_user];
            uint256 giftToSend = _amount > remainingCap ? remainingCap : _amount;
            
            if (giftToSend > 0) {
                usdcToken.transfer(_user, giftToSend);
                yearlyGiftReceived[_user] += giftToSend;
                emit GiftDistributed(_user, giftToSend);
            }
        }
    }
}
