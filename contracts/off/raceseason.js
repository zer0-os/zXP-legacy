const { expect } = require("chai");
const { ethers } = require("hardhat");
const {
    signTypedData,
    SignTypedDataVersion,
} = require("@metamask/eth-sig-util");
const axios = require('axios');

describe("WWRace Season", function () {
    var p1address;
    var p2address;
    var p1;
    var p2;
    var WheelsRace;
    var wheelsInstance;

    var domain, types;

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

        const Race = await ethers.getContractFactory("WheelsRaceSeason");
        WheelsRace = await Race.deploy("Wheels Race", "1", "Wheel_Staked", "WWS", p1address, wheelsInstance.address);
        await WheelsRace.deployed();

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
                { name: 'raceId', type: 'uint' },
                { name: 'wheelId', type: 'uint' },
                { name: 'opponentWheelId', type: 'uint' },
                { name: 'raceStartTimestamp', type: 'uint' },
            ]
        }
    });

    it("Should stake the Wheel and mint a Wheel_Staked token", async function () {
        await wheelsInstance.mint(p1address);
        await wheelsInstance["safeTransferFrom(address,address,uint256)"](p1address, WheelsRace.address, 0);

        const originalTokenURI = await wheelsInstance.tokenURI(0);
        // Check that the new token was minted with the correct metadata
        const stakedTokenURI = await WheelsRace.tokenURI(0);
        expect(stakedTokenURI).to.equal(originalTokenURI);
        expect(await WheelsRace.ownerOf(0)).to.equal(p1address);
        expect(await WheelsRace.stakedBy(0)).to.equal(p1address);
    });

    it("Should allow unstake after season end", async function () {
        await wheelsInstance.mint(p1address);
        await wheelsInstance.mint(p1address);
        await wheelsInstance["safeTransferFrom(address,address,uint256)"](p1address, WheelsRace.address, 2);

        await WheelsRace.connect(p1).unstake(2);
        expect(await wheelsInstance.ownerOf(2)).to.equal(p1address);
        expect(await WheelsRace.stakedBy(2)).to.equal(ethers.constants.AddressZero);
    });

    it("Should have burned the staked token after unstake", async function () {
        await expect(WheelsRace.ownerOf(2)).to.be.revertedWith("ERC721: invalid token ID");
    });

    it("Should allow a player to claim a win", async function () {
        await wheelsInstance.mint(p1address);
        await wheelsInstance.mint(p2address);
        await wheelsInstance.connect(p1)["safeTransferFrom(address,address,uint256)"](p1address, WheelsRace.address, 3);
        await wheelsInstance.connect(p2)["safeTransferFrom(address,address,uint256)"](p2address, WheelsRace.address, 4);
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
        expect(await WheelsRace.stakedBy(4)).to.equal(p1address);
    });

    it("Should have transferred the staked token after win", async function () {
        expect(await WheelsRace.ownerOf(4)).to.equal(p1address);
    });

    it("Should not allow canRace for a locked token", async function () {
        await expect(WheelsRace.connect(p1).canRace(p1address, 4, p1address, 4)).to.be.revertedWith('Locked');
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
        await wheelsInstance.connect(p1)["safeTransferFrom(address,address,uint256)"](p1address, WheelsRace.address, 5);
        await wheelsInstance.connect(p2)["safeTransferFrom(address,address,uint256)"](p2address, WheelsRace.address, 6);
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
        await expect(WheelsRace.connect(p1).unstake(2)).to.be.reverted;
    });

    it("Should not allow unstake request for a non-staked wheel", async function () {
        await expect(WheelsRace.connect(p1).unstake(999)).to.be.reverted;
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

        await expect(WheelsRace.connect(p1).claimWin(slip, p2signature, wilderworldSignature)).to.be.revertedWith("WR: Sender isnt opponent");
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
        await wheelsInstance.connect(p1)["safeTransferFrom(address,address,uint256)"](p1address, WheelsRace.address, 7);
        await expect(WheelsRace.connect(p1)["safeTransferFrom(address,address,uint256)"](p1address, WheelsRace.address, 7)).to.be.revertedWith("WR: Token is soulbound");
    });



    it("Admin: Should transfer out token mistakenly sent with transferFrom", async function () {
        await wheelsInstance.mint(p1address);
        await wheelsInstance.connect(p1)["transferFrom(address,address,uint256)"](p1address, WheelsRace.address, 8);

        await WheelsRace.transferOut(p1address, 8);
        expect(await wheelsInstance.ownerOf(8)).to.equal(p1address);
    });
    it("Admin: Should not allow transfer out of a token that is staked", async function () {
        await wheelsInstance.mint(p1address);
        await wheelsInstance["safeTransferFrom(address,address,uint256)"](p1address, WheelsRace.address, 9);
        await expect(WheelsRace.transferOut(p1address, 9)).to.be.reverted;
    });

    it("canRace should correctly return false for a non-existing Wheel", async function () {
        await expect(WheelsRace.connect(p1).canRace(p1address, 999, p2address, 888)).to.be.revertedWith("ERC721: invalid token ID");
    });


    it("Should revert if a player tries to stake a Wheel that doesn't exist", async function () {
        await expect(wheelsInstance["safeTransferFrom(address,address,uint256)"](p1address, WheelsRace.address, 999)).to.be.reverted;
    });
    it("Should only allow the admin to change the wilderWorld address", async function () {
        const newAddress = ethers.utils.getAddress('0x0000000000000000000000000000000000000001');
        await expect(WheelsRace.connect(p2).setWW(newAddress)).to.be.revertedWith("Sender isnt admin");
        await WheelsRace.setWW(newAddress);
        expect(await WheelsRace.wilderWorld()).to.equal(newAddress);
    });

    it("Should only allow the admin to change the wheels contract", async function () {
        const newAddress = ethers.utils.getAddress('0x0000000000000000000000000000000000000002');
        await expect(WheelsRace.connect(p2).setWheels(newAddress)).to.be.revertedWith("Sender isnt admin");
        await WheelsRace.setWheels(newAddress);
        expect(await WheelsRace.wheels()).to.equal(newAddress);
    });

    it("Should only allow the admin to change the expirePeriod", async function () {
        const newExpirePeriod = 100;
        await expect(WheelsRace.connect(p2).setExpirePeriod(newExpirePeriod)).to.be.revertedWith("Sender isnt admin");
        await WheelsRace.setExpirePeriod(newExpirePeriod);
        expect(await WheelsRace.expirePeriod()).to.equal(newExpirePeriod);
    });
    it("Should not allow a user to unstake for a wheel that is currently in a race", async function () {
        await expect(WheelsRace.connect(p1).unstake(2)).to.be.revertedWith("ERC721: invalid token ID");
    });
});