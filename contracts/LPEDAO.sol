// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title VisionX DAO for Dispute Resolution
contract LPEDAO {
    IERC20 public lpeToken;
    
    struct Dispute {
        uint256 escrowOrLoanId;
        string reason;
        uint256 votesFor;
        uint256 votesAgainst;
        mapping(address => bool) hasVoted;
        bool resolved;
    }
    
    mapping(uint256 => Dispute) public disputes;
    uint256 public disputeCount;
    
    event DisputeCreated(uint256 disputeId, uint256 escrowOrLoanId, string reason);
    event VoteCasted(uint256 disputeId, address indexed voter, bool support);
    event DisputeResolved(uint256 disputeId, bool approved);

    constructor(address _lpeToken) {
        lpeToken = IERC20(_lpeToken);
    }

    function createDispute(uint256 _escrowOrLoanId, string calldata _reason) external {
        Dispute storage newDispute = disputes[disputeCount];
        newDispute.escrowOrLoanId = _escrowOrLoanId;
        newDispute.reason = _reason;
        newDispute.votesFor = 0;
        newDispute.votesAgainst = 0;
        newDispute.resolved = false;
        emit DisputeCreated(disputeCount, _escrowOrLoanId, _reason);
        disputeCount++;
    }

    function voteOnDispute(uint256 _disputeId, bool _support) external {
        Dispute storage dispute = disputes[_disputeId];
        require(!dispute.resolved, "Dispute already resolved");
        require(!dispute.hasVoted[msg.sender], "Already voted");

        uint256 votes = lpeToken.balanceOf(msg.sender);
        require(votes > 0, "No LPE tokens to vote");

        if (_support) {
            dispute.votesFor += votes;
        } else {
            dispute.votesAgainst += votes;
        }

        dispute.hasVoted[msg.sender] = true;
        emit VoteCasted(_disputeId, msg.sender, _support);
    }

    function resolveDispute(uint256 _disputeId) external {
        Dispute storage dispute = disputes[_disputeId];
        require(!dispute.resolved, "Dispute already resolved");

        uint256 totalVotes = dispute.votesFor + dispute.votesAgainst;
        require(totalVotes > 0, "No votes casted");

        bool approved = (dispute.votesFor * 100) / totalVotes >= 51;
        dispute.resolved = true;

        emit DisputeResolved(_disputeId, approved);
    }
}