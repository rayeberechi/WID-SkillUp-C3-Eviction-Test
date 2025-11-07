const { expect } = require("chai");

describe("SimpleBank", function () {
  let SimpleBank, bank, owner, user1, user2;

  beforeEach(async function () {
    SimpleBank = await ethers.getContractFactory("SimpleBank");
    [owner, user1, user2] = await ethers.getSigners();
    bank = await SimpleBank.deploy();
    await bank.deployed();
  });

  it("should allow deposits", async function () {
    await bank.connect(user1).deposit({ value: ethers.utils.parseEther("1") });
    const balance = await bank.connect(user1).checkBalance();
    expect(balance).to.equal(ethers.utils.parseEther("1"));
  });

  it("should allow withdrawals", async function () {
    await bank.connect(user1).deposit({ value: ethers.utils.parseEther("2") });
    await bank.connect(user1).withdraw(ethers.utils.parseEther("1"));
    const balance = await bank.connect(user1).checkBalance();
    expect(balance).to.equal(ethers.utils.parseEther("1"));
  });

  it("should not allow withdrawal beyond balance", async function () {
    await expect(bank.connect(user1).withdraw(ethers.utils.parseEther("1"))).to.be.revertedWith("Insufficient balance");
  });

  it("should allow transfer between users", async function () {
    await bank.connect(user1).deposit({ value: ethers.utils.parseEther("2") });
    await bank.connect(user1).transfer(user2.address, ethers.utils.parseEther("1"));
    expect(await bank.connect(user1).checkBalance()).to.equal(ethers.utils.parseEther("1"));
    expect(await bank.connect(user2).checkBalance()).to.equal(ethers.utils.parseEther("1"));
  });

  it("should not allow transfer beyond balance", async function () {
    await expect(bank.connect(user1).transfer(user2.address, ethers.utils.parseEther("1"))).to.be.revertedWith("Insufficient balance");
  });
});
