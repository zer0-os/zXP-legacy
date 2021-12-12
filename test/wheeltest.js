const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("zXP", function () {
  it("Should deploy the managers and register contracts", async function () {
    const GameManager = await ethers.getContractFactory("GameManager");
    const gameManager = await GameManager.deploy();
    //await gameManager.deployed();
    console.log(gameManager.address);

    const ContractRegistry = await ethers.getContractFactory("ContractRegistry");
    const registry = await ContractRegistry.deploy();
    //await registry.deployed();
    console.log(registry.address);

    const ItemRegistry = await ethers.getContractFactory("ItemRegistry");
    const iregistry = await ItemRegistry.deploy();
    //await iregistry.deployed();
    console.log(iregistry.address);
    
    const ItemManager = await ethers.getContractFactory("ItemManager");
    const im = await ItemManager.deploy(iregistry.address);
    //let im = await itemManager.deployed();

    const Wheels = await ethers.getContractFactory("Wheel");
    const wheel = await Wheels.deploy(ethers.utils.formatBytes32String("WheelGenerator"), iregistry.address);
    //await wheel.deployed();
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
    //let td = await token.deployed();
    await token.mint("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");
    //expect(await td.ownerOf(0)).to.equal("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");
    //issue license
    //let issuetx = await im.issueLicense(ethers.utils.keccak256(ethers.utils.defaultAbiCoder.encode(["bytes32", "uint256", "address"],[ethers.utils.formatBytes32String("Wheel"), 12345, "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"])));
    //await issuetx.wait();
    //Attach wheel zero 
    let attachtx = await im.attach(wheel.address, 12345, token.address, 0);
    //await attachtx.wait();
    console.log(attachtx);
    console.log(ethers.utils.keccak256(ethers.utils.defaultAbiCoder.encode(["address","uint256"],[token.address, 0])));
    expect(await wheel.nftToItem(ethers.utils.keccak256(ethers.utils.defaultAbiCoder.encode(["address","uint256"],[token.address, 0])))).to.equal(12345);

    //const setGreetingTx = await greeter.setGreeting("Hola, mundo!");
    // wait until the transaction is mined
    //await setGreetingTx.wait();
    //expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});
