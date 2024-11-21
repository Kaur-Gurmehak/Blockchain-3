

## K Framework Rule
// K Rule for Access Control 
rule [withdraw-access-control]:
    <k>
      call(withdraw(AMOUNT:Int)) 
      => 
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

