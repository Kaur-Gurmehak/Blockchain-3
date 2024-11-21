// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SecureWallet {
    error AccessControlError(string message);

    address public owner;
    uint256 public balance;

    // Events for formal verification tracking
    event Withdrawal(address indexed caller, uint256 amount);
    event Deposit(address indexed depositor, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    // Modifier implementing K Framework access control logic
    modifier onlyOwner() {
        // Directly implements K rule's access control check
        if (msg.sender != owner) {
            revert AccessControlError("Only owner can withdraw");
        }
        _;
    }

    // Withdraw function with formal verification considerations
    function withdraw(uint256 amount) public onlyOwner {
        // Preconditions matching K rule
        require(amount <= balance, "Insufficient balance");
        
        // State transition as specified in K rule
        balance -= amount;
        
        // Transfer funds
        payable(msg.sender).transfer(amount);
        
        // Event for verification tracking
        emit Withdrawal(msg.sender, amount);
    }

    // Deposit function with verification event
    function deposit() public payable {
        balance += msg.value;
        
        // Event for tracking deposits
        emit Deposit(msg.sender, msg.value);
    }
}
