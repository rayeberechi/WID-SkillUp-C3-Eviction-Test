const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SimpleBank", function () {
  let SimpleBank, bank, owner, addr1, addr2;

  beforeEach(async function () {
    SimpleBank = await ethers.getContractFactory("SimpleBank");
    [owner, addr1, addr2] = await ethers.getSigners();
    bank = await SimpleBank.deploy();
    await bank.waitForDeployment();
  });

  describe("Deposit", function () {
    it("should increase sender's balance after deposit", async function () {
      await bank.connect(addr1).deposit({ value: ethers.parseEther("1") });
      const balance = await bank.checkBalance(addr1.address);
      expect(balance).to.equal(ethers.parseEther("1"));
    });

    it("should fail for zero deposit", async function () {
      await expect(
        bank.connect(addr1).deposit({ value: 0 })
      ).to.be.revertedWith("Deposit must be greater than zero");
    });
  });

  describe("Withdraw", function () {
    it("should withdraw successfully when balance is sufficient", async function () {
      await bank.connect(addr1).deposit({ value: ethers.parseEther("1") });
      await expect(() =>
        bank.connect(addr1).withdraw(ethers.parseEther("0.5"))
      ).to.changeEtherBalances(
        [bank, addr1],
        [ethers.parseEther("-0.5"), ethers.parseEther("0.5")]
      );
      const balance = await bank.checkBalance(addr1.address);
      expect(balance).to.equal(ethers.parseEther("0.5"));
    });

    it("should fail when withdrawing more than balance", async function () {
      await bank.connect(addr1).deposit({ value: ethers.parseEther("0.4") });
      await expect(
        bank.connect(addr1).withdraw(ethers.parseEther("1"))
      ).to.be.revertedWith("Insufficient balance");
    });

    it("should fail for zero-value withdraw", async function () {
      await bank.connect(addr1).deposit({ value: ethers.parseEther("1") });
      await expect(
        bank.connect(addr1).withdraw(0)
      ).to.be.revertedWith("Amount must be greater than zero");
    });
  });

  describe("checkBalance", function () {
    it("should return correct balances for different users", async function () {
      await bank.connect(addr1).deposit({ value: ethers.parseEther("0.7") });
      await bank.connect(addr2).deposit({ value: ethers.parseEther("0.3") });
      expect(await bank.checkBalance(addr1.address)).to.equal(ethers.parseEther("0.7"));
      expect(await bank.checkBalance(addr2.address)).to.equal(ethers.parseEther("0.3"));
      expect(await bank.checkBalance(owner.address)).to.equal(ethers.parseEther("0"));
    });
  });

  describe("Transfer", function () {
    it("should transfer funds successfully between users", async function () {
      await bank.connect(addr1).deposit({ value: ethers.parseEther("1") });
      await bank.connect(addr1).transfer(addr2.address, ethers.parseEther("0.4"));
      expect(await bank.checkBalance(addr1.address)).to.equal(ethers.parseEther("0.6"));
      expect(await bank.checkBalance(addr2.address)).to.equal(ethers.parseEther("0.4"));
    });

    it("should fail when transferring more than sender's balance", async function () {
      await bank.connect(addr1).deposit({ value: ethers.parseEther("0.2") });
      await expect(
        bank.connect(addr1).transfer(addr2.address, ethers.parseEther("1"))
      ).to.be.revertedWith("Insufficient balance");
    });

    it("should fail for zero-value transfer", async function () {
      await bank.connect(addr1).deposit({ value: ethers.parseEther("1") });
      await expect(
        bank.connect(addr1).transfer(addr2.address, 0)
      ).to.be.revertedWith("Amount must be greater than zero");
    });

    it("should fail to transfer to zero address", async function () {
      await bank.connect(addr1).deposit({ value: ethers.parseEther("0.8") });
      await expect(
        bank.connect(addr1).transfer(ethers.ZeroAddress, ethers.parseEther("0.1"))
      ).to.be.revertedWith("Cannot transfer to zero address");
    });
  });
});