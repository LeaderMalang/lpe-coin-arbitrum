// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract LPEToken is ERC20, ERC20Burnable, ERC20Pausable, AccessControl, ERC20Permit , Ownable{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    uint256 public immutable cap; // Maximum supply cap

    // Drop-related variables
    uint256 public scheduledDropAmount = 5 * 10**decimals(); // 5 tokens
    uint256 public randomDropAmount = 3 * 10**decimals(); // 3 tokens

    // Track claim status and streaks
    mapping(address => uint256) public lastScheduledDropClaim;
    mapping(address => uint256) public streakCount; // Tracks consecutive daily claims
    mapping(address => uint256) public lastStreakUpdate;

    // Referral system
    mapping(address => address) public referredBy;
    mapping(address => uint256) public referralCount;

    // Events
    event TokensMinted(address indexed to, uint256 amount);
    event TokensBurned(address indexed from, uint256 amount);
    event ScheduledDropClaimed(address indexed user, uint256 amount);
    event RandomDropAwarded(address indexed user, uint256 amount);
    event StreakCompleted(address indexed user, uint256 streak);
    event Referred(address indexed referrer, address indexed referred);
    // event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(uint256 _cap) ERC20("LPE Token", "LPE") ERC20Permit("LPE Token")  Ownable(msg.sender){
        require(_cap > 0, "Cap should be greater than 0");
        cap = _cap;

        // Set up roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
    }

    // Transfer ownership function
    function transferOwnership(address newOwner) public override {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not the owner");
        require(newOwner != address(0), "New owner is the zero address");

        // Grant the DEFAULT_ADMIN_ROLE to the new owner
        grantRole(DEFAULT_ADMIN_ROLE, newOwner);

        // Revoke the DEFAULT_ADMIN_ROLE from the current owner
        revokeRole(DEFAULT_ADMIN_ROLE, msg.sender);

        emit OwnershipTransferred(msg.sender, newOwner);
    }

    // Mint function with cap
    function mint(address to, uint256 amount) public {
        require(hasRole(MINTER_ROLE, msg.sender), "Must have minter role to mint");
        require(totalSupply() + amount <= cap, "ERC20Capped: cap exceeded");
        _mint(to, amount);
        emit TokensMinted(to, amount);
    }

    // Burn functions with events
    function burn(uint256 amount) public override {
        super.burn(amount);
        emit TokensBurned(msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) public override {
        super.burnFrom(account, amount);
        emit TokensBurned(account, amount);
    }

    // Pause and unpause functions
    function pause() public {
        require(hasRole(PAUSER_ROLE, msg.sender), "Must have pauser role to pause");
        _pause();
    }

    function unpause() public {
        require(hasRole(PAUSER_ROLE, msg.sender), "Must have pauser role to unpause");
        _unpause();
    }

    // Scheduled Drop: Users can claim once per day
    function claimScheduledDrop() external {
        require(block.timestamp - lastScheduledDropClaim[msg.sender] >= 1 days, "Already claimed today's drop");
        lastScheduledDropClaim[msg.sender] = block.timestamp;
        _mint(msg.sender, scheduledDropAmount);
        emit ScheduledDropClaimed(msg.sender, scheduledDropAmount);

        // Update streak if applicable
        if (block.timestamp - lastStreakUpdate[msg.sender] <= 1 days) {
            streakCount[msg.sender]++;
        } else {
            streakCount[msg.sender] = 1; // Reset streak if missed a day
        }
        lastStreakUpdate[msg.sender] = block.timestamp;
    }

    // Random Drop: Can be triggered by admin based on external conditions
    function randomDrop(address to) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _mint(to, randomDropAmount);
        emit RandomDropAwarded(to, randomDropAmount);
    }

    // Streak bonus claim: Users can claim a bonus after 7 days of consecutive scheduled drops
    function claimStreakBonus() external {
        require(streakCount[msg.sender] >= 7, "Complete a 7-day streak to claim bonus");
        streakCount[msg.sender] = 0; // Reset streak count
        _mint(msg.sender, scheduledDropAmount * 2); // Bonus reward
        emit StreakCompleted(msg.sender, 7);
    }

    // Referral program: Users can refer new users and get rewarded
    function referUser(address newUser) external {
        require(referredBy[newUser] == address(0), "User already referred");
        referredBy[newUser] = msg.sender;
        referralCount[msg.sender]++;
        // Mint referral rewards
        _mint(msg.sender, randomDropAmount); // Reward for referrer
        _mint(newUser, randomDropAmount); // Reward for referred
        emit Referred(msg.sender, newUser);
    }

    // Hook for token transfer restrictions (pausable)
    // function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Pausable) {
    //     super._beforeTokenTransfer(from, to, amount);
    // }
    function _update(address from, address to, uint256 amount) internal override(ERC20, ERC20Pausable) {
    super._update(from, to, amount);
}
}

