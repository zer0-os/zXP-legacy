const { expect } = require("chai");
const { ethers } = require("hardhat");
require("@nomicfoundation/hardhat-chai-matchers");

describe("WWRace", function () {
    var p1signer;
    var p2signer;
    var P1;
    var P2;
    var WheelsRace;
    var wheelsInstance;

    before(async function () {
        const erc721wheelToken = await ethers.getContractFactory("ERC721TestToken");
        wheelsInstance = await erc721wheelToken.deploy('Wilder Wheels', 'WHL', {
            "id": 0,
            "description": "Wilder Wheels",
            "external_url": "0://wilder.wheels",
            "image": "wheel.png",
            "name": "Wilder Wheels"
        });
        await wheelsInstance.deployed();
    });

    beforeEach(async function () {
        [P1, P2, ...addrs] = await ethers.getSigners();
        p1signer = P1.address;
        p2signer = P2.address;

        const Race = await ethers.getContractFactory("WheelsRace");
        WheelsRace = await Race.deploy("Wheels Race", "v1", p1signer, wheelsInstance.address);
        await WheelsRace.deployed();
    });

    it("Should set correct values in the constructor", async function () {
        expect(await WheelsRace.wilderWorld()).to.equal(p1signer);
        expect(await WheelsRace.wheels()).to.equal(wheelsInstance.address);
    });

    it("Should stake the wheel correctly", async function () {
        await wheelsInstance.mint(p1signer);
        await wheelsInstance["safeTransferFrom(address,address,uint256)"](p1signer, WheelsRace.address, 0);

        expect(await WheelsRace.stakedBy(0)).to.equal(p1signer);
        expect(await WheelsRace.unstakeRequests(0)).to.equal(0);
    });

    it("Should not allow unstake without request", async function () {
        await wheelsInstance.mint(p1signer);
        await wheelsInstance["safeTransferFrom(address,address,uint256)"](p1signer, WheelsRace.address, 1);

        await expect(WheelsRace.connect(P1).performUnstake(1)).to.be.revertedWith("No unstake request");
    });

    it("Should allow unstake after request and delay", async function () {
        await wheelsInstance.mint(p1signer);
        await wheelsInstance["safeTransferFrom(address,address,uint256)"](p1signer, WheelsRace.address, 2);

        await WheelsRace.connect(P1).requestUnstake(2);
        await ethers.provider.send("evm_increaseTime", [24 * 60 * 60]);
        await ethers.provider.send("evm_mine");

        await WheelsRace.connect(P1).performUnstake(2);
        expect(await wheelsInstance.ownerOf(2)).to.equal(p1signer);
        expect(await WheelsRace.stakedBy(2)).to.equal(ethers.constants.AddressZero);
    });
    it("Should allow a player to claim a win", async function () {
        await wheelsInstance.mint(p1signer);
        await wheelsInstance.mint(p2signer);
        await wheelsInstance.connect(P1)["safeTransferFrom(address,address,uint256)"](p1signer, WheelsRace.address, 3);
        await wheelsInstance.connect(P2)["safeTransferFrom(address,address,uint256)"](p2signer, WheelsRace.address, 4);

        const raceStartDeclaration = {
            player: p2signer,
            opponent: p1signer,
            raceId: 1,
            wheelId: 4,
            raceStartTimestamp: Math.floor(Date.now() / 1000),
            raceExpiryTimestamp: Math.floor(Date.now() / 1000) + (60 * 60 * 24)
        };

        const raceStartDeclarationHash = await WheelsRace.createRaceStartDeclarationHash(raceStartDeclaration);
        const p2signature = await P2.signMessage(raceStartDeclarationHash);

        const winnerDeclaration = {
            winner: p1signer,
            raceId: 1,
            winTimestamp: Math.floor(Date.now() / 1000) + (60 * 60 * 24),
        };

        const winnerDeclarationHash = await WheelsRace.createWinDeclarationHash(winnerDeclaration);
        const wilderworldSignature = await P1.signMessage(ethers.utils.arrayify(winnerDeclarationHash));

        const s = await WheelsRace.connect(P1).claimWin(winnerDeclaration, wilderworldSignature, raceStartDeclaration, p2signature);
        console.log(s);
        expect(await wheelsInstance.ownerOf(3)).to.equal(p1signer);
        expect(await wheelsInstance.ownerOf(4)).to.equal(p2signer);
    });

});