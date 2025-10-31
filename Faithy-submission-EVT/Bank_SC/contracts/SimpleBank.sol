// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleBank {
    // Mapping to store user balances
    mapping(address => uint256) public balances;

    // Function 1: deposit()
    // Allows users to send Ether to the contract and updates their balance
    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        balances[msg.sender] += msg.value;
    }

    // Function 2: withdraw()
    // Allows users to withdraw their Ether
    function withdraw(uint256 _amount) public {
        require(_amount > 0, "Withdrawal amount must be greater than 0");
        require(balances[msg.sender] >= _amount, "Insufficient funds");

        balances[msg.sender] -= _amount;
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Transfer failed");
    }

    // Function 3: checkBalance()
    // Allows users to check their own balance
    function checkBalance() public view returns (uint256) {
        return balances[msg.sender];
    }

    // Function 4: transfer()
    // Allows a user to transfer their "banked" funds to another user
    function transfer(address _to, uint256 _amount) public {
        require(_amount > 0, "Transfer amount must be greater than 0");
        require(balances[msg.sender] >= _amount, "Insufficient funds");

        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
    }
}