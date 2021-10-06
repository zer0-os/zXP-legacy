const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("zXP", function () {
  it("Should deploy the managers and register contracts", async function () {
    const GameManager = await ethers.getContractFactory("GameManager");
    const gameManager = await GameManager.deploy();
    await gameManager.deployed();

    const ItemManager = await ethers.getContractFactory("ItemManager");
    const itemManager = await GameManager.deploy();
    await itemManager.deployed();

    const ContractRegistry = await ethers.getContractFactory("ContractRegistry");
    const registry = await ContractRegistry.deploy();
    await registry.deployed();

    const Wheels = await ethers.getContractFactory("Wheel");
    const wheel = await Wheels.deploy();
    await wheel.deployed();

    let regGMtx = await registry.registerAddress(ethers.utils.formatBytes32String("GameManager"), manager.address);
    console.log(regGMtx);

    let erc721token = await ethers.getContractFactory("ERC721TestToken");
    let token = await erc721token.deploy('Test 721', 'TEST', {
      "id": 0,
      "description": "My NFT",
      "external_url": "https://forum.openzeppelin.com/t/create-an-nft-and-deploy-to-a-public-testnet-using-truffle/2961",
      "image": "https://twemoji.maxcdn.com/svg/1f40e.svg",
      "name": "My NFT 0"
    });
    let td = await token.deployed();
    await td.mint("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");
    expect(await td.ownerOf(0)).to.equal("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");


    await itemManager.attach(td.address, 0, )

    //const setGreetingTx = await greeter.setGreeting("Hola, mundo!");
    // wait until the transaction is mined
    //await setGreetingTx.wait();
    //expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});
