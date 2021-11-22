const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("zXP", function () {
  it("Should deploy the managers and register contracts", async function () {
    const GameManager = await ethers.getContractFactory("GameManager");
    const gameManager = await GameManager.deploy();
    await gameManager.deployed();
    console.log(gameManager.address);

    const ContractRegistry = await ethers.getContractFactory("ContractRegistry");
    const registry = await ContractRegistry.deploy();
    await registry.deployed();
    console.log(registry.address);

    const ItemRegistry = await ethers.getContractFactory("ItemRegistry");
    const iregistry = await ItemRegistry.deploy();
    await iregistry.deployed();
    console.log(iregistry.address);
    
    const ItemManager = await ethers.getContractFactory("ItemManager");
    const itemManager = await GameManager.deploy();
    await itemManager.deployed();
    console.log(itemManager.address);

    const Wheels = await ethers.getContractFactory("Wheel");
    const wheel = await Wheels.deploy(ethers.utils.formatBytes32String("WheelGenerator"), iregistry.address);
    await wheel.deployed();
    console.log(wheel.address);

    let regGMtx = await registry.registerAddress(ethers.utils.formatBytes32String("GameManager"), gameManager.address);
    //console.log(regGMtx);

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

    await itemManager.attach(wheel.address, 0, token.address, 0, 12345);

    //const setGreetingTx = await greeter.setGreeting("Hola, mundo!");
    // wait until the transaction is mined
    //await setGreetingTx.wait();
    //expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});
