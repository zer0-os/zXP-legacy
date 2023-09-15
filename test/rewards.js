const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("XP Vault", function () {
    let Token, token, Vault, vault, Controller, controller, owner, addr1, addr2;

    beforeEach(async function () {
        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

        Token = await ethers.getContractFactory("ERC20TestToken");
        token = await Token.deploy("Experience points", "XP"); // Assuming it has a standard ERC20 constructor

        Vault = await ethers.getContractFactory("WildVault");
        vault = await Vault.deploy(token.address, owner.address);

        Controller = await ethers.getContractFactory("ControllerContract");
        controller = await Controller.deploy(vault.address);
    });

    describe("Vault Operations", function () {
        it("Should allow deposit of tokens", async function () {
            await token.mint(addr1.address, ethers.utils.parseEther("10000"));
            await token.connect(addr1).approve(vault.address, ethers.utils.parseEther("500"));
            await expect(vault.connect(addr1).deposit(ethers.utils.parseEther("500")))
                .to.emit(vault, 'Deposited')
                .withArgs(addr1.address, ethers.utils.parseEther("500"));
        });

        it("Shouldn't allow non-controller to withdraw", async function () {
            await expect(vault.connect(addr1).withdraw(ethers.utils.parseEther("10")))
                .to.be.revertedWith("Not the controller");
        });

        it("Should allow controller to withdraw", async function () {
            await token.mint(addr1.address, ethers.utils.parseEther("100"));
            await token.connect(addr1).approve(vault.address, ethers.utils.parseEther("100"));
            await vault.connect(addr1).deposit(ethers.utils.parseEther("100"));

            await expect(vault.withdraw(ethers.utils.parseEther("50")))
                .to.emit(vault, 'Withdrawn')
                .withArgs(owner.address, ethers.utils.parseEther("50"));
        });
    });
});
