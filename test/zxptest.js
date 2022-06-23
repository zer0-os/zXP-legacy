const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("zXP", function () {

  var _registry; 
  var _itemManager;
  var _characterManager;
  var _wheelToken;
  var _wheel;
  var _beast;
  var _beastBattle;

  describe("Deployment", function () {
      it("Should deploy the managers and register contracts", async function () {
        //const GameManager = await ethers.getContractFactory("GameManager");
        //const gameManager = await GameManager.deploy();
        //await gameManager.deployed();
        //console.log(gameManager.address);
    
        //const ContractRegistry = await ethers.getContractFactory("ContractRegistry");
        //const registry = await ContractRegistry.deploy();
        //await registry.deployed();
        //console.log(registry.address);
    
        const RegistryFactory = await ethers.getContractFactory("Registry");
        const registry = await RegistryFactory.deploy();
        await registry.deployed();
        _registry = registry;
        
        const ItemManagerFactory = await ethers.getContractFactory("ItemManager");
        const itemManager = await ItemManagerFactory.deploy(registry.address);
        await itemManager.deployed();
        _itemManager = itemManager;

        const CharacterManagerFactory = await ethers.getContractFactory("Character_S0");
        const characterManager = await CharacterManagerFactory.deploy(registry.address);
        await characterManager.deployed();
        _characterManager = characterManager;
        
        //console.log(regGMtx);
        const addy = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
        const erc721wheelToken = await ethers.getContractFactory("ERC721TestToken");
        const wheelToken = await erc721wheelToken.deploy('Test 721', 'TEST', {
          "id": 0,
          "description": "My NFT",
          "external_url": "https://forum.openzeppelin.com/t/create-an-nft-and-deploy-to-a-public-testnet-using-truffle/2961",
          "image": "https://twemoji.maxcdn.com/svg/1f40e.svg",
          "name": "My NFT 0"
        });
        await wheelToken.deployed();
        _wheelToken = wheelToken;
        await wheelToken.mint(addy);
        expect(await wheelToken.ownerOf(0)).to.equal(addy);

        const erc721beastToken = await ethers.getContractFactory("ERC721TestToken");
        const beastToken = await erc721beastToken.deploy('Test 721', 'TEST', {
          "id": 0,
          "description": "My NFT",
          "external_url": "https://forum.openzeppelin.com/t/create-an-nft-and-deploy-to-a-public-testnet-using-truffle/2961",
          "image": "https://twemoji.maxcdn.com/svg/1f40e.svg",
          "name": "My NFT 0"
        });
        await beastToken.deployed();
        _beastToken = beastToken;
        await beastToken.mint(addy);
        expect(await beastToken.ownerOf(0)).to.equal(addy);
    
        const Wheels = await ethers.getContractFactory("Wheel_S0");
        const wheel = await Wheels.deploy(ethers.utils.formatBytes32String("WheelGenerator"), registry.address, wheelToken.address);
        await wheel.deployed();
        _wheel = wheel;

        const Beasts = await ethers.getContractFactory("Beast_S0");
        const beast = await Beasts.deploy(ethers.utils.formatBytes32String("BeastGenerator"), registry.address, beastToken.address);
        await beast.deployed();
        _beast = beast;

        const beastBattles = await ethers.getContractFactory("BeastBattle_S0");
        const beastBattle = await beastBattles.deploy(registry.address);
        await beastBattle.deployed();
        _beastBattle = beastBattle;
    
        //await registry.registerAddress(ethers.utils.formatBytes32String("GameManager"), gameManager.address);
        await _registry.registerAddress(ethers.utils.formatBytes32String("ItemManager"), itemManager.address);
        await _registry.registerAddress(ethers.utils.formatBytes32String("CharacterManager"), itemManager.address);
        await _registry.registerAddress(ethers.utils.formatBytes32String("Wheel_S0"), wheel.address);
        await _registry.registerAddress(ethers.utils.formatBytes32String("Beast_S0"), beast.address);
        await _registry.registerAddress(ethers.utils.formatBytes32String("BeastBattle_S0"), beastBattle.address);
        //expect(await im.attachItemToNft(wheel.address, wheelToken.address, 0)).to.emit(itemManager, "Attached");
        
        //issue license
        //expect(await im.issueLicense(ethers.utils.keccak256(ethers.utils.defaultAbiCoder.encode(["bytes32", "uint256", "address"],[ethers.utils.formatBytes32String("Wheel"), 12345, addy])))).to.emit(im, "Licensed");
        //expect(await im.licensed(ethers.utils.keccak256(ethers.utils.defaultAbiCoder.encode(["bytes32", "uint256", "address"],[ethers.utils.formatBytes32String("Wheel"), 12345, addy])))).to.equal(true);
        //await issuetx.wait();
        //Attach wheel zero 
      
        //await attachtx.wait();
        //console.log(attachtx);
        //console.log(ethers.utils.keccak256(ethers.utils.defaultAbiCoder.encode(["address","uint256"],[wheelToken.address, 0])));
        //expect(await wheel.nftToItem(ethers.utils.keccak256(ethers.utils.defaultAbiCoder.encode(["address","uint256"],[wheelToken.address, 0])))).to.equal(12345);
    
        //const setGreetingTx = await greeter.setGreeting("Hola, mundo!");
        // wait until the transaction is mined
        //await setGreetingTx.wait();
        //expect(await greeter.greet()).to.equal("Hola, mundo!");
    });
    it("Player 1 creates character", async function () {
      _characterManager.create();
    });
    it("P1 equips wheel", async function () {
      _characterManager.equipWheel(0);
    });
    it("P1 equips beast", async function () {
      _characterManager.equipBeast(0);
    });
    it("P1 uses beast in game and earns XP", async function () {
      _beastBattle.battle();
    });
    it("New zXP season initialized", async function () {
    });
    it("P1 advances season", async function () {
    });
  });

  describe("Deployment", function () {
    it("Should ", async function () {
      
    });
  });

});