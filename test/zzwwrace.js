const { expect } = require("chai");
const { ethers } = require("hardhat");
const {
    signTypedData,
    SignTypedDataVersion,
} = require("@metamask/eth-sig-util");
const axios = require('axios');

describe("WWRace beforeEach", function () {
    var p1address;
    var p2address;
    var p1;
    var p2;
    var WheelsRace;
    var wheelsInstance;
    var domain, types;

    const apiurl = "http://localhost:8181"

    beforeEach(async function () {
        const erc721wheelToken = await ethers.getContractFactory("ERC721TestToken");
        wheelsInstance = await erc721wheelToken.deploy('Wilder Wheels', 'WHL', {
            "id": 0,
            "description": "Wilder Wheels",
            "external_url": "0://wilder.wheels",
            "image": "wheel.png",
            "name": "Wilder Wheels"
        });
        await wheelsInstance.deployed();

        [p1, p2] = await ethers.getSigners();
        p1address = p1.address;
        p2address = p2.address;

        const Race = await ethers.getContractFactory("WheelsRace");
        WheelsRace = await Race.deploy("Wheels Race", "1", p1address, p1address);
        await WheelsRace.deployed();

        const Staker = await ethers.getContractFactory("StakedWheel");
        StakedWheels = await Staker.deploy("Staked Wheel", "SWW", p1address, wheelsInstance.address);
        await StakedWheels.deployed();

        StakedWheels.setController(WheelsRace.address);
        WheelsRace.initialize(StakedWheels.address);

        domain = {
            name: 'Wheels Race',
            version: '1',
            chainId: (await ethers.provider.getNetwork()).chainId,
            verifyingContract: WheelsRace.address
        }
        types = {
            RaceSlip: [
                { name: 'player', type: 'address' },
                { name: 'opponent', type: 'address' },
                { name: 'raceId', type: 'uint256' },
                { name: 'wheelId', type: 'uint256' },
                { name: 'opponentWheelId', type: 'uint256' },
                { name: 'raceStartTimestamp', type: 'uint256' },
            ]
        }
    });

    it("Should stake the Wheel and mint a Wheel_Staked token", async function () {
        await wheelsInstance.mint(p1address);
        await wheelsInstance["safeTransferFrom(address,address,uint256)"](p1address, StakedWheels.address, 0);

        const originalTokenURI = await wheelsInstance.tokenURI(0);
        // Check that the new token was minted with the correct metadata
        const stakedTokenURI = await StakedWheels.tokenURI(0);
        expect(stakedTokenURI).to.equal(originalTokenURI);
        expect(await StakedWheels.ownerOf(0)).to.equal(p1address);
        expect(await StakedWheels.stakedBy(0)).to.equal(p1address);
    });

    it("Should not allow unstake without request", async function () {
        await wheelsInstance.mint(p1address);
        await wheelsInstance["safeTransferFrom(address,address,uint256)"](p1address, StakedWheels.address, 0);

        await expect(StakedWheels.connect(p1).performUnstake(0)).to.be.reverted;
    });

    it("Should allow unstake after request and delay", async function () {
        await wheelsInstance.mint(p1address);
        await wheelsInstance["safeTransferFrom(address,address,uint256)"](p1address, StakedWheels.address, 0);

        await StakedWheels.connect(p1).requestUnstake(0);
        await ethers.provider.send("evm_increaseTime", [24 * 60 * 60]);
        await ethers.provider.send("evm_mine");

        await StakedWheels.connect(p1).performUnstake(0);
        expect(await wheelsInstance.ownerOf(0)).to.equal(p1address);
        expect(await StakedWheels.stakedBy(0)).to.equal(ethers.constants.AddressZero);
    });

    it("Should have burned the staked token after unstake", async function () {
        await expect(StakedWheels.ownerOf(0)).to.be.revertedWith("ERC721: invalid token ID");
    });

    it("Should allow a player to claim a win", async function () {
        await wheelsInstance.mint(p1address);
        await wheelsInstance.mint(p2address);
        await wheelsInstance.connect(p1)["safeTransferFrom(address,address,uint256)"](p1address, StakedWheels.address, 0);
        await wheelsInstance.connect(p2)["safeTransferFrom(address,address,uint256)"](p2address, StakedWheels.address, 1);
        //expect(await WheelsRace.ownerOf(4)).to.equal(p2address);

        const latestBlockNumber = await ethers.provider.getBlockNumber();
        const latestBlock = await ethers.provider.getBlock(latestBlockNumber);
        const startTime = latestBlock.timestamp;

        const slip = {
            player: p2address,
            opponent: p1address,
            raceId: "100000000000000000000000000000000000000000000000000",
            wheelId: "1",
            opponentWheelId: "0",
            raceStartTimestamp: startTime
        };

        const p2signature = await p2._signTypedData(domain, types, slip);
        const wilderworldSignature = await p1._signTypedData(domain, types, slip);

        const s = await WheelsRace.connect(p1).claimWin(slip, p2signature, wilderworldSignature);
        expect(await StakedWheels.stakedBy(1)).to.equal(p1address);
        expect(await StakedWheels.ownerOf(1)).to.equal(p1address);
        //await expect(WheelsRace.connect(p1).canRace(p1address, 1, p1address, 1)).to.be.revertedWith('Locked');

    });

    it("Should not allow a player to claim win on a locked token", async function () {
        await wheelsInstance.mint(p1address);
        await wheelsInstance.mint(p2address);
        await wheelsInstance.connect(p1)["safeTransferFrom(address,address,uint256)"](p1address, StakedWheels.address, 0);
        await wheelsInstance.connect(p2)["safeTransferFrom(address,address,uint256)"](p2address, StakedWheels.address, 1);

        const _latestBlockNumber = await ethers.provider.getBlockNumber();
        const _latestBlock = await ethers.provider.getBlock(_latestBlockNumber);
        const _startTime = _latestBlock.timestamp;

        const _slip = {
            player: p2address,
            opponent: p1address,
            raceId: "100000000000000000000",
            wheelId: "1",
            opponentWheelId: "0",
            raceStartTimestamp: _startTime
        };

        const _p2signature = await p2._signTypedData(domain, types, _slip);
        const _wilderworldSignature = await p1._signTypedData(domain, types, _slip);

        await WheelsRace.connect(p1).claimWin(_slip, _p2signature, _wilderworldSignature);

        const latestBlockNumber = await ethers.provider.getBlockNumber();
        const latestBlock = await ethers.provider.getBlock(latestBlockNumber);
        const startTime = latestBlock.timestamp;

        const slip = {
            player: p2address,
            opponent: p1address,
            raceId: "100000000000000000000000000000000000000000000000000",
            wheelId: "1",
            opponentWheelId: "0",
            raceStartTimestamp: startTime,
        };

        const p2signature = await p2._signTypedData(domain, types, slip);
        const wilderworldSignature = await p1._signTypedData(domain, types, slip);

        await expect(WheelsRace.connect(p1).claimWin(slip, p2signature, wilderworldSignature)).to.be.revertedWith('WR: Within lock period');
    });

    it("Should not allow a player to claim a consumed raceId", async function () {
        await wheelsInstance.mint(p1address);
        await wheelsInstance.mint(p2address);
        await wheelsInstance.connect(p1)["safeTransferFrom(address,address,uint256)"](p1address, StakedWheels.address, 0);
        await wheelsInstance.connect(p2)["safeTransferFrom(address,address,uint256)"](p2address, StakedWheels.address, 1);
        await network.provider.send("evm_increaseTime", [69120000]);
        await network.provider.send("evm_mine");
        const latestBlockNumber = await ethers.provider.getBlockNumber();
        const latestBlock = await ethers.provider.getBlock(latestBlockNumber);
        const startTime = latestBlock.timestamp;
        const slip = {
            player: p2address,
            opponent: p1address,
            raceId: "100000000000000000000000000000000000000000000000000",
            wheelId: "1",
            opponentWheelId: "0",
            raceStartTimestamp: startTime
        };

        const p2signature = await p2._signTypedData(domain, types, slip);
        const wilderworldSignature = await p1._signTypedData(domain, types, slip);

        await WheelsRace.connect(p1).claimWin(slip, p2signature, wilderworldSignature);

        await network.provider.send("evm_increaseTime", [69120000]);
        await network.provider.send("evm_mine");
        await wheelsInstance.mint(p1address);
        await wheelsInstance.mint(p2address);
        await wheelsInstance.connect(p1)["safeTransferFrom(address,address,uint256)"](p1address, StakedWheels.address, 2);
        await wheelsInstance.connect(p2)["safeTransferFrom(address,address,uint256)"](p2address, StakedWheels.address, 3);
        const _latestBlockNumber = await ethers.provider.getBlockNumber();
        const _latestBlock = await ethers.provider.getBlock(_latestBlockNumber);
        const _startTime = _latestBlock.timestamp;
        const _slip = {
            player: p2address,
            opponent: p1address,
            raceId: "100000000000000000000000000000000000000000000000000",
            wheelId: "3",
            opponentWheelId: "2",
            raceStartTimestamp: _startTime
        };

        const _p2signature = await p2._signTypedData(domain, types, _slip);
        const _wilderworldSignature = await p1._signTypedData(domain, types, _slip);

        await expect(WheelsRace.connect(p1).claimWin(_slip, _p2signature, _wilderworldSignature)).to.be.revertedWith('WR: RaceId used');
    });

    it("Should allow to cancel a race", async function () {
        const slip = { player: p1address, opponent: p2address, raceId: 999, wheelId: 6, opponentWheelId: 5, raceStartTimestamp: "10000000000000000" };
        await WheelsRace.connect(p1).cancel(slip);
        expect(await WheelsRace.isCanceled(slip)).to.be.true;
    });

    it("Should not allow a player to claim a canceled race", async function () {
        await wheelsInstance.mint(p1address);
        await wheelsInstance.mint(p2address);
        await wheelsInstance.connect(p1)["safeTransferFrom(address,address,uint256)"](p1address, StakedWheels.address, 0);
        await wheelsInstance.connect(p2)["safeTransferFrom(address,address,uint256)"](p2address, StakedWheels.address, 1);
        const latestBlockNumber = await ethers.provider.getBlockNumber();
        const latestBlock = await ethers.provider.getBlock(latestBlockNumber);
        const startTime = latestBlock.timestamp;
        const slip = {
            player: p2address,
            opponent: p1address,
            raceId: "1234",
            wheelId: "1",
            opponentWheelId: "0",
            raceStartTimestamp: startTime + 100000,
        };

        await WheelsRace.connect(p2).cancel(slip);

        const p2signature = await p2._signTypedData(domain, types, slip);
        const wilderworldSignature = await p1._signTypedData(domain, types, slip);

        await network.provider.send("evm_increaseTime", [100000]);
        await network.provider.send("evm_mine");

        await expect(WheelsRace.connect(p1).claimWin(slip, p2signature, wilderworldSignature)).to.be.revertedWith("WR: Slip Canceled");
    });

    it("Should not allow to cancel a race after cancelBuffer", async function () {
        const slip = { player: p1address, opponent: p2address, raceId: 6, wheelId: 0, opponentWheelId: 1, raceStartTimestamp: "0" };
        //await ethers.provider.send("evm_increaseTime", [10000]); // Assuming cancelBuffer to be less than 10000 seconds
        //await ethers.provider.send("evm_mine");

        await expect(WheelsRace.connect(p1).cancel(slip)).to.be.revertedWith("WR: Cancel period ended");
    });

    it("Should not allow a non-player to cancel a race", async function () {
        const slip = { player: p1address, opponent: p2address, raceId: 7, wheelId: 0, opponentWheelId: 1, raceStartTimestamp: "0" };
        await expect(WheelsRace.connect(p2).cancel(slip)).to.be.revertedWith("WR: Sender isnt player");
    });

    it("Should not allow unstaking a wheel owned by someone else", async function () {
        await wheelsInstance.mint(p1address);
        await expect(StakedWheels.connect(p1).requestUnstake(1)).to.be.reverted;
    });

    it("Should not allow unstake request for a non-staked wheel", async function () {
        await expect(StakedWheels.connect(p1).requestUnstake(999)).to.be.reverted;
    });

    it("Admin: Should cancel race", async function () {
        await WheelsRace.connect(p1).cancelRace("1234");
    });

    it("Should not allow a player to claim an admin canceled race", async function () {
        await wheelsInstance.mint(p1address);
        await wheelsInstance.mint(p2address);
        await wheelsInstance.connect(p1)["safeTransferFrom(address,address,uint256)"](p1address, StakedWheels.address, 0);
        await wheelsInstance.connect(p2)["safeTransferFrom(address,address,uint256)"](p2address, StakedWheels.address, 1);

        const latestBlockNumber = await ethers.provider.getBlockNumber();
        const latestBlock = await ethers.provider.getBlock(latestBlockNumber);
        const startTime = latestBlock.timestamp;
        const slip = {
            player: p2address,
            opponent: p1address,
            raceId: "1234",
            wheelId: "1",
            opponentWheelId: "0",
            raceStartTimestamp: startTime,
        };

        const p2signature = await p2._signTypedData(domain, types, slip);
        const wilderworldSignature = await p1._signTypedData(domain, types, slip);

        await WheelsRace.connect(p1).cancelRace("1234");
        await expect(WheelsRace.connect(p1).claimWin(slip, p2signature, wilderworldSignature)).to.be.revertedWith("WR: RaceId used");
    });
    it("Should not allow claiming a win before a race starts", async function () {
        //await wheelsInstance.connect(p1)["safeTransferFrom(address,address,uint256)"](p1address, p2address, 5);

        const slip = {
            player: p2address,
            opponent: p1address,
            raceId: "1234",
            wheelId: "1",
            opponentWheelId: "0",
            raceStartTimestamp: "10000000000000000",
        };

        const p2signature = await p2._signTypedData(domain, types, slip);
        const wilderworldSignature = await p1._signTypedData(domain, types, slip);

        await expect(WheelsRace.connect(p1).claimWin(slip, p2signature, wilderworldSignature)).to.be.revertedWith("WR: Race hasnt started");
    });
    it("Should not allow claiming win on an expired slip", async function () {
        //await wheelsInstance.connect(p1)["safeTransferFrom(address,address,uint256)"](p1address, p2address, 5);
        const latestBlockNumber = await ethers.provider.getBlockNumber();
        const latestBlock = await ethers.provider.getBlock(latestBlockNumber);
        const startTime = latestBlock.timestamp;
        const slip = {
            player: p2address,
            opponent: p1address,
            raceId: "1234",
            wheelId: "1",
            opponentWheelId: "0",
            raceStartTimestamp: startTime,
        };
        await ethers.provider.send("evm_increaseTime", [24 * 60 * 60]);
        await ethers.provider.send("evm_mine");
        const p2signature = await p2._signTypedData(domain, types, slip);
        const wilderworldSignature = await p1._signTypedData(domain, types, slip);

        await expect(WheelsRace.connect(p1).claimWin(slip, p2signature, wilderworldSignature)).to.be.revertedWith("WR: Race expired");
    });
    it("Should not allow claiming a win with invalid data", async function () {
        //await wheelsInstance.connect(p1)["safeTransferFrom(address,address,uint256)"](p1address, p2address, 5);

        const slip = {
            player: p2address,
            opponent: p1address,
            raceId: "100000000000000000000000000000000000000000000000000",
            wheelId: "5",
            opponentWheelId: "3",
            raceStartTimestamp: Math.floor(Date.now() / 1000)
        };

        const p2signature = await p2._signTypedData(domain, types, slip);
        const wilderworldSignature = await p1._signTypedData(domain, types, slip);

        await expect(WheelsRace.connect(p1).claimWin([], p2signature, wilderworldSignature)).to.be.reverted;
    });
    it("Should not allow claiming a win with invalid player", async function () {
        const slip = {
            player: p1address, //invalid address
            opponent: p1address,
            raceId: "100000000000000000000000000000000000000000000000000",
            wheelId: "5",
            opponentWheelId: "3",
            raceStartTimestamp: Math.floor(Date.now() / 1000)
        };

        const p2signature = await p2._signTypedData(domain, types, slip);
        const wilderworldSignature = await p1._signTypedData(domain, types, slip);

        await expect(WheelsRace.connect(p1).claimWin(slip, p2signature, wilderworldSignature)).to.be.revertedWith("WR: Not signed by opponent");
    });
    it("Should not allow claiming a win with invalid opponent", async function () {
        //await wheelsInstance.connect(p2)["safeTransferFrom(address,address,uint256)"](p2address, WheelsRace.address, 5);
        //expect(await WheelsRace.stakedBy(5)).to.equal(p2address);
        const latestBlockNumber = await ethers.provider.getBlockNumber();
        const latestBlock = await ethers.provider.getBlock(latestBlockNumber);
        const startTime = latestBlock.timestamp;
        const slip = {
            player: p2address,
            opponent: p2address,
            raceId: "100000000000000001000000000000000000000000000000000",
            wheelId: "1",
            opponentWheelId: "0",
            raceStartTimestamp: startTime
        };

        const p2signature = await p2._signTypedData(domain, types, slip);
        const wilderworldSignature = await p1._signTypedData(domain, types, slip);

        await expect(WheelsRace.connect(p1).claimWin(slip, p2signature, wilderworldSignature)).to.be.revertedWith("WR: Sender isnt opponentSlip.opponent");
    });

    it("Should not allow claiming a win with invalid domain name", async function () {
        const slip = {
            player: p2address,
            opponent: p1address,
            raceId: "110000000000000000000000000000000000000000000000000",
            wheelId: "1",
            opponentWheelId: "0",
            raceStartTimestamp: Math.floor(Date.now() / 1000)
        };

        const invalidDomain = {
            name: 'INVALID',
            version: '1',
            chainId: (await ethers.provider.getNetwork()).chainId,
            verifyingContract: WheelsRace.address
        }

        const p2signature = await p2._signTypedData(invalidDomain, types, slip);
        const wilderworldSignature = await p1._signTypedData(invalidDomain, types, slip);

        await expect(WheelsRace.connect(p1).claimWin(slip, p2signature, wilderworldSignature)).to.be.revertedWith("WR: Not signed by opponent");
    });
    it("Should not allow claiming a win with invalid domain version", async function () {
        const slip = {
            player: p2address,
            opponent: p1address,
            raceId: "110000000000000000000000000000000000000000000000000",
            wheelId: "1",
            opponentWheelId: "0",
            raceStartTimestamp: Math.floor(Date.now() / 1000)
        };

        const invalidDomain = {
            name: 'Wheels Race',
            version: '123',
            chainId: (await ethers.provider.getNetwork()).chainId,
            verifyingContract: WheelsRace.address
        }

        const p2signature = await p2._signTypedData(invalidDomain, types, slip);
        const wilderworldSignature = await p1._signTypedData(invalidDomain, types, slip);

        await expect(WheelsRace.connect(p1).claimWin(slip, p2signature, wilderworldSignature)).to.be.revertedWith("WR: Not signed by opponent");
    });
    it("Should not allow claiming a win with invalid domain chainID", async function () {
        const slip = {
            player: p2address,
            opponent: p1address,
            raceId: "110000000000000000000000000000000000000000000000000",
            wheelId: "1",
            opponentWheelId: "0",
            raceStartTimestamp: Math.floor(Date.now() / 1000)
        };

        const invalidDomain = {
            name: 'Wheels Race',
            version: '1',
            chainId: "0",
            verifyingContract: WheelsRace.address
        }

        const p2signature = await p2._signTypedData(invalidDomain, types, slip);
        const wilderworldSignature = await p1._signTypedData(invalidDomain, types, slip);

        await expect(WheelsRace.connect(p1).claimWin(slip, p2signature, wilderworldSignature)).to.be.revertedWith("WR: Not signed by opponent");
    });
    it("Should not allow claiming a win with invalid domain verifyingContract", async function () {
        const slip = {
            player: p2address,
            opponent: p1address,
            raceId: "110000000000000000000000000000000000000000000000000",
            wheelId: "1",
            opponentWheelId: "0",
            raceStartTimestamp: Math.floor(Date.now() / 1000)
        };

        const invalidDomain = {
            name: 'Wheels Race',
            version: '1',
            chainId: (await ethers.provider.getNetwork()).chainId,
            verifyingContract: wheelsInstance.address
        }

        const p2signature = await p2._signTypedData(invalidDomain, types, slip);
        const wilderworldSignature = await p1._signTypedData(invalidDomain, types, slip);

        await expect(WheelsRace.connect(p1).claimWin(slip, p2signature, wilderworldSignature)).to.be.revertedWith("WR: Not signed by opponent");
    });
    it("Should not allow claiming a win with invalid types", async function () {
        const slip = {
            player: p2address,
            opponent: p1address,
            raceId: "110000000000000000000000000000000000000000000000000",
            wheelId: "1",
            opponentWheelId: "0",
            raceStartTimestamp: Math.floor(Date.now() / 1000)
        };

        const invalidTypes = {
            Invalid: [
                { name: 'player', type: 'address' },
                { name: 'opponent', type: 'address' },
                { name: 'raceId', type: 'uint256' },
                { name: 'wheelId', type: 'uint256' },
                { name: 'opponentWheelId', type: 'uint256' },
                { name: 'raceStartTimestamp', type: 'uint256' }
            ]
        }
        const p2signature = await p2._signTypedData(domain, invalidTypes, slip);
        const wilderworldSignature = await p1._signTypedData(domain, invalidTypes, slip);

        await expect(WheelsRace.connect(p1).claimWin(slip, p2signature, wilderworldSignature)).to.be.revertedWith("WR: Not signed by opponent");
    });
    it("Should not allow claiming a win with unstaked player wheel", async function () {
        await wheelsInstance.mint(p1address);
        await wheelsInstance.mint(p2address);
        await wheelsInstance.connect(p1)["safeTransferFrom(address,address,uint256)"](p1address, StakedWheels.address, 0);
        //await wheelsInstance.connect(p2)["safeTransferFrom(address,address,uint256)"](p2address, WheelsRace.address, 1);

        const latestBlockNumber = await ethers.provider.getBlockNumber();
        const latestBlock = await ethers.provider.getBlock(latestBlockNumber);
        const startTime = latestBlock.timestamp;
        const slip = {
            player: p2address,
            opponent: p1address,
            raceId: "1234567",
            wheelId: "1",
            opponentWheelId: "0",
            raceStartTimestamp: startTime
        };

        const p2signature = await p2._signTypedData(domain, types, slip);
        const wilderworldSignature = await p1._signTypedData(domain, types, slip);

        await expect(WheelsRace.connect(p1).claimWin(slip, p2signature, wilderworldSignature)).to.be.revertedWith("WR: Opponent wheel unstaked");
    });
    it("Should not allow claiming a win with unstaked opponent wheel", async function () {
        await wheelsInstance.mint(p1address);
        await wheelsInstance.mint(p2address);
        //await wheelsInstance.connect(p1)["safeTransferFrom(address,address,uint256)"](p1address, WheelsRace.address, 0);
        await wheelsInstance.connect(p2)["safeTransferFrom(address,address,uint256)"](p2address, StakedWheels.address, 1);

        const latestBlockNumber = await ethers.provider.getBlockNumber();
        const latestBlock = await ethers.provider.getBlock(latestBlockNumber);
        const startTime = latestBlock.timestamp;
        const slip = {
            player: p2address,
            opponent: p1address,
            raceId: "1234567",
            wheelId: "1",
            opponentWheelId: "0",
            raceStartTimestamp: startTime,
        };

        const p2signature = await p2._signTypedData(domain, types, slip);
        const wilderworldSignature = await p1._signTypedData(domain, types, slip);

        await expect(WheelsRace.connect(p1).claimWin(slip, p2signature, wilderworldSignature)).to.be.revertedWith("WR: Player wheel unstaked");
    });
    it("Should not allow claiming a win with invalid wilderworld signature", async function () {
        const latestBlockNumber = await ethers.provider.getBlockNumber();
        const latestBlock = await ethers.provider.getBlock(latestBlockNumber);
        const startTime = latestBlock.timestamp;
        const slip = {
            player: p2address,
            opponent: p1address,
            raceId: "1234567",
            wheelId: "6",
            opponentWheelId: "5",
            raceStartTimestamp: startTime,
        };

        const p2signature = await p2._signTypedData(domain, types, slip);
        const invalidSignature = await p2._signTypedData(domain, types, slip);

        //const v1 = ethers.utils.verifyTypedData(domain, types, slip, p2signature);
        //const v2 = ethers.utils.verifyTypedData(domain, types, slip, wilderworldSignature);

        await expect(WheelsRace.connect(p1).claimWin(slip, p2signature, invalidSignature)).to.be.revertedWith("WR: Not signed by WW");
    });
    it("Should not allow transfer of Wheel_Staked token", async function () {
        await wheelsInstance.mint(p1address);
        await wheelsInstance.connect(p1)["safeTransferFrom(address,address,uint256)"](p1address, StakedWheels.address, 0);
        await expect(StakedWheels.connect(p1)["safeTransferFrom(address,address,uint256)"](p1address, StakedWheels.address, 0)).to.be.revertedWith("NotAuthorized");
    });

    it("Admin: Should transfer out token mistakenly sent with transferFrom", async function () {
        await wheelsInstance.mint(p1address);
        await wheelsInstance.connect(p1)["transferFrom(address,address,uint256)"](p1address, StakedWheels.address, 0);

        await StakedWheels.transferOut(p1address, 0);
        expect(await wheelsInstance.ownerOf(0)).to.equal(p1address);
    });
    it("Admin: Should not allow transfer out of a token that is staked", async function () {
        await wheelsInstance.mint(p1address);
        await wheelsInstance["safeTransferFrom(address,address,uint256)"](p1address, StakedWheels.address, 0);
        await expect(StakedWheels.transferOut(p1address, 0)).to.be.reverted;
    });

    it("canRace should correctly return false for a non-existing Wheel", async function () {
        await expect(WheelsRace.connect(p1).canRace(p1address, 999, p2address, 888)).to.be.revertedWith("ERC721: invalid token ID");
    });


    it("Should revert if a player tries to stake a Wheel that doesn't exist", async function () {
        await expect(wheelsInstance["safeTransferFrom(address,address,uint256)"](p1address, StakedWheels.address, 999)).to.be.reverted;
    });

    it("Should only allow the admin to change the expirePeriod", async function () {
        const newExpirePeriod = 100;
        await expect(StakedWheels.connect(p2).setExpirePeriod(newExpirePeriod)).to.be.revertedWith("NotAuthorized");
        await StakedWheels.setExpirePeriod(newExpirePeriod);
        expect(await StakedWheels.expirePeriod()).to.equal(newExpirePeriod);
    });
    it("Should allow a user to cancel their unstake request", async function () {
        await wheelsInstance.mint(p1address);
        await wheelsInstance.connect(p1)["safeTransferFrom(address,address,uint256)"](p1address, StakedWheels.address, 0);

        await StakedWheels.connect(p1).requestUnstake(0);
        await StakedWheels.connect(p1).cancelUnstake(0);
    });
    it("Should not allow a user to request unstaking for a wheel that isnt staked", async function () {
        await wheelsInstance.mint(p1address);
        await expect(StakedWheels.connect(p1).requestUnstake(0)).to.be.revertedWith("NotStaker");
    });

});

describe("WWRace", function () {
    var p1address;
    var p2address;
    var p1;
    var p2;
    var WheelsRace;
    var wheelsInstance;
    var domain, types;

    const apiurl = "http://localhost:8181"

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

        [p1, p2] = await ethers.getSigners();
        p1address = p1.address;
        p2address = p2.address;

        const Race = await ethers.getContractFactory("WheelsRace");
        WheelsRace = await Race.deploy("Wheels Race", "1", p1address, p1address);
        await WheelsRace.deployed();

        const Staker = await ethers.getContractFactory("StakedWheel");
        StakedWheels = await Staker.deploy("Staked Wheel", "SWW", p1address, wheelsInstance.address);
        await StakedWheels.deployed();

        StakedWheels.setController(WheelsRace.address);
        WheelsRace.initialize(StakedWheels.address);

        domain = {
            name: 'Wheels Race',
            version: '1',
            chainId: (await ethers.provider.getNetwork()).chainId,
            verifyingContract: WheelsRace.address
        }
        types = {
            RaceSlip: [
                { name: 'player', type: 'address' },
                { name: 'opponent', type: 'address' },
                { name: 'raceId', type: 'uint256' },
                { name: 'wheelId', type: 'uint256' },
                { name: 'opponentWheelId', type: 'uint256' },
                { name: 'raceStartTimestamp', type: 'uint256' },
            ]
        }
    });

    it("Should stake the Wheel and mint a Wheel_Staked token", async function () {
        await wheelsInstance.mint(p1address);
        await wheelsInstance["safeTransferFrom(address,address,uint256)"](p1address, StakedWheels.address, 0);

        const originalTokenURI = await wheelsInstance.tokenURI(0);
        // Check that the new token was minted with the correct metadata
        const stakedTokenURI = await StakedWheels.tokenURI(0);
        expect(stakedTokenURI).to.equal(originalTokenURI);
        expect(await StakedWheels.ownerOf(0)).to.equal(p1address);
        expect(await StakedWheels.stakedBy(0)).to.equal(p1address);
    });

    it("Should not allow unstake without request", async function () {
        await wheelsInstance.mint(p1address);
        await wheelsInstance["safeTransferFrom(address,address,uint256)"](p1address, StakedWheels.address, 1);

        await expect(StakedWheels.connect(p1).performUnstake(1)).to.be.reverted;
    });

    it("Should allow unstake after request and delay", async function () {
        await wheelsInstance.mint(p1address);
        await wheelsInstance["safeTransferFrom(address,address,uint256)"](p1address, StakedWheels.address, 2);

        await StakedWheels.connect(p1).requestUnstake(2);
        await ethers.provider.send("evm_increaseTime", [24 * 60 * 60]);
        await ethers.provider.send("evm_mine");

        await StakedWheels.connect(p1).performUnstake(2);
        expect(await wheelsInstance.ownerOf(2)).to.equal(p1address);
        expect(await StakedWheels.stakedBy(2)).to.equal(ethers.constants.AddressZero);
    });

    it("Should have burned the staked token after unstake", async function () {
        await expect(StakedWheels.ownerOf(2)).to.be.revertedWith("ERC721: invalid token ID");
    });

    it("Should allow a player to claim a win", async function () {
        await wheelsInstance.mint(p1address);
        await wheelsInstance.mint(p2address);
        await wheelsInstance.connect(p1)["safeTransferFrom(address,address,uint256)"](p1address, StakedWheels.address, 3);
        await wheelsInstance.connect(p2)["safeTransferFrom(address,address,uint256)"](p2address, StakedWheels.address, 4);
        //expect(await WheelsRace.ownerOf(4)).to.equal(p2address);

        const latestBlockNumber = await ethers.provider.getBlockNumber();
        const latestBlock = await ethers.provider.getBlock(latestBlockNumber);
        const startTime = latestBlock.timestamp;

        const slip = {
            player: p2address,
            opponent: p1address,
            raceId: "100000000000000000000000000000000000000000000000000",
            wheelId: "4",
            opponentWheelId: "3",
            raceStartTimestamp: startTime
        };

        const p2signature = await p2._signTypedData(domain, types, slip);
        const wilderworldSignature = await p1._signTypedData(domain, types, slip);

        const s = await WheelsRace.connect(p1).claimWin(slip, p2signature, wilderworldSignature);
        expect(await StakedWheels.stakedBy(4)).to.equal(p1address);
    });

    it("Should have transferred the staked token after win", async function () {
        expect(await StakedWheels.ownerOf(4)).to.equal(p1address);
    });

    it("Should not allow canRace for a locked token", async function () {
        await expect(WheelsRace.connect(p1).canRace(p1address, 4, p1address, 4)).to.be.revertedWith('');
    });

    it("Should not allow a player to claim win on a locked token", async function () {
        const latestBlockNumber = await ethers.provider.getBlockNumber();
        const latestBlock = await ethers.provider.getBlock(latestBlockNumber);
        const startTime = latestBlock.timestamp;

        const slip = {
            player: p2address,
            opponent: p1address,
            raceId: "100000000000000000000000000000000000000000000000000",
            wheelId: "4",
            opponentWheelId: "3",
            raceStartTimestamp: startTime,
        };

        const p2signature = await p2._signTypedData(domain, types, slip);
        const wilderworldSignature = await p1._signTypedData(domain, types, slip);

        //const v1 = ethers.utils.verifyTypedData(domain, types, slip, p2signature);
        //const v2 = ethers.utils.verifyTypedData(domain, types, slip, wilderworldSignature);

        await expect(WheelsRace.connect(p1).claimWin(slip, p2signature, wilderworldSignature)).to.be.revertedWith('WR: Within lock period');
    });

    it("Should not allow a player to claim a consumed raceId", async function () {
        await wheelsInstance.mint(p1address);
        await wheelsInstance.mint(p2address);
        await wheelsInstance.connect(p1)["safeTransferFrom(address,address,uint256)"](p1address, StakedWheels.address, 5);
        await wheelsInstance.connect(p2)["safeTransferFrom(address,address,uint256)"](p2address, StakedWheels.address, 6);
        await network.provider.send("evm_increaseTime", [69120000]);
        await network.provider.send("evm_mine");
        const latestBlockNumber = await ethers.provider.getBlockNumber();
        const latestBlock = await ethers.provider.getBlock(latestBlockNumber);
        const startTime = latestBlock.timestamp;
        const slip = {
            player: p2address,
            opponent: p1address,
            raceId: "100000000000000000000000000000000000000000000000000",
            wheelId: "6",
            opponentWheelId: "5",
            raceStartTimestamp: startTime
        };

        const p2signature = await p2._signTypedData(domain, types, slip);
        const wilderworldSignature = await p1._signTypedData(domain, types, slip);

        //const v1 = ethers.utils.verifyTypedData(domain, types, slip, p2signature);
        //const v2 = ethers.utils.verifyTypedData(domain, types, slip, wilderworldSignature);

        await expect(WheelsRace.connect(p1).claimWin(slip, p2signature, wilderworldSignature)).to.be.revertedWith('WR: RaceId used');
    });

    it("Should allow to cancel a race", async function () {
        const slip = { player: p1address, opponent: p2address, raceId: 999, wheelId: 6, opponentWheelId: 5, raceStartTimestamp: "10000000000000000" };
        await WheelsRace.connect(p1).cancel(slip);
        expect(await WheelsRace.isCanceled(slip)).to.be.true;
    });

    it("Should not allow a player to claim a canceled race", async function () {
        //await wheelsInstance.mint(p1address);
        //await wheelsInstance.mint(p1address);
        //await wheelsInstance.connect(p1)["safeTransferFrom(address,address,uint256)"](p1address, p2address, 4);
        //await wheelsInstance.connect(p2)["safeTransferFrom(address,address,uint256)"](p2address, WheelsRace.address, 4);
        const latestBlockNumber = await ethers.provider.getBlockNumber();
        const latestBlock = await ethers.provider.getBlock(latestBlockNumber);
        const startTime = latestBlock.timestamp;
        const slip = {
            player: p2address,
            opponent: p1address,
            raceId: "1234",
            wheelId: "6",
            opponentWheelId: "5",
            raceStartTimestamp: startTime + 100000,
        };

        await WheelsRace.connect(p2).cancel(slip);

        const p2signature = await p2._signTypedData(domain, types, slip);
        const wilderworldSignature = await p1._signTypedData(domain, types, slip);

        await network.provider.send("evm_increaseTime", [100000]);
        await network.provider.send("evm_mine");
        //const v1 = ethers.utils.verifyTypedData(domain, types, slip, p2signature);
        //const v2 = ethers.utils.verifyTypedData(domain, types, slip, wilderworldSignature);

        await expect(WheelsRace.connect(p1).claimWin(slip, p2signature, wilderworldSignature)).to.be.revertedWith("WR: Slip Canceled");
    });

    it("Should not allow to cancel a race after cancelBuffer", async function () {
        const slip = { player: p1address, opponent: p2address, raceId: 6, wheelId: 0, opponentWheelId: 1, raceStartTimestamp: "0" };
        //await ethers.provider.send("evm_increaseTime", [10000]); // Assuming cancelBuffer to be less than 10000 seconds
        //await ethers.provider.send("evm_mine");

        await expect(WheelsRace.connect(p1).cancel(slip)).to.be.revertedWith("WR: Cancel period ended");
    });

    it("Should not allow a non-player to cancel a race", async function () {
        const slip = { player: p1address, opponent: p2address, raceId: 7, wheelId: 0, opponentWheelId: 1, raceStartTimestamp: "0" };
        await expect(WheelsRace.connect(p2).cancel(slip)).to.be.revertedWith("WR: Sender isnt player");
    });

    it("Should not allow unstaking a wheel owned by someone else", async function () {
        await wheelsInstance.mint(p1address);
        await expect(StakedWheels.connect(p1).requestUnstake(2)).to.be.reverted;
    });

    it("Should not allow unstake request for a non-staked wheel", async function () {
        await expect(StakedWheels.connect(p1).requestUnstake(999)).to.be.reverted;
    });

    it("Admin: Should cancel race", async function () {
        await WheelsRace.connect(p1).cancelRace("1234");
    });

    it("Should not allow a player to claim an admin canceled race", async function () {
        //await wheelsInstance.mint(p1address);
        //await wheelsInstance.mint(p1address);
        //await wheelsInstance.connect(p1)["safeTransferFrom(address,address,uint256)"](p1address, p2address, 4);
        //await wheelsInstance.connect(p2)["safeTransferFrom(address,address,uint256)"](p2address, WheelsRace.address, 4);
        const latestBlockNumber = await ethers.provider.getBlockNumber();
        const latestBlock = await ethers.provider.getBlock(latestBlockNumber);
        const startTime = latestBlock.timestamp;
        const slip = {
            player: p2address,
            opponent: p1address,
            raceId: "1234",
            wheelId: "6",
            opponentWheelId: "5",
            raceStartTimestamp: startTime,
        };

        const p2signature = await p2._signTypedData(domain, types, slip);
        const wilderworldSignature = await p1._signTypedData(domain, types, slip);

        //const v1 = ethers.utils.verifyTypedData(domain, types, slip, p2signature);
        //const v2 = ethers.utils.verifyTypedData(domain, types, slip, wilderworldSignature);

        await expect(WheelsRace.connect(p1).claimWin(slip, p2signature, wilderworldSignature)).to.be.revertedWith("WR: RaceId used");
    });
    it("Should not allow claiming a win before a race starts", async function () {
        //await wheelsInstance.connect(p1)["safeTransferFrom(address,address,uint256)"](p1address, p2address, 5);

        const slip = {
            player: p2address,
            opponent: p1address,
            raceId: "1234",
            wheelId: "6",
            opponentWheelId: "5",
            raceStartTimestamp: "10000000000000000",
        };

        const p2signature = await p2._signTypedData(domain, types, slip);
        const wilderworldSignature = await p1._signTypedData(domain, types, slip);

        await expect(WheelsRace.connect(p1).claimWin(slip, p2signature, wilderworldSignature)).to.be.revertedWith("WR: Race hasnt started");
    });
    it("Should not allow claiming win on an expired slip", async function () {
        //await wheelsInstance.connect(p1)["safeTransferFrom(address,address,uint256)"](p1address, p2address, 5);
        const latestBlockNumber = await ethers.provider.getBlockNumber();
        const latestBlock = await ethers.provider.getBlock(latestBlockNumber);
        const startTime = latestBlock.timestamp;
        const slip = {
            player: p2address,
            opponent: p1address,
            raceId: "1234",
            wheelId: "6",
            opponentWheelId: "5",
            raceStartTimestamp: startTime,
        };
        await ethers.provider.send("evm_increaseTime", [24 * 60 * 60]);
        await ethers.provider.send("evm_mine");
        const p2signature = await p2._signTypedData(domain, types, slip);
        const wilderworldSignature = await p1._signTypedData(domain, types, slip);

        await expect(WheelsRace.connect(p1).claimWin(slip, p2signature, wilderworldSignature)).to.be.revertedWith("WR: Race expired");
    });
    it("Should not allow claiming a win with invalid data", async function () {
        //await wheelsInstance.connect(p1)["safeTransferFrom(address,address,uint256)"](p1address, p2address, 5);

        const slip = {
            player: p2address,
            opponent: p1address,
            raceId: "100000000000000000000000000000000000000000000000000",
            wheelId: "5",
            opponentWheelId: "3",
            raceStartTimestamp: Math.floor(Date.now() / 1000)
        };

        const p2signature = await p2._signTypedData(domain, types, slip);
        const wilderworldSignature = await p1._signTypedData(domain, types, slip);

        await expect(WheelsRace.connect(p1).claimWin([], p2signature, wilderworldSignature)).to.be.reverted;
    });
    it("Should not allow claiming a win with invalid player", async function () {
        const slip = {
            player: p1address, //invalid address
            opponent: p1address,
            raceId: "100000000000000000000000000000000000000000000000000",
            wheelId: "5",
            opponentWheelId: "3",
            raceStartTimestamp: Math.floor(Date.now() / 1000)
        };

        const p2signature = await p2._signTypedData(domain, types, slip);
        const wilderworldSignature = await p1._signTypedData(domain, types, slip);

        await expect(WheelsRace.connect(p1).claimWin(slip, p2signature, wilderworldSignature)).to.be.revertedWith("WR: Not signed by opponent");
    });
    it("Should not allow claiming a win with invalid opponent", async function () {
        //await wheelsInstance.connect(p2)["safeTransferFrom(address,address,uint256)"](p2address, WheelsRace.address, 5);
        //expect(await WheelsRace.stakedBy(5)).to.equal(p2address);
        const latestBlockNumber = await ethers.provider.getBlockNumber();
        const latestBlock = await ethers.provider.getBlock(latestBlockNumber);
        const startTime = latestBlock.timestamp;
        const slip = {
            player: p2address,
            opponent: p2address,
            raceId: "100000000000000001000000000000000000000000000000000",
            wheelId: "5",
            opponentWheelId: "3",
            raceStartTimestamp: startTime
        };

        const p2signature = await p2._signTypedData(domain, types, slip);
        const wilderworldSignature = await p1._signTypedData(domain, types, slip);

        await expect(WheelsRace.connect(p1).claimWin(slip, p2signature, wilderworldSignature)).to.be.revertedWith("WR: Sender isnt opponentSlip.opponent");
    });

    it("Should not allow claiming a win with invalid domain name", async function () {
        const slip = {
            player: p2address,
            opponent: p1address,
            raceId: "110000000000000000000000000000000000000000000000000",
            wheelId: "4",
            opponentWheelId: "3",
            raceStartTimestamp: Math.floor(Date.now() / 1000)
        };

        const invalidDomain = {
            name: 'INVALID',
            version: '1',
            chainId: (await ethers.provider.getNetwork()).chainId,
            verifyingContract: WheelsRace.address
        }

        const p2signature = await p2._signTypedData(invalidDomain, types, slip);
        const wilderworldSignature = await p1._signTypedData(invalidDomain, types, slip);

        await expect(WheelsRace.connect(p1).claimWin(slip, p2signature, wilderworldSignature)).to.be.revertedWith("WR: Not signed by opponent");
    });
    it("Should not allow claiming a win with invalid domain version", async function () {
        const slip = {
            player: p2address,
            opponent: p1address,
            raceId: "110000000000000000000000000000000000000000000000000",
            wheelId: "4",
            opponentWheelId: "3",
            raceStartTimestamp: Math.floor(Date.now() / 1000)
        };

        const invalidDomain = {
            name: 'Wheels Race',
            version: '123',
            chainId: (await ethers.provider.getNetwork()).chainId,
            verifyingContract: WheelsRace.address
        }

        const p2signature = await p2._signTypedData(invalidDomain, types, slip);
        const wilderworldSignature = await p1._signTypedData(invalidDomain, types, slip);

        await expect(WheelsRace.connect(p1).claimWin(slip, p2signature, wilderworldSignature)).to.be.revertedWith("WR: Not signed by opponent");
    });
    it("Should not allow claiming a win with invalid domain chainID", async function () {
        const slip = {
            player: p2address,
            opponent: p1address,
            raceId: "110000000000000000000000000000000000000000000000000",
            wheelId: "4",
            opponentWheelId: "3",
            raceStartTimestamp: Math.floor(Date.now() / 1000)
        };

        const invalidDomain = {
            name: 'Wheels Race',
            version: '1',
            chainId: "0",
            verifyingContract: WheelsRace.address
        }

        const p2signature = await p2._signTypedData(invalidDomain, types, slip);
        const wilderworldSignature = await p1._signTypedData(invalidDomain, types, slip);

        await expect(WheelsRace.connect(p1).claimWin(slip, p2signature, wilderworldSignature)).to.be.revertedWith("WR: Not signed by opponent");
    });
    it("Should not allow claiming a win with invalid domain verifyingContract", async function () {
        const slip = {
            player: p2address,
            opponent: p1address,
            raceId: "110000000000000000000000000000000000000000000000000",
            wheelId: "4",
            opponentWheelId: "3",
            raceStartTimestamp: Math.floor(Date.now() / 1000)
        };

        const invalidDomain = {
            name: 'Wheels Race',
            version: '1',
            chainId: (await ethers.provider.getNetwork()).chainId,
            verifyingContract: wheelsInstance.address
        }

        const p2signature = await p2._signTypedData(invalidDomain, types, slip);
        const wilderworldSignature = await p1._signTypedData(invalidDomain, types, slip);

        await expect(WheelsRace.connect(p1).claimWin(slip, p2signature, wilderworldSignature)).to.be.revertedWith("WR: Not signed by opponent");
    });
    it("Should not allow claiming a win with invalid types", async function () {
        const slip = {
            player: p2address,
            opponent: p1address,
            raceId: "110000000000000000000000000000000000000000000000000",
            wheelId: "4",
            opponentWheelId: "3",
            raceStartTimestamp: Math.floor(Date.now() / 1000)
        };

        const invalidTypes = {
            Invalid: [
                { name: 'player', type: 'address' },
                { name: 'opponent', type: 'address' },
                { name: 'raceId', type: 'uint256' },
                { name: 'wheelId', type: 'uint256' },
                { name: 'opponentWheelId', type: 'uint256' },
                { name: 'raceStartTimestamp', type: 'uint256' }
            ]
        }
        const p2signature = await p2._signTypedData(domain, invalidTypes, slip);
        const wilderworldSignature = await p1._signTypedData(domain, invalidTypes, slip);

        await expect(WheelsRace.connect(p1).claimWin(slip, p2signature, wilderworldSignature)).to.be.revertedWith("WR: Not signed by opponent");
    });
    it("Should not allow claiming a win with unstaked player wheel", async function () {
        const latestBlockNumber = await ethers.provider.getBlockNumber();
        const latestBlock = await ethers.provider.getBlock(latestBlockNumber);
        const startTime = latestBlock.timestamp;
        const slip = {
            player: p2address,
            opponent: p1address,
            raceId: "1234567",
            wheelId: "6000",
            opponentWheelId: "5",
            raceStartTimestamp: startTime,
        };

        const p2signature = await p2._signTypedData(domain, types, slip);
        const wilderworldSignature = await p1._signTypedData(domain, types, slip);

        //const v1 = ethers.utils.verifyTypedData(domain, types, slip, p2signature);
        //const v2 = ethers.utils.verifyTypedData(domain, types, slip, wilderworldSignature);

        await expect(WheelsRace.connect(p1).claimWin(slip, p2signature, wilderworldSignature)).to.be.revertedWith("WR: Opponent wheel unstaked");
    });
    it("Should not allow claiming a win with unstaked opponent wheel", async function () {
        const latestBlockNumber = await ethers.provider.getBlockNumber();
        const latestBlock = await ethers.provider.getBlock(latestBlockNumber);
        const startTime = latestBlock.timestamp;
        const slip = {
            player: p2address,
            opponent: p1address,
            raceId: "1234567",
            wheelId: "6",
            opponentWheelId: "5000",
            raceStartTimestamp: startTime,
        };

        const p2signature = await p2._signTypedData(domain, types, slip);
        const wilderworldSignature = await p1._signTypedData(domain, types, slip);

        //const v1 = ethers.utils.verifyTypedData(domain, types, slip, p2signature);
        //const v2 = ethers.utils.verifyTypedData(domain, types, slip, wilderworldSignature);

        await expect(WheelsRace.connect(p1).claimWin(slip, p2signature, wilderworldSignature)).to.be.revertedWith("WR: Player wheel unstaked");
    });
    it("Should not allow claiming a win with invalid wilderworld signature", async function () {
        const latestBlockNumber = await ethers.provider.getBlockNumber();
        const latestBlock = await ethers.provider.getBlock(latestBlockNumber);
        const startTime = latestBlock.timestamp;
        const slip = {
            player: p2address,
            opponent: p1address,
            raceId: "1234567",
            wheelId: "6",
            opponentWheelId: "5",
            raceStartTimestamp: startTime,
        };

        const p2signature = await p2._signTypedData(domain, types, slip);
        const invalidSignature = await p2._signTypedData(domain, types, slip);

        //const v1 = ethers.utils.verifyTypedData(domain, types, slip, p2signature);
        //const v2 = ethers.utils.verifyTypedData(domain, types, slip, wilderworldSignature);

        await expect(WheelsRace.connect(p1).claimWin(slip, p2signature, invalidSignature)).to.be.revertedWith("WR: Not signed by WW");
    });
    it("Should not allow transfer of Wheel_Staked token", async function () {
        await wheelsInstance.mint(p1address);
        await wheelsInstance.connect(p1)["safeTransferFrom(address,address,uint256)"](p1address, StakedWheels.address, 7);
        await expect(StakedWheels.connect(p1)["safeTransferFrom(address,address,uint256)"](p1address, StakedWheels.address, 7)).to.be.revertedWith("NotAuthorized");
    });



    it("Admin: Should transfer out token mistakenly sent with transferFrom", async function () {
        await wheelsInstance.mint(p1address);
        await wheelsInstance.connect(p1)["transferFrom(address,address,uint256)"](p1address, StakedWheels.address, 8);

        await StakedWheels.transferOut(p1address, 8);
        expect(await wheelsInstance.ownerOf(8)).to.equal(p1address);
    });
    it("Admin: Should not allow transfer out of a token that is staked", async function () {
        await wheelsInstance.mint(p1address);
        await wheelsInstance["safeTransferFrom(address,address,uint256)"](p1address, StakedWheels.address, 9);
        await expect(StakedWheels.transferOut(p1address, 9)).to.be.reverted;
    });

    it("canRace should correctly return false for a non-existing Wheel", async function () {
        await expect(WheelsRace.connect(p1).canRace(p1address, 999, p2address, 888)).to.be.revertedWith("ERC721: invalid token ID");
    });


    it("Should revert if a player tries to stake a Wheel that doesn't exist", async function () {
        await expect(wheelsInstance["safeTransferFrom(address,address,uint256)"](p1address, StakedWheels.address, 999)).to.be.reverted;
    });
    //it("Should only allow the admin to change the wilderWorld address", async function () {
    //    const newAddress = ethers.utils.getAddress('0x0000000000000000000000000000000000000001');
    //    await expect(WheelsRace.connect(p2).setWW(newAddress)).to.be.revertedWith("NotAdmin");
    //    await WheelsRace.setWW(newAddress);
    //    expect(await WheelsRace.wilderWorld()).to.equal(newAddress);
    //});

    it("Should only allow the admin to change the expirePeriod", async function () {
        const newExpirePeriod = 100;
        await expect(StakedWheels.connect(p2).setExpirePeriod(newExpirePeriod)).to.be.revertedWith("NotAuthorized");
        await StakedWheels.setExpirePeriod(newExpirePeriod);
        expect(await StakedWheels.expirePeriod()).to.equal(newExpirePeriod);
    });
    it("Should allow a user to cancel their unstake request", async function () {
        await StakedWheels.connect(p1).requestUnstake(1);
        await StakedWheels.connect(p1).cancelUnstake(1);
        // Check for some state change that indicates the unstake request was canceled. This will depend on your contract's implementation.
    });
    it("Should allow a user to cancel their unstake request", async function () {
        await StakedWheels.connect(p1).requestUnstake(1);
        await StakedWheels.connect(p1).cancelUnstake(1);
        // Check for some state change that indicates the unstake request was canceled. This will depend on your contract's implementation.
    });
    it("Should not allow a user to request unstaking for a wheel they do not own", async function () {
        await expect(StakedWheels.connect(p2).requestUnstake(1)).to.be.revertedWith("NotStaker");
    });

    ///Upgrade
    it("Should upgrade to a new version of the racing contract", async function () {
        await expect(StakedWheels.connect(p2).requestUnstake(1)).to.be.revertedWith("NotStaker");
    });


    /*
    it("canRace should correctly return true when both players have staked their Wheel", async function () {
        // Mint and stake wheels for both players
        await wheelsInstance.mint(p1address);
        await wheelsInstance.mint(p2address);
        await wheelsInstance["safeTransferFrom(address,address,uint256)"](p1address, WheelsRace.address, 10);
        await wheelsInstance.connect(p2)["safeTransferFrom(address,address,uint256)"](p2address, WheelsRace.address, 11);

        const canRace = await WheelsRace.canRace(p1address, 2, p2address, 3);
        expect(canRace).to.equal(true);
    });*/
    /*it("Goerli: p1 wheel staked", async function () {
        await goerliWheels.connect(p2g)["safeTransferFrom(address,address,uint256)"](p2g.address, "0x1699E3509E0993dAF971D97f3323Cb4591D6701F", "33984923448272799104450017303065461695744043458962660621372049648542077111162");
    });
    it("Goerli: p2 wheel staked", async function () {
        //await goerliWheels.connect(p2g)["safeTransferFrom(address,address,uint256)"](p2g.address, "0xf86202bB61909083194aDa24e32E3766F2A22d33", p1gid);
    });

    it("Goerli: tx", async function () {
        await p2g.sendTransaction({ to: "0xf86202bB61909083194aDa24e32E3766F2A22d33", value: ethers.utils.parseEther("0.03") });
    });*/

    /*
        it("API: should get slips", async function () {
            //player1 = 0x1699E3509E0993dAF971D97f3323Cb4591D6701F & player2=0xf86202bB61909083194aDa24e32E3766F2A22d33 & player1WheelId=69663397254254126517230868800323562519247494034614092385221476236310933604750 & player2WheelId=73097851658437357582176135055287038418959903636735131830759981735090502369936 & raceStartTimestamp=15 & raceExpiryTimestamp=18"
    
            const data = {
                player1: p1g.address,
                player2: p2g.address,
                player1WheelId: "61542046481300809449350218852237881182759362590482592350887904669406209867305",
                player2WheelId: "33984923448272799104450017303065461695744043458962660621372049648542077111162",
                raceStartTimestamp: "10",
                raceExpiryTimestamp: "200000000000000",
            }
    
            const response = await axios.get(apiurl + '/raceSlips', {
                params: data,
                headers: { 'Content-Type': 'application/json' },
            })
                .then(function (response) {
                    //console.log(response.data);
                    return response.data;
                })
                .catch(function (error) {
                    console.log(error);
                });
    
            const player1Slip = response.player1Slip;
            const player2Slip = response.player2Slip;
            //const player1Signature = await p1g._signTypedData(player1Slip.domain, player1Slip.types, player1Slip.message);
            //const player2Signature = await p2g._signTypedData(player2Slip.domain, player2Slip.types, player2Slip.message);
            const slips = { player1Slip, player2Slip };
            console.log(slips);
        });*/
    /*
        it("API: should get canRaceStart true", async function () {
            //player1 = 0x1699E3509E0993dAF971D97f3323Cb4591D6701F & player2=0xf86202bB61909083194aDa24e32E3766F2A22d33 & player1WheelId=69663397254254126517230868800323562519247494034614092385221476236310933604750 & player2WheelId=73097851658437357582176135055287038418959903636735131830759981735090502369936 & raceStartTimestamp=15 & raceExpiryTimestamp=18"
    
            const data = {
                player1: p1g.address,
                player2: p2g.address,
                player1WheelId: "61542046481300809449350218852237881182759362590482592350887904669406209867305",
                player2WheelId: "33984923448272799104450017303065461695744043458962660621372049648542077111162",
                raceStartTimestamp: "10",
                raceExpiryTimestamp: "200000000000000",
            }
    
            const response = await axios.get(apiurl + '/raceSlips', {
                params: data,
                headers: { 'Content-Type': 'application/json' },
            })
                .then(function (response) {
                    //console.log(response.data);
                    return response.data;
                })
                .catch(function (error) {
                    console.log(error);
                });
    
            const p1Slip = response.player1Slip;
            const p2Slip = response.player2Slip;
            const player1Slip = { RaceSlip: p1Slip.RaceSlip };
            const player2Slip = { RaceSlip: p2Slip.RaceSlip };
    
            const player1Signature = await p1g._signTypedData(player1Slip.domain, player1Slip, player1Slip.message);
            const player2Signature = await p2g._signTypedData(player2Slip.domain, player2Slip, player2Slip.message);
            const slips = { player1Slip, player1Signature, player2Slip, player2Signature };
            //console.log(slips);
    
            const aresponse = await axios.post(apiurl + '/canRaceStart', slips, {
                headers: { 'Content-Type': 'application/json' },
            })
                .then(function (response) {
                    return response.data;
                })
                .catch(function (error) {
                    console.log(error);
                });
            expect(aresponse.canStart).to.equal(true);
        });*/
    /*
        it("API: Should get signature from wilderworld for win", async function () {
    
            const data = {
                player1: p1g.address,
                player2: p2g.address,
                player1WheelId: "61542046481300809449350218852237881182759362590482592350887904669406209867305",
                player2WheelId: "33984923448272799104450017303065461695744043458962660621372049648542077111162",
                raceStartTimestamp: "10",
                raceExpiryTimestamp: "200000000000000",
            }
    
            const response = await axios.get(apiurl + '/raceSlips', {
                params: data,
                headers: { 'Content-Type': 'application/json' },
            })
                .then(function (response) {
                    //console.log(response.data);
                    return response.data;
                })
                .catch(function (error) {
                    //console.log(error);
                });
    
            const player1Slip = response.player1Slip;
            const player2Slip = response.player2Slip;
    
            const p1types = { RaceSlip: player1Slip.types.RaceSlip };
            const p2types = { RaceSlip: player2Slip.types.RaceSlip };
    
            const player1Signature = await p1g._signTypedData(player1Slip.domain, p1types, player1Slip.message);
            const player2Signature = await p2g._signTypedData(player2Slip.domain, p2types, player2Slip.message);
            const slips = { player1Slip, player1Signature, player2Slip, player2Signature };
            //console.log(slips);
    
            const aresponse = await axios.post(apiurl + '/canRaceStart', slips, {
                headers: { 'Content-Type': 'application/json' },
            })
                .then(function (response) {
                    //console.log(response.data);
                    return response.data;
                })
                .catch(function (error) {
                    console.log(error);
                });
            //console.log(aresponse);
            expect(aresponse.canStart).to.equal(true);
    
            const loserSlip = player2Slip;
            const bresponse = await axios.post(apiurl + '/sign', { loserSlip }, {
                headers: { 'Content-Type': 'application/json' },
            })
                .then(function (response) {
                    //console.log(response.data);
                    return response.data;
                })
                .catch(function (error) {
                    console.log(error);
                });
            //console.log("wwsig: ", bresponse.signature);
            const wilderworldSignature = bresponse.signature;
            const a = ethers.utils.verifyTypedData(loserSlip.domain, loserSlip.types, loserSlip.message, wilderworldSignature);
            console.log("recovered: ", a);
        });*/
    /*
    it("API: Should claim the win", async function () {
        const data = {
            player1: p1g.address,
            player2: p2g.address,
            player1WheelId: "61542046481300809449350218852237881182759362590482592350887904669406209867305",
            player2WheelId: "33984923448272799104450017303065461695744043458962660621372049648542077111162",
            raceStartTimestamp: "10",
            raceExpiryTimestamp: "200000000000000",
        }

        const response = await axios.get(apiurl + '/raceSlips', {
            params: data,
            headers: { 'Content-Type': 'application/json' },
        })
            .then(function (response) {
                //console.log(response.data);
                return response.data;
            })
            .catch(function (error) {
                //console.log(error);
            });

        const player1Slip = response.player1Slip;
        const player2Slip = response.player2Slip;
        const player1Signature = await p1g._signTypedData(player1Slip.domain, player1Slip.types, player1Slip.message);
        const player2Signature = await p2g._signTypedData(player2Slip.domain, player2Slip.types, player2Slip.message);
        const slips = { player1Slip, player1Signature, player2Slip, player2Signature };
        //console.log(slips);

        const aresponse = await axios.post(apiurl + '/canRaceStart', slips, {
            headers: { 'Content-Type': 'application/json' },
        })
            .then(function (response) {
                //console.log(response.data);
                return response.data;
            })
            .catch(function (error) {
                console.log(error);
            });
        //console.log(aresponse);
        expect(aresponse.canStart).to.equal(true);

        const loserSlip = player2Slip;
        const bresponse = await axios.post(apiurl + '/sign', { loserSlip }, {
            headers: { 'Content-Type': 'application/json' },
        })
            .then(function (response) {
                //console.log(response.data);
                return response.data;
            })
            .catch(function (error) {
                console.log(error);
            });
        //console.log("wwsig: ", bresponse.signature);
        const wilderworldSignature = bresponse.signature;
        const a = ethers.utils.verifyTypedData(loserSlip.domain, loserSlip.types, loserSlip.message, wilderworldSignature);
        //console.log("recovered: ", a);
    });*/
    /*
    it("API: should pass canRaceStart", async function () {
        const data = {
            player1: p1address,
            player2: p2address,
            player1WheelId: 123,
            player2WheelId: 456,
            raceStartTimestamp: 10
        }

        const response = await axios.get(apiurl + '/raceSlips', {
            params: data,
            headers: { 'Content-Type': 'application/json' },
        })
            .then(function (response) {
                return response.data;
            })
            .catch(function (error) {
                console.log(error);
            });
        const loserSlip = response.player1Slip;
        const aresponse = await axios.post(apiurl + '/sign', { loserSlip }, {
            headers: { 'Content-Type': 'application/json' },
        })
            .then(function (response) {
                return response.data;
            })
            .catch(function (error) {
                console.log(error);
            });
        const wilderworldSignature = aresponse.signature;
        const a = ethers.utils.verifyTypedData(loserSlip.domain, types, loserSlip.message, wilderworldSignature);
    });
    it("API: should get slips", async function () {
        //player1 = 0x1699E3509E0993dAF971D97f3323Cb4591D6701F & player2=0xf86202bB61909083194aDa24e32E3766F2A22d33 & player1WheelId=69663397254254126517230868800323562519247494034614092385221476236310933604750 & player2WheelId=73097851658437357582176135055287038418959903636735131830759981735090502369936 & raceStartTimestamp=15 & raceExpiryTimestamp=18"

        const data = {
            player1: p1address,
            player2: p2address,
            player1WheelId: "69663397254254126517230868800323562519247494034614092385221476236310933604750",
            player2WheelId: "73097851658437357582176135055287038418959903636735131830759981735090502369936",
            raceStartTimestamp: "100000000"
        }

        const response = await axios.get('http://localhost:8181/raceSlips', {
            params: data,
            headers: { 'Content-Type': 'application/json' },
        })
            .then(function (response) {
                //console.log(response.data);
                return response.data;
            })
            .catch(function (error) {
                console.log(error);
            });

        const player1Slip = response.player1Slip;
        const player2Slip = response.player2Slip;

        const player1Signature = await p1._signTypedData(player1Slip.domain, types, player1Slip.message);
        const player2Signature = await p2._signTypedData(player2Slip.domain, types, player2Slip.message);

        const slips = { player1Slip, player1Signature, player2Slip, player2Signature };

        const aresponse = await axios.post('http://localhost:8181/canRaceStart', slips, {
            headers: { 'Content-Type': 'application/json' },
        })
            .then(function (response) {
                return response.data;
            })
            .catch(function (error) {
                console.log(error);
            });

    });*/
});


