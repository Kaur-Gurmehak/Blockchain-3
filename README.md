
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

 ## Improved Solidity Contract

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
    

