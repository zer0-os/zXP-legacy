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

        [p1, p2] = await ethers.getSigners();
        p1address = p1.address;
        p2address = p2.address;

        const Race = await ethers.getContractFactory("WheelsRace");
        WheelsRace = await Race.deploy("Wheels Race", "1", "Wheel_Staked", "WWS", p1address, wheelsInstance.address);
        await WheelsRace.deployed();
    });

    //beforeEach(async function () {
    //});

    it("Should set correct values in the constructor", async function () {
        expect(await WheelsRace.wilderWorld()).to.equal(p1address);
        expect(await WheelsRace.wheels()).to.equal(wheelsInstance.address);
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

    it("Should have burned the staked token after unstake", async function () {
        await expect(WheelsRace.ownerOf(2)).to.be.revertedWith("ERC721: invalid token ID");
    });

    it("Should allow a player to claim a win", async function () {
        await wheelsInstance.mint(p1address);
        await wheelsInstance.mint(p2address);
        await wheelsInstance.connect(p1)["safeTransferFrom(address,address,uint256)"](p1address, WheelsRace.address, 3);
        await wheelsInstance.connect(p2)["safeTransferFrom(address,address,uint256)"](p2address, WheelsRace.address, 4);
        expect(await WheelsRace.ownerOf(4)).to.equal(p2address);

        const value = {
            player: p2address,
            opponent: p1address,
            raceId: "100000000000000000000000000000000000000000000000000",
            wheelId: "4",
            raceStartTimestamp: Math.floor(Date.now() / 1000),
            raceExpiryTimestamp: "10000000000000000000"
        };

        const domain = {
            name: 'Wheels Race',
            version: '1',
            chainId: (await ethers.provider.getNetwork()).chainId,
            verifyingContract: WheelsRace.address
        }
        const types = {
            RaceSlip: [
                { name: 'player', type: 'address' },
                { name: 'opponent', type: 'address' },
                { name: 'raceId', type: 'uint256' },
                { name: 'wheelId', type: 'uint256' },
                { name: 'raceStartTimestamp', type: 'uint256' },
                { name: 'raceExpiryTimestamp', type: 'uint256' },
            ]
        }

        const p2signature = await p2._signTypedData(domain, types, value);
        const wilderworldSignature = await p1._signTypedData(domain, types, value);

        //const v1 = ethers.utils.verifyTypedData(domain, types, value, p2signature);
        //const v2 = ethers.utils.verifyTypedData(domain, types, value, wilderworldSignature);

        const s = await WheelsRace.connect(p1).claimWin(value, p2signature, wilderworldSignature);
        expect(await wheelsInstance.ownerOf(4)).to.equal(p1address);
    });

    it("Should have burned the staked token after win", async function () {
        await expect(WheelsRace.ownerOf(4)).to.be.revertedWith("ERC721: invalid token ID");
    });

    it("Should not allow a player to claim a consumed raceId", async function () {
        await wheelsInstance.connect(p1)["safeTransferFrom(address,address,uint256)"](p1address, p2address, 4);
        await wheelsInstance.connect(p2)["safeTransferFrom(address,address,uint256)"](p2address, WheelsRace.address, 4);


        const value = {
            player: p2address,
            opponent: p1address,
            raceId: "100000000000000000000000000000000000000000000000000",
            wheelId: "4",
            raceStartTimestamp: Math.floor(Date.now() / 1000),
            raceExpiryTimestamp: "10000000000000000000"
        };

        const domain = {
            name: 'Wheels Race',
            version: '1',
            chainId: (await ethers.provider.getNetwork()).chainId,
            verifyingContract: WheelsRace.address
        }
        const types = {
            RaceSlip: [
                { name: 'player', type: 'address' },
                { name: 'opponent', type: 'address' },
                { name: 'raceId', type: 'uint256' },
                { name: 'wheelId', type: 'uint256' },
                { name: 'raceStartTimestamp', type: 'uint256' },
                { name: 'raceExpiryTimestamp', type: 'uint256' },
            ]
        }

        const p2signature = await p2._signTypedData(domain, types, value);
        const wilderworldSignature = await p1._signTypedData(domain, types, value);

        //const v1 = ethers.utils.verifyTypedData(domain, types, value, p2signature);
        //const v2 = ethers.utils.verifyTypedData(domain, types, value, wilderworldSignature);

        await expect(WheelsRace.connect(p1).claimWin(value, p2signature, wilderworldSignature)).to.be.revertedWith('RaceId already used');
    });

    it("Should cancel race", async function () {
        await WheelsRace.connect(p1).cancelRace("1234");
    });

    it("Should not allow a player to claim a canceled race", async function () {
        const value = {
            player: p2address,
            opponent: p1address,
            raceId: "1234",
            wheelId: "4",
            raceStartTimestamp: Math.floor(Date.now() / 1000),
            raceExpiryTimestamp: "10000000000000000000"
        };

        const domain = {
            name: 'Wheels Race',
            version: '1',
            chainId: (await ethers.provider.getNetwork()).chainId,
            verifyingContract: WheelsRace.address
        }
        const types = {
            RaceSlip: [
                { name: 'player', type: 'address' },
                { name: 'opponent', type: 'address' },
                { name: 'raceId', type: 'uint256' },
                { name: 'wheelId', type: 'uint256' },
                { name: 'raceStartTimestamp', type: 'uint256' },
                { name: 'raceExpiryTimestamp', type: 'uint256' },
            ]
        }

        const p2signature = await p2._signTypedData(domain, types, value);
        const wilderworldSignature = await p1._signTypedData(domain, types, value);

        //const v1 = ethers.utils.verifyTypedData(domain, types, value, p2signature);
        //const v2 = ethers.utils.verifyTypedData(domain, types, value, wilderworldSignature);

        await expect(WheelsRace.connect(p1).claimWin(value, p2signature, wilderworldSignature)).to.be.revertedWith('RaceId already used');
    });


    it("Should not allow unstaking a wheel owned by someone else", async function () {
        await wheelsInstance.mint(p1address);
        await expect(WheelsRace.connect(p1).requestUnstake(4)).to.be.reverted;
    });

    it("Should not allow unstake request for a non-staked wheel", async function () {
        await expect(WheelsRace.connect(p1).requestUnstake(999)).to.be.reverted;
    });

    it("Should not allow claiming a win with invalid data", async function () {
        await wheelsInstance.connect(p1)["safeTransferFrom(address,address,uint256)"](p1address, p2address, 5);

        const value = {
            player: p2address,
            opponent: p1address,
            raceId: "100000000000000000000000000000000000000000000000000",
            wheelId: "5",
            raceStartTimestamp: Math.floor(Date.now() / 1000),
            raceExpiryTimestamp: "10000000000000000000"
        };

        const domain = {
            name: 'Wheels Race',
            version: '1',
            chainId: (await ethers.provider.getNetwork()).chainId,
            verifyingContract: WheelsRace.address
        }
        const types = {
            RaceSlip: [
                { name: 'player', type: 'address' },
                { name: 'opponent', type: 'address' },
                { name: 'raceId', type: 'uint256' },
                { name: 'wheelId', type: 'uint256' },
                { name: 'raceStartTimestamp', type: 'uint256' },
                { name: 'raceExpiryTimestamp', type: 'uint256' },
            ]
        }

        const p2signature = await p2._signTypedData(domain, types, value);
        const wilderworldSignature = await p1._signTypedData(domain, types, value);

        await expect(WheelsRace.connect(p1).claimWin([], p2signature, wilderworldSignature)).to.be.reverted;
    });
    it("Should not allow claiming a win with invalid player", async function () {
        const value = {
            player: p1address, //invalid address
            opponent: p1address,
            raceId: "100000000000000000000000000000000000000000000000000",
            wheelId: "5",
            raceStartTimestamp: Math.floor(Date.now() / 1000),
            raceExpiryTimestamp: "10000000000000000000"
        };

        const domain = {
            name: 'Wheels Race',
            version: '1',
            chainId: (await ethers.provider.getNetwork()).chainId,
            verifyingContract: WheelsRace.address
        }
        const types = {
            RaceSlip: [
                { name: 'player', type: 'address' },
                { name: 'opponent', type: 'address' },
                { name: 'raceId', type: 'uint256' },
                { name: 'wheelId', type: 'uint256' },
                { name: 'raceStartTimestamp', type: 'uint256' },
                { name: 'raceExpiryTimestamp', type: 'uint256' },
            ]
        }
        const p2signature = await p2._signTypedData(domain, types, value);
        const wilderworldSignature = await p1._signTypedData(domain, types, value);

        await expect(WheelsRace.connect(p1).claimWin(value, p2signature, wilderworldSignature)).to.be.reverted;
    });
    it("Should not allow claiming a win with invalid opponent", async function () {
        await wheelsInstance.connect(p2)["safeTransferFrom(address,address,uint256)"](p2address, WheelsRace.address, 5);
        expect(await WheelsRace.stakedBy(5)).to.equal(p2address);

        const value = {
            player: p2address,
            opponent: p2address,
            raceId: "100000000000000001000000000000000000000000000000000",
            wheelId: "5",
            raceStartTimestamp: Math.floor(Date.now() / 1000),
            raceExpiryTimestamp: "10000000000000000000"
        };

        const domain = {
            name: 'Wheels Race',
            version: '1',
            chainId: (await ethers.provider.getNetwork()).chainId,
            verifyingContract: WheelsRace.address
        }
        const types = {
            RaceSlip: [
                { name: 'player', type: 'address' },
                { name: 'opponent', type: 'address' },
                { name: 'raceId', type: 'uint256' },
                { name: 'wheelId', type: 'uint256' },
                { name: 'raceStartTimestamp', type: 'uint256' },
                { name: 'raceExpiryTimestamp', type: 'uint256' },
            ]
        }
        const p2signature = await p2._signTypedData(domain, types, value);
        const wilderworldSignature = await p1._signTypedData(domain, types, value);

        await expect(WheelsRace.connect(p1).claimWin(value, p2signature, wilderworldSignature)).to.be.reverted;
    });
    it("Should not allow claiming a win with invalid expire time", async function () {
        const value = {
            player: p2address,
            opponent: p1address,
            raceId: "100000000000000001000000000000000000000000000000000",
            wheelId: "5",
            raceStartTimestamp: "10000",
            raceExpiryTimestamp: "0"
        };

        const domain = {
            name: 'Wheels Race',
            version: '1',
            chainId: (await ethers.provider.getNetwork()).chainId,
            verifyingContract: WheelsRace.address
        }
        const types = {
            RaceSlip: [
                { name: 'player', type: 'address' },
                { name: 'opponent', type: 'address' },
                { name: 'raceId', type: 'uint256' },
                { name: 'wheelId', type: 'uint256' },
                { name: 'raceStartTimestamp', type: 'uint256' },
                { name: 'raceExpiryTimestamp', type: 'uint256' },
            ]
        }
        const p2signature = await p2._signTypedData(domain, types, value);
        const wilderworldSignature = await p1._signTypedData(domain, types, value);

        await expect(WheelsRace.connect(p1).claimWin(value, p2signature, wilderworldSignature)).to.be.reverted;
    });
    it("Should not allow claiming a win with invalid domain name", async function () {
        const value = {
            player: p2address,
            opponent: p1address,
            raceId: "110000000000000000000000000000000000000000000000000",
            wheelId: "4",
            raceStartTimestamp: Math.floor(Date.now() / 1000),
            raceExpiryTimestamp: "10000000000000000000"
        };

        const domain = {
            name: 'INVALID',
            version: '1',
            chainId: (await ethers.provider.getNetwork()).chainId,
            verifyingContract: WheelsRace.address
        }
        const types = {
            RaceSlip: [
                { name: 'player', type: 'address' },
                { name: 'opponent', type: 'address' },
                { name: 'raceId', type: 'uint256' },
                { name: 'wheelId', type: 'uint256' },
                { name: 'raceStartTimestamp', type: 'uint256' },
                { name: 'raceExpiryTimestamp', type: 'uint256' },
            ]
        }
        const p2signature = await p2._signTypedData(domain, types, value);
        const wilderworldSignature = await p1._signTypedData(domain, types, value);

        await expect(WheelsRace.connect(p1).claimWin(value, p2signature, wilderworldSignature)).to.be.reverted;
    });
    it("Should not allow claiming a win with invalid domain version", async function () {
        const value = {
            player: p2address,
            opponent: p1address,
            raceId: "110000000000000000000000000000000000000000000000000",
            wheelId: "4",
            raceStartTimestamp: Math.floor(Date.now() / 1000),
            raceExpiryTimestamp: "10000000000000000000"
        };

        const domain = {
            name: 'Wheels Race',
            version: '123',
            chainId: (await ethers.provider.getNetwork()).chainId,
            verifyingContract: WheelsRace.address
        }
        const types = {
            RaceSlip: [
                { name: 'player', type: 'address' },
                { name: 'opponent', type: 'address' },
                { name: 'raceId', type: 'uint256' },
                { name: 'wheelId', type: 'uint256' },
                { name: 'raceStartTimestamp', type: 'uint256' },
                { name: 'raceExpiryTimestamp', type: 'uint256' },
            ]
        }
        const p2signature = await p2._signTypedData(domain, types, value);
        const wilderworldSignature = await p1._signTypedData(domain, types, value);

        await expect(WheelsRace.connect(p1).claimWin(value, p2signature, wilderworldSignature)).to.be.reverted;
    });
    it("Should not allow claiming a win with invalid domain chainID", async function () {
        const value = {
            player: p2address,
            opponent: p1address,
            raceId: "110000000000000000000000000000000000000000000000000",
            wheelId: "4",
            raceStartTimestamp: Math.floor(Date.now() / 1000),
            raceExpiryTimestamp: "10000000000000000000"
        };

        const domain = {
            name: 'Wheels Race',
            version: '1',
            chainId: "0",
            verifyingContract: WheelsRace.address
        }
        const types = {
            RaceSlip: [
                { name: 'player', type: 'address' },
                { name: 'opponent', type: 'address' },
                { name: 'raceId', type: 'uint256' },
                { name: 'wheelId', type: 'uint256' },
                { name: 'raceStartTimestamp', type: 'uint256' },
                { name: 'raceExpiryTimestamp', type: 'uint256' },
            ]
        }
        const p2signature = await p2._signTypedData(domain, types, value);
        const wilderworldSignature = await p1._signTypedData(domain, types, value);

        await expect(WheelsRace.connect(p1).claimWin(value, p2signature, wilderworldSignature)).to.be.reverted;
    });
    it("Should not allow claiming a win with invalid domain verifyingContract", async function () {
        const value = {
            player: p2address,
            opponent: p1address,
            raceId: "110000000000000000000000000000000000000000000000000",
            wheelId: "4",
            raceStartTimestamp: Math.floor(Date.now() / 1000),
            raceExpiryTimestamp: "10000000000000000000"
        };

        const domain = {
            name: 'Wheels Race',
            version: '1',
            chainId: (await ethers.provider.getNetwork()).chainId,
            verifyingContract: wheelsInstance.address
        }
        const types = {
            RaceSlip: [
                { name: 'player', type: 'address' },
                { name: 'opponent', type: 'address' },
                { name: 'raceId', type: 'uint256' },
                { name: 'wheelId', type: 'uint256' },
                { name: 'raceStartTimestamp', type: 'uint256' },
                { name: 'raceExpiryTimestamp', type: 'uint256' },
            ]
        }
        const p2signature = await p2._signTypedData(domain, types, value);
        const wilderworldSignature = await p1._signTypedData(domain, types, value);

        await expect(WheelsRace.connect(p1).claimWin(value, p2signature, wilderworldSignature)).to.be.reverted;
    });
    it("Should not allow claiming a win with invalid types", async function () {
        const value = {
            player: p2address,
            opponent: p1address,
            raceId: "110000000000000000000000000000000000000000000000000",
            wheelId: "4",
            raceStartTimestamp: Math.floor(Date.now() / 1000),
            raceExpiryTimestamp: "10000000000000000000"
        };

        const domain = {
            name: 'Wheels Race',
            version: '1',
            chainId: (await ethers.provider.getNetwork()).chainId,
            verifyingContract: wheelsInstance.address
        }
        const types = {
            Invalid: [
                { name: 'player', type: 'address' },
                { name: 'opponent', type: 'address' },
                { name: 'raceId', type: 'uint256' },
                { name: 'wheelId', type: 'uint256' },
                { name: 'raceStartTimestamp', type: 'uint256' },
                { name: 'raceExpiryTimestamp', type: 'uint256' },
            ]
        }
        const p2signature = await p2._signTypedData(domain, types, value);
        const wilderworldSignature = await p1._signTypedData(domain, types, value);

        await expect(WheelsRace.connect(p1).claimWin(value, p2signature, wilderworldSignature)).to.be.reverted;
    });
    it("Should not allow claiming a win with invalid wilderworld signature", async function () {
        // populate winnerDeclaration and raceStartDeclaration with invalid data
        await expect(WheelsRace.connect(p1).claimWin([], "invalidSignature", "invalidSignature")).to.be.reverted;
    });
    it("Should not allow transfer of Wheel_Staked token", async function () {
        await wheelsInstance.mint(p1address);
        await wheelsInstance.connect(p1)["safeTransferFrom(address,address,uint256)"](p1address, WheelsRace.address, 6);
        await expect(WheelsRace.connect(p1)["safeTransferFrom(address,address,uint256)"](p1address, WheelsRace.address, 6)).to.be.revertedWith("WR: Token is soulbound");
    });
    /*
    it("myAPI: Should get signature from wilderworld for win", async function () {
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

    it("API: should get slips", async function () {
        //player1 = 0x1699E3509E0993dAF971D97f3323Cb4591D6701F & player2=0xf86202bB61909083194aDa24e32E3766F2A22d33 & player1WheelId=69663397254254126517230868800323562519247494034614092385221476236310933604750 & player2WheelId=73097851658437357582176135055287038418959903636735131830759981735090502369936 & raceStartTimestamp=15 & raceExpiryTimestamp=18"

        const data = {
            player1: "0x1699E3509E0993dAF971D97f3323Cb4591D6701F",
            player2: "0xf86202bB61909083194aDa24e32E3766F2A22d33",
            player1WheelId: 69663397254254126517230868800323562519247494034614092385221476236310933604750,
            player2WheelId: 73097851658437357582176135055287038418959903636735131830759981735090502369936,
            raceStartTimestamp: 10,
            raceExpiryTimestamp: 200,
        }

        const response = await axios.get('http://54.196.218.144:3000/raceSlips', {
            params: data,
            headers: { 'Content-Type': 'application/json' },
        })
            .then(function (response) {
                console.log(response.data);
                return response.data;
            })
            .catch(function (error) {
                console.log(error);
            });

        const player1Slip = response.player1Slip;
        const player2Slip = response.player2Slip;
        const player1Signature = await p1._signTypedData(player1Slip.domain, player1Slip.types, player1Slip.message);
        const player2Signature = await p2._signTypedData(player2Slip.domain, player2Slip.types, player2Slip.message);
        const slips = { player1Slip, player1Signature, player2Slip, player2Signature };

        const aresponse = await axios.post('http://54.196.218.144:3000/canRaceStart', slips, {
            headers: { 'Content-Type': 'application/json' },
        })
            .then(function (response) {
                console.log(response.data);
                return response.data;
            })
            .catch(function (error) {
                console.log(error);
            });
        console.log(aresponse);

    });

    /*it("API: should pass canRaceStart??????", async function () {
        const data = {
            player1: p1address,
            player2: p2address,
            raceId: 1,
            player1WheelId: 123,
            player2WheelId: 456,
            raceStartTimestamp: 10,
            raceExpiryTimestamp: 200,
        }

        const response = await axios.get('http://54.196.218.144:3000/raceSlips', {
            params: data,
            headers: { 'Content-Type': 'application/json' },
        })
            .then(function (response) {
                console.log(response.data);
                return response.data;
            })
            .catch(function (error) {
                console.log(error);
            });
        const loserSlip = response.player1Slip;
        console.log("loserslip", loserSlip);
        const aresponse = await axios.post('http://54.196.218.144:3000/sign', { loserSlip }, {
            headers: { 'Content-Type': 'application/json' },
        })
            .then(function (response) {
                console.log(response.data);
                return response.data;
            })
            .catch(function (error) {
                console.log(error);
            });
        const wilderworldSignature = aresponse.signature;
        console.log("wwsig: ", wilderworldSignature);
        const a = ethers.utils.verifyTypedData(loserSlip.domain, loserSlip.types, loserSlip.message, wilderworldSignature);
        console.log("recovered: ", a);
    });*/
    /*
       it("myAPI: should get slips", async function () {
           //player1 = 0x1699E3509E0993dAF971D97f3323Cb4591D6701F & player2=0xf86202bB61909083194aDa24e32E3766F2A22d33 & player1WheelId=69663397254254126517230868800323562519247494034614092385221476236310933604750 & player2WheelId=73097851658437357582176135055287038418959903636735131830759981735090502369936 & raceStartTimestamp=15 & raceExpiryTimestamp=18"
   
           const data = {
               player1: p1address,
               player2: p2address,
               player1WheelId: "69663397254254126517230868800323562519247494034614092385221476236310933604750",
               player2WheelId: "73097851658437357582176135055287038418959903636735131830759981735090502369936",
               raceStartTimestamp: "100000000",
               raceExpiryTimestamp: "2000000000",
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
   
           console.log("player1Slip", player1Slip);
           console.log("player2Slip", player2Slip);
   
           const player1Signature = await p1._signTypedData(player1Slip.domain, player1Slip.types, player1Slip.message);
           const player2Signature = await p2._signTypedData(player2Slip.domain, player2Slip.types, player2Slip.message);
   
           console.log("player1Sig", player1Signature);
           console.log("player2Sig", player2Signature);
   
           const v1 = ethers.utils.verifyTypedData(player1Slip.domain, player1Slip.types, player1Slip.message, player1Signature);
           console.log("v1: ", v1);
   
           const v2 = ethers.utils.verifyTypedData(player2Slip.domain, player2Slip.types, player2Slip.message, player2Signature);
           console.log("v2: ", v2);
   
   
           const slips = { player1Slip, player1Signature, player2Slip, player2Signature };
   
           const aresponse = await axios.post('http://localhost:8181/canRaceStart', slips, {
               headers: { 'Content-Type': 'application/json' },
           })
               .then(function (response) {
                   console.log(response.data);
                   return response.data;
               })
               .catch(function (error) {
                   console.log(error);
               });
           console.log("true???: ", aresponse);
   
       });*/
});