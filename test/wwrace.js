const { expect } = require("chai");
const { ethers } = require("hardhat");
const {
    signTypedData,
    SignTypedDataVersion,
} = require("@metamask/eth-sig-util");
const axios = require('axios');

describe("WWRace", function () {
    var p1address;
    var p2address;
    var p1;
    var p2;
    var WheelsRace;
    var wheelsInstance;
    // Generate a random private key
    //const privateKey = randomBytes(32);
    //const signingKey = new ethers.utils.SigningKey(privateKey);

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
        [p1, p2] = await ethers.getSigners();
        p1address = p1.address;
        p2address = p2.address;

        const Race = await ethers.getContractFactory("WheelsRace");
        WheelsRace = await Race.deploy("Wheels Race", "1", p1address, wheelsInstance.address);
        await WheelsRace.deployed();
    });

    it("Should set correct values in the constructor", async function () {
        expect(await WheelsRace.wilderWorld()).to.equal(p1address);
        expect(await WheelsRace.wheels()).to.equal(wheelsInstance.address);
    });

    it("Should stake the wheel correctly", async function () {
        await wheelsInstance.mint(p1address);
        await wheelsInstance["safeTransferFrom(address,address,uint256)"](p1address, WheelsRace.address, 0);

        expect(await WheelsRace.stakedBy(0)).to.equal(p1address);
        expect((await WheelsRace.unstakeRequests(0)).toNumber()).to.equal(0);
    });

    it("Should not allow unstake without request", async function () {
        await wheelsInstance.mint(p1address); https://sepolia.etherscan.io/address/0x78f3a49919021a4769513ff8dd44fbedb487bd87
        await wheelsInstance["safeTransferFrom(address,address,uint256)"](p1address, WheelsRace.address, 1);

        await expect(WheelsRace.connect(p1).performUnstake(1)).to.be.reverted;
    });

    it("Should allow unstake after request and delay", async function () {
        await wheelsInstance.mint(p1address);
        await wheelsInstance["safeTransferFrom(address,address,uint256)"](p1address, WheelsRace.address, 2);

        await WheelsRace.connect(p1).requestUnstake(2);
        await ethers.provider.send("evm_increaseTime", [24 * 60 * 60]);
        await ethers.provider.send("evm_mine");

        await WheelsRace.connect(p1).performUnstake(2);
        expect(await wheelsInstance.ownerOf(2)).to.equal(p1address);
        expect(await WheelsRace.stakedBy(2)).to.equal(ethers.constants.AddressZero);
    });

    it("Should allow a player to claim a win", async function () {
        await wheelsInstance.mint(p1address);
        await wheelsInstance.mint(p2address);
        await wheelsInstance.connect(p1)["safeTransferFrom(address,address,uint256)"](p1address, WheelsRace.address, 3);
        await wheelsInstance.connect(p2)["safeTransferFrom(address,address,uint256)"](p2address, WheelsRace.address, 4);


        const raceSlip = {
            player: p2address,
            opponent: p1address,
            raceId: 1,
            wheelId: 4,
            raceStartTimestamp: Math.floor(Date.now() / 1000),
            raceExpiryTimestamp: Math.floor(Date.now() / 1000) + (60 * 60 * 24)
        };

        const domain = {
            name: 'Wheels Race',
            version: '1',
            chainId: (await ethers.provider.getNetwork()).chainId,
            verifyingContract: WheelsRace.address
        }
        const startTypes = {
            RaceSlip: [
                { name: 'player', type: 'address' },
                { name: 'opponent', type: 'address' },
                { name: 'raceId', type: 'uint256' },
                { name: 'wheelId', type: 'uint256' },
                { name: 'raceStartTimestamp', type: 'uint256' },
                { name: 'raceExpiryTimestamp', type: 'uint256' },
            ]
        }

        const p2signature = await p2._signTypedData(domain, startTypes, raceSlip);
        const wilderworldSignature = await p1._signTypedData(domain, startTypes, raceSlip);

        const s = await WheelsRace.connect(p1).claimWin(raceSlip, p2signature, wilderworldSignature);
        expect(await wheelsInstance.ownerOf(4)).to.equal(p1address);
    });

    it("Should not allow unstaking a wheel owned by someone else", async function () {
        await wheelsInstance.mint(p1address);
        await wheelsInstance["safeTransferFrom(address,address,uint256)"](p1address, WheelsRace.address, 4);
        await expect(WheelsRace.connect(p2).requestUnstake(4)).to.be.reverted;
    });

    it("Should not allow unstake request for a non-staked wheel", async function () {
        await expect(WheelsRace.connect(p1).requestUnstake(999)).to.be.reverted;
    });

    it("Should not allow claiming a win with invalid data", async function () {
        // populate winnerDeclaration and raceStartDeclaration with invalid data
        await expect(WheelsRace.connect(p1).claimWin([], "invalidSignature", "invalidSignature")).to.be.reverted;
    });

    it("API: Should get signature from wilderworld for win", async function () {
        const raceSlip = {
            player: p2address,
            opponent: p1address,
            raceId: 1,
            wheelId: 7,
            raceStartTimestamp: Math.floor(Date.now() / 1000),
            raceExpiryTimestamp: Math.floor(Date.now() / 1000) + (60 * 60 * 24)
        };

        const domain = {
            name: 'Wheels Race',
            version: '1',
            chainId: (await ethers.provider.getNetwork()).chainId,
            verifyingContract: WheelsRace.address
        }

        const startTypes = {
            RaceSlip: [
                { name: 'player', type: 'address' },
                { name: 'opponent', type: 'address' },
                { name: 'raceId', type: 'uint256' },
                { name: 'wheelId', type: 'uint256' },
                { name: 'raceStartTimestamp', type: 'uint256' },
                { name: 'raceExpiryTimestamp', type: 'uint256' },
            ]
        }

        const loserSlip = {
            domain: domain,
            types: startTypes,
            message: raceSlip
        }

        const p2signature = await p2._signTypedData(domain, startTypes, raceSlip);

        const response = await axios.post('http://localhost:8181/sign', { loserSlip }, {
            headers: { 'Content-Type': 'application/json' },
        })
            .then(function (response) {
                console.log(response.data);
                return response.data;
            })
            .catch(function (error) {
                console.log(error);
            });
        const wilderworldSignature = response.signature;
        console.log("wwsig: ", wilderworldSignature);
        const a = ethers.utils.verifyTypedData(domain, startTypes, raceSlip, wilderworldSignature);
        console.log("recovered: ", a);
    });

    it("API: should pass canRaceStart", async function () {
        const start = Math.floor(Date.now() / 1000);
        const expire = Math.floor(Date.now() / 1000) + (60 * 60 * 24);
        const raceSlip = {
            player: p1address,
            opponent: p2address,
            raceId: 1,
            wheelId: 7,
            raceStartTimestamp: start,
            raceExpiryTimestamp: expire
        };

        const domain = {
            name: 'Wheels Race',
            version: '1',
            chainId: (await ethers.provider.getNetwork()).chainId,
            verifyingContract: WheelsRace.address
        }

        const startTypes = {
            RaceSlip: [
                { name: 'player', type: 'address' },
                { name: 'opponent', type: 'address' },
                { name: 'raceId', type: 'uint256' },
                { name: 'wheelId', type: 'uint256' },
                { name: 'raceStartTimestamp', type: 'uint256' },
                { name: 'raceExpiryTimestamp', type: 'uint256' },
            ]
        }

        const raceSlipP2 = {
            player: p2address,
            opponent: p1address,
            raceId: 1,
            wheelId: 8,
            raceStartTimestamp: start,
            raceExpiryTimestamp: expire
        };

        const domainP2 = {
            name: 'Wheels Race',
            version: '1',
            chainId: (await ethers.provider.getNetwork()).chainId,
            verifyingContract: WheelsRace.address
        }

        const p1Slip = {
            domain: domain,
            types: startTypes,
            message: raceSlip
        }

        const p2Slip = {
            domain: domainP2,
            types: startTypes,
            message: raceSlipP2
        }

        const slips = { p1Slip, p2Slip }

        const response = await axios.post('http://localhost:8181/canRaceStart', slips, {
            headers: { 'Content-Type': 'application/json' },
        })
            .then(function (response) {
                console.log(response.data);
                return response.data;
            })
            .catch(function (error) {
                console.log(error);
            });
        console.log(response);
    });


});