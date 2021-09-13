const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("zXP", function () {
  it("Should deploy the game manager and register contracts", async function () {
    const GameManager = await ethers.getContractFactory("GameManager");
    const manager = await GameManager.deploy();
    await manager.deployed();

    //expect(await greeter.greet()).to.equal("Hello, world!");

    //const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

    // wait until the transaction is mined
    //await setGreetingTx.wait();

    //expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});
