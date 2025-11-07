// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract SimpleBank { 
    mapping(address => uint256) private balances;
    address public owner;
    uint256 public totalDeposits;

    event Deposit(address indexed account, uint256 amount);
    event Withdraw(address indexed account, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

constructor() {
        owner = msg.sender;
    }

    function deposit() external payable {
        require(msg.value > 0, "Cannot deposit zero amount");
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        require(amount > 0, "cannot withdraw zero amount");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        
        balances[msg.sender] -= amount;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed.");
        totalDeposits -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }

  function getBalance(address account) external view returns (uint256) {
        return balances[account];
    }
    function getTotalDeposits() external view onlyOwner returns (uint256) {
        return totalDeposits;
    }
    

    function transfer(address recipient, uint256 amount) external {
        require(amount > 0, "Cannot transfer zero amount");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        require(recipient != address(0), "cannot transfer to zero address");

        balances[msg.sender] -= amount;
        balances[recipient] += amount;
    }





}
