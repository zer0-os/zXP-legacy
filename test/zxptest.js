const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("zXP", function () {
  it("Should deploy the managers and register contracts", async function () {
    const GameManager = await ethers.getContractFactory("GameManager");
    const gameManager = await GameManager.deploy();
    await gameManager.deployed();
    console.log(gameManager.address);

    //const ContractRegistry = await ethers.getContractFactory("ContractRegistry");
    //const registry = await ContractRegistry.deploy();
    //await registry.deployed();
    //console.log(registry.address);

    const RegistryFactory = await ethers.getContractFactory("Registry");
    const registry = await RegistryFactory.deploy();
    await registry.deployed();
    console.log(registry.address);
    
    const ItemManagerF = await ethers.getContractFactory("ItemManager");
    const itemManager = await ItemManagerF.deploy(registry.address);
    await itemManager.deployed();

    const Wheels = await ethers.getContractFactory("Wheel");
    const wheel = await Wheels.deploy(ethers.utils.formatBytes32String("WheelGenerator"), registry.address);
    await wheel.deployed();
    console.log(wheel.address);

    await registry.registerAddress(ethers.utils.formatBytes32String("GameManager"), gameManager.address);
    await registry.registerAddress(ethers.utils.formatBytes32String("ItemManager"), im.address);
    await registry.registerItem(ethers.utils.formatBytes32String("Wheel"), wheel.address);
    
    //console.log(regGMtx);
    const addy = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
    const erc721token = await ethers.getContractFactory("ERC721TestToken");
    const token = await erc721token.deploy('Test 721', 'TEST', {
      "id": 0,
      "description": "My NFT",
      "external_url": "https://forum.openzeppelin.com/t/create-an-nft-and-deploy-to-a-public-testnet-using-truffle/2961",
      "image": "https://twemoji.maxcdn.com/svg/1f40e.svg",
      "name": "My NFT 0"
    });
    await token.deployed();
    await token.mint(addy);
    expect(await token.ownerOf(0)).to.equal(addy);
    
     expect(await im.attachItemToNft(wheel.address, token.address, 0)).to.emit(itemManager, "Attached");
    
    
    //issue license
    //expect(await im.issueLicense(ethers.utils.keccak256(ethers.utils.defaultAbiCoder.encode(["bytes32", "uint256", "address"],[ethers.utils.formatBytes32String("Wheel"), 12345, addy])))).to.emit(im, "Licensed");
    //expect(await im.licensed(ethers.utils.keccak256(ethers.utils.defaultAbiCoder.encode(["bytes32", "uint256", "address"],[ethers.utils.formatBytes32String("Wheel"), 12345, addy])))).to.equal(true);
    //await issuetx.wait();
    //Attach wheel zero 
   
    //await attachtx.wait();
    //console.log(attachtx);
    //console.log(ethers.utils.keccak256(ethers.utils.defaultAbiCoder.encode(["address","uint256"],[token.address, 0])));
    //expect(await wheel.nftToItem(ethers.utils.keccak256(ethers.utils.defaultAbiCoder.encode(["address","uint256"],[token.address, 0])))).to.equal(12345);

    //const setGreetingTx = await greeter.setGreeting("Hola, mundo!");
    // wait until the transaction is mined
    //await setGreetingTx.wait();
    //expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});