const { loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SimpleBank", function () {
  async function deploySimpleBankFixture() {
    const [owner, addr1, addr2] = await ethers.getSigners();
    const SimpleBank = await ethers.getContractFactory("SimpleBank");
    const simpleBank = await SimpleBank.deploy();
    return { simpleBank, owner, addr1, addr2 };
  }

  describe("Deployment", function () {
    it("should set the right owner", async function () {
      const { simpleBank, owner } = await loadFixture(deploySimpleBankFixture);
      expect(await simpleBank.owner()).to.equal(owner.address);
    });

    it("should start with total deposits equal to zero", async function () {
      const { simpleBank } = await loadFixture(deploySimpleBankFixture);
      expect(await simpleBank.totalDeposits()).to.equal(0);
    });

    it("should have zero contract balance at first", async function () {
      const { simpleBank } = await loadFixture(deploySimpleBankFixture);
      expect(await simpleBank.getTotalDeposits()).to.equal(0);
    });
  });

  describe("Deposit", function () {
    it("should accept deposits and increase user balance", async function () {
      const { simpleBank, addr1 } = await loadFixture(deploySimpleBankFixture);
      const amount = ethers.parseEther("1.0");

      await simpleBank.connect(addr1).deposit({ value: amount });

      const balance = await simpleBank.getBalance(addr1.address);
      expect(balance).to.equal(amount);
    });
  });

  describe("Withdraw", function () {
    it("should allow user to withdraw their funds", async function () {
      const { simpleBank, addr1 } = await loadFixture(deploySimpleBankFixture);
      const amount = ethers.parseEther("1.0");

      await simpleBank.connect(addr1).deposit({ value: amount });
      await simpleBank.connect(addr1).withdraw(ethers.parseEther("0.5"));

      const balance = await simpleBank.getBalance(addr1.address);
      expect(balance).to.equal(ethers.parseEther("0.5"));
    });
  });

  describe("Transfer", function () {
    it("should allow transfer between users", async function () {
      const { simpleBank, addr1, addr2 } = await loadFixture(deploySimpleBankFixture);
      await simpleBank.connect(addr1).deposit({ value: ethers.parseEther("1") });

      await simpleBank.connect(addr1).transfer(addr2.address, ethers.parseEther("0.4"));

      const balance1 = await simpleBank.getBalance(addr1.address);
      const balance2 = await simpleBank.getBalance(addr2.address);

      expect(balance1).to.equal(ethers.parseEther("0.6"));
      expect(balance2).to.equal(ethers.parseEther("0.4"));
    });
  });

  describe("Get Balance", function () {
    it("should return the correct balance for any account", async function () {
      const { simpleBank, addr1 } = await loadFixture(deploySimpleBankFixture);
      await simpleBank.connect(addr1).deposit({ value: ethers.parseEther("0.8") });

      const balance = await simpleBank.getBalance(addr1.address);
      expect(balance).to.equal(ethers.parseEther("0.8"));
    });
  });
});
