// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CA3 {
    address public owner;
    uint256 public balance;

    constructor() {
        owner = msg.sender;
    }

    // Modifier to restrict function access to owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    // Withdraw function with access control
    function withdraw(uint256 amount) public onlyOwner {
        require(amount <= balance, "Insufficient balance");
        balance -= amount;
        payable(msg.sender).transfer(amount);
    }

    function deposit() public payable {
        balance += msg.value;
    }
}