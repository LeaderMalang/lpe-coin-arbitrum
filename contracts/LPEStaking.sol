// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LPEStaking is Ownable {
    IERC20 public lpeToken;
    mapping(address => uint256) public stakes;
    mapping(address => uint256) public stakeTimestamps;
    
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);

    constructor(address _lpeToken) Ownable(msg.sender){
        lpeToken = IERC20(_lpeToken);
    }

    function stake(uint256 _amount) external {
        require(_amount > 0, "Cannot stake zero tokens");
        lpeToken.transferFrom(msg.sender, address(this), _amount);
        stakes[msg.sender] += _amount;
        stakeTimestamps[msg.sender] = block.timestamp;
        emit Staked(msg.sender, _amount);
    }

    function unstake(uint256 _amount) external {
        require(stakes[msg.sender] >= _amount, "Not enough tokens staked");
        lpeToken.transfer(msg.sender, _amount);
        stakes[msg.sender] -= _amount;
        emit Unstaked(msg.sender, _amount);
    }
}