// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleBank {
    mapping(address => uint256) private balances;

    // Deposit Ether
    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        balances[msg.sender] += msg.value;
    }

    // Withdraw Ether
    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    // Check balance
    function checkBalance() public view returns (uint256) {
        return balances[msg.sender];
    }

    // Transfer funds to another user
    function transfer(address recipient, uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        require(recipient != address(0), "Invalid recipient");
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
    }
}
