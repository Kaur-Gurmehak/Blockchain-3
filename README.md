
## Introduction
The provided content addresses the following aspects of the question:

- Rule in the K Framework: The rule withdraw-access-control ensures access control by checking if the caller (CALLER) is the owner (OWNER). If not, it throws an AccessControlError, thus enforcing that only the owner can call the withdraw function. The rule also updates the contract state by ensuring the balance is sufficient and remains non-negative after the withdrawal.

- Vulnerable Solidity Code: This section provides a simple example of a vulnerable contract where anyone can call the withdraw function due to the lack of access control. It shows the potential security risk.

- Improved Solidity Contract: This improved version implements the access control logic directly within the contract using a modifier called onlyOwner. This modifier checks if the caller is the owner before allowing the withdrawal. The contract also emits events for deposit and withdrawal actions to facilitate formal verification.

## K Framework Rule
### K Rule for Access Control
### Rule: withdraw-access-control

This rule ensures that only the contract owner can execute the `withdraw` function and verifies the state accordingly.

```markdown

rule [withdraw-access-control]:
    <k>
      // Specification of withdraw function call
      call(withdraw(AMOUNT:Int)) 
      => 
      // Access control check
      if (CALLER =/=Int OWNER) 
      then throw(AccessControlError("Only owner can withdraw"))
      else proceed 
    </k>
    <contractState>
      <owner> OWNER:Int </owner>
      <caller> CALLER:Int </caller>
      <balance> BALANCE:Int => BALANCE -Int AMOUNT </balance>
    </contractState>
    // Preconditions
    requires AMOUNT <=Int BALANCE  // Ensure sufficient balance
    ensures BALANCE >=Int 0         // Ensure non-negative balance after withdrawal
```

The rule specifies:-

- Formally specifies access control for withdraw()
- Checks if caller matches owner
- Verifies sufficient balance
- Ensures valid state transitions

```markdown
  ## Vulnerable Code

    // SPDX-License-Identifier: MIT
    pragma solidity ^0.8.0;

    contract VulnerableWallet {
    address public owner;
    uint256 public balance;

    constructor() {
        owner = msg.sender;
    }

    function withdraw(uint256 amount) public {
        require(amount <= balance, "Insufficient balance");
        balance -= amount;
        payable(msg.sender).transfer(amount);
    }
    function deposit() public payable {
        balance += msg.value;
    }
    }
```
- The contract has a basic withdraw() function that currently lacks proper access control
- owner is set to the contract deployer in the constructor
- Anyone can currently call withdraw(), which is a security vulnerability

 ## Improved Solidity Contract

     // SPDX-License-Identifier: MIT
    pragma solidity ^0.8.0;

    contract SecureWallet {
    error AccessControlError(string message);

    address public owner;
    uint256 public balance;

    event Withdrawal(address indexed caller, uint256 amount);
    event Deposit(address indexed depositor, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    // Modifier implementing K Framework access control logic
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert AccessControlError("Only owner can withdraw");
        }
        _;
    }

    // Withdraw function with formal verification considerations
    function withdraw(uint256 amount) public onlyOwner {
        // Preconditions
        require(amount <= balance, "Insufficient balance");
        
        // State transition as specified in K rule
        balance -= amount;
        
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }
    function deposit() public payable {
        balance += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    }

This solution provides:

- Formal verification of owner-only access
- Runtime protection against unauthorized withdrawals
- Ensures valid balance transitions

