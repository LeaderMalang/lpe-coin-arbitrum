// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract LPEMicroLendingEscrow is Ownable {
    IERC20 public lpeToken;
    uint256 public constant ORIGINATION_FEE = 150; // 1.5% fee (150 / 10000)

    struct Loan {
        address lender;
        address borrower;
        uint256 amount;
        bool repaid;
    }

    mapping(uint256 => Loan) public loans;
    uint256 public loanCount;

    event LoanCreated(uint256 loanId, address indexed lender, address indexed borrower, uint256 amount);
    event LoanRepaid(uint256 loanId);

    constructor(address _lpeToken) Ownable(msg.sender) {
        lpeToken = IERC20(_lpeToken);
    }

    function createLoan(address _borrower, uint256 _amount) external {
        require(_amount > 0, "Loan amount must be greater than zero");
        uint256 fee = (_amount * ORIGINATION_FEE) / 10000;
        uint256 netAmount = _amount - fee;

        lpeToken.transferFrom(msg.sender, address(this), _amount);
        lpeToken.transfer(_borrower, netAmount);
        
        loans[loanCount] = Loan(msg.sender, _borrower, _amount, false);
        emit LoanCreated(loanCount, msg.sender, _borrower, _amount);
        loanCount++;
    }

    function repayLoan(uint256 _loanId) external {
        Loan storage loan = loans[_loanId];
        require(!loan.repaid, "Loan already repaid");
        
        lpeToken.transferFrom(msg.sender, loan.lender, loan.amount);
        loan.repaid = true;
        emit LoanRepaid(_loanId);
    }
}