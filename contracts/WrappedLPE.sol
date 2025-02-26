// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import OpenZeppelin's ERC20 and Ownable implementations
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract WrappedLPE is ERC20, Ownable {

    // Address of the LPE token that will be wrapped
    IERC20 public lpeToken;

    // Event emitted when LPE is wrapped into wLPE
    event Wrapped(address indexed user, uint256 amount);

    // Event emitted when wLPE is unwrapped into LPE
    event Unwrapped(address indexed user, uint256 amount);

    // Constructor sets the LPE token address and the wrapped token's name/symbol
    constructor(IERC20 _lpeToken) ERC20("Wrapped LPE", "wLPE") Ownable(msg.sender) {
        lpeToken = _lpeToken;
    }

    // Function to wrap LPE tokens and mint equivalent wLPE tokens
    function wrap(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than zero");

        // Transfer LPE tokens from user to the contract
        require(lpeToken.transferFrom(msg.sender, address(this), _amount), "LPE transfer failed");

        // Mint wLPE tokens to the user
        _mint(msg.sender, _amount);

        emit Wrapped(msg.sender, _amount);
    }

    // Function to unwrap wLPE tokens and redeem LPE tokens
    function unwrap(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than zero");
        require(balanceOf(msg.sender) >= _amount, "Not enough wLPE tokens");

        // Burn wLPE tokens from the user
        _burn(msg.sender, _amount);

        // Transfer LPE tokens from contract to the user
        require(lpeToken.transfer(msg.sender, _amount), "LPE transfer failed");

        emit Unwrapped(msg.sender, _amount);
    }

    // Function to recover any stuck LPE tokens (admin only)
    function recoverStuckLPE(uint256 _amount) external onlyOwner {
        require(lpeToken.transfer(owner(), _amount), "LPE recovery failed");
    }

    // Function to transfer contract ownership to a new address (onlyOwner)
    function transferOwnership(address newOwner) public override onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        super.transferOwnership(newOwner);
    }
}



