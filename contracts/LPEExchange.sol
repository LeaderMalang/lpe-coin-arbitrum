// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LPEExchange is Ownable {
    IERC20 public lpeToken;
   
    uint256 public totalLiquidity;

    // Holding period for purchased tokens
    uint256 public constant HOLD_PERIOD = 3 weeks;
    uint256 public constant MIN_BUY = 0.01 ether;
    uint256 public constant MAX_BUY = 10 ether;

    mapping(address => uint256) public liquidity;
    mapping(address => uint256) public purchaseTimestamp;

    event LiquidityProvided(address indexed provider, uint256 amountToken, uint256 amountETH);
    event LiquidityRemoved(address indexed provider, uint256 amountToken, uint256 amountETH);
    event BoughtTokens(address indexed buyer, uint256 amountETH, uint256 amountTokens);
    event SoldTokens(address indexed seller, uint256 amountTokens, uint256 amountETH);

   
    modifier holdPeriodPassed() {
        require(block.timestamp >= purchaseTimestamp[msg.sender] + HOLD_PERIOD, "Holding period not passed");
        _;
    }

    constructor(address _lpeTokenAddress)  Ownable(msg.sender){
        lpeToken = IERC20(_lpeTokenAddress);
        
        emit OwnershipTransferred(address(0), msg.sender);  // Initial ownership transfer event
    }

    // Add liquidity function for owner
    function addLiquidity(uint256 _amountToken) external payable onlyOwner {
        require(_amountToken > 0 && msg.value > 0, "Must provide both ETH and LPE tokens");

        lpeToken.transferFrom(msg.sender, address(this), _amountToken);
        totalLiquidity += msg.value;
        emit LiquidityProvided(msg.sender, _amountToken, msg.value);
    }

    // Buy LPE tokens
    function buyTokens() external payable {
        require(msg.value >= MIN_BUY && msg.value <= MAX_BUY, "Buy amount out of range");

        uint256 tokenAmount = (msg.value * lpeToken.balanceOf(address(this))) / address(this).balance;
        lpeToken.transfer(msg.sender, tokenAmount);
        purchaseTimestamp[msg.sender] = block.timestamp;

        emit BoughtTokens(msg.sender, msg.value, tokenAmount);
    }

    // Sell LPE tokens after holding period
    function sellTokens(uint256 _amountToken) external holdPeriodPassed {
        require(_amountToken > 0, "Must sell some amount of tokens");

        uint256 ethAmount = (_amountToken * address(this).balance) / lpeToken.balanceOf(address(this));
        require(address(this).balance >= ethAmount, "Not enough ETH liquidity");

        lpeToken.transferFrom(msg.sender, address(this), _amountToken);
        payable(msg.sender).transfer(ethAmount);

        emit SoldTokens(msg.sender, _amountToken, ethAmount);
    }

    // Remove liquidity function for owner
    function removeLiquidity(uint256 _amountETH) external onlyOwner {
        require(_amountETH > 0, "Invalid ETH amount");

        uint256 tokenAmount = (_amountETH * lpeToken.balanceOf(address(this))) / address(this).balance;
        totalLiquidity -= _amountETH;

        payable(msg.sender).transfer(_amountETH);
        lpeToken.transfer(msg.sender, tokenAmount);

        emit LiquidityRemoved(msg.sender, tokenAmount, _amountETH);
    }

    // Function to transfer ownership to a new address
    // function transferOwnership(address newOwner) external onlyOwner {
    //     require(newOwner != address(0), "New owner is the zero address");
    //     emit OwnershipTransferred(owner, newOwner);
    //     owner = newOwner;
    // }

    // Fallback function to accept ETH
    receive() external payable {}
}