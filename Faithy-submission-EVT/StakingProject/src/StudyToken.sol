// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

// This is a simple ERC20 token for testing
contract StudyToken is ERC20 {
    constructor() ERC20("StudyToken", "STUDY") {
        // Give 1 million tokens to the person who deploys this
        _mint(msg.sender, 1_000_000 * 10**18);
    }
}