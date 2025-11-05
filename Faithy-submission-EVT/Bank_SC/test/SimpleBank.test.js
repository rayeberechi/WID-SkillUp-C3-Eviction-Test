const { expect } = require("chai");

const { ethers } = require("hardhat");



describe("SimpleBank", function () {

  let simpleBank;

  let owner;

  let addr1;



  beforeEach(async function () {

    // Get signers

    [owner, addr1] = await ethers.getSigners();



    // Deploy the contract

    const SimpleBank = await ethers.getContractFactory("SimpleBank");

    simpleBank = await SimpleBank.deploy();

  });



  it("Should allow a user to deposit Ether", async function () {

    // TODO:

    // 1. Send 1 Ether to the deposit() function from 'owner'

    // 2. Check if the contract's balance is 1 Ether

    // 3. Check if the 'owner's balance in the mapping is 1 Ether

  });



  it("Should allow a user to withdraw Ether", async function () {

    // TODO:

    // 1. Deposit 1 Ether first

    // 2. Call withdraw() to get 0.5 Ether

    // 3. Check if the owner's balance in the mapping is now 0.5 Ether

  });



  it("Should fail if user withdraws more than their balance", async function () {

    // TODO:

    // 1. Deposit 1 Ether

    // 2. Expect the call to withdraw(2 Ether) to be "reverted with" the error message

  });



  it("Should correctly check a user's balance", async function () {

    // TODO:

    // 1. Deposit 1 Ether

    // 2. Call checkBalance()

    // 3. Expect the result to be 1 Ether

  });



  it("Should allow a user to transfer to another address", async function () {

    // TODO:

    // 1. 'owner' deposits 1 Ether

    // 2. 'owner' calls transfer() to send 0.5 Ether to 'addr1'

    // 3. Check 'owner's balance in mapping (should be 0.5 Ether)

    // 4. Check 'addr1's balance in mapping (should be 0.5 Ether)

  });

});