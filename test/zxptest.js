const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("zXP", function () {

  var _registry; 
  var _itemManager;
  var _characterManager;
  var _wheelToken;
  var _beastToken;
  var _wheel;
  var _beast;
  var _beastBattle;
  var _wheelRace;
  var _characterS0;
  var _deepMeme;
  var _meme;
  var _zxp;
  var _memeLord;
  var P1;
  var P2;

  describe("zXP Season 0", function () {
      it("Deploy the managers and registers contracts", async function () {
      const [p1, p2] = await ethers.getSigners();
      P1 = p1;
      P2 = p2;

      const addy = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
      const erc721wheelToken = await ethers.getContractFactory("ERC721TestToken");
      const wheelToken = await erc721wheelToken.deploy('Wilder Wheels', 'WHEEL', {
        "id": 0,
        "description": "Wilder Wheels",
        "external_url": "0://wilder.wheels",
        "image": "wheel.png",
        "name": "Wilder Wheels"
      });
      await wheelToken.deployed();
      _wheelToken = wheelToken;
      await wheelToken.mint(addy);
      expect(await wheelToken.ownerOf(0)).to.equal(addy);

      const erc721beastToken = await ethers.getContractFactory("ERC721TestToken");
      const beastToken = await erc721beastToken.deploy('Wilder Beasts', 'BEAST', {
        "id": 0,
        "description": "Beasts",
        "external_url": "0://wilder.beasts",
        "image": "beast.png",
        "name": "Wilder Beasts"
      });
      await beastToken.deployed();
      _beastToken = beastToken;
      await beastToken.mint(addy);
      expect(await beastToken.ownerOf(0)).to.equal(addy);

      const RegistryFactory = await ethers.getContractFactory("Registry");
      const registry = await RegistryFactory.deploy();
      await registry.deployed();
      _registry = registry;
      
      const ZXPFactory = await ethers.getContractFactory("ZXP");
      const zxp = await ZXPFactory.deploy(registry.address);
      await zxp.deployed();
      _zxp = zxp;

      const ItemManagerFactory = await ethers.getContractFactory("ItemManager");
      const itemManager = await ItemManagerFactory.deploy(registry.address);
      await itemManager.deployed();
      _itemManager = itemManager;

      const CharacterManagerFactory = await ethers.getContractFactory("CharacterManager");
      const characterManager = await CharacterManagerFactory.deploy(registry.address);
      await characterManager.deployed();
      _characterManager = characterManager;

      const CharacterS0Factory = await ethers.getContractFactory("Character_S0");
      const characterS0 = await CharacterS0Factory.deploy(registry.address);
      await characterS0.deployed();
      _characterS0 = characterS0;

      const Wheels = await ethers.getContractFactory("Wheel_S0");
      const wheel = await Wheels.deploy(ethers.utils.formatBytes32String("Wheel_S0"), registry.address, _wheelToken.address);
      await wheel.deployed();
      _wheel = wheel;

      const Beasts = await ethers.getContractFactory("Beast_S0");
      const beast = await Beasts.deploy(ethers.utils.formatBytes32String("Beast_S0"), registry.address, beastToken.address);
      await beast.deployed();
      _beast = beast;

      const beastBattles = await ethers.getContractFactory("BeastBattle_S0");
      const beastBattle = await beastBattles.deploy(registry.address);
      await beastBattle.deployed();
      _beastBattle = beastBattle;
      
      const deepMemeZNA = P1.address;
      const deepMemeFactory = await ethers.getContractFactory("DeepMeme_S0");
      const deepMeme = await deepMemeFactory.deploy(registry.address, deepMemeZNA);
      await deepMeme.deployed();
      _deepMeme = deepMeme;

      const memeFactory = await ethers.getContractFactory("Meme_S0");
      const meme = await memeFactory.deploy(registry.address, deepMemeZNA);
      await meme.deployed();
      _meme = meme;
  
      const memeLordFactory = await ethers.getContractFactory("MemeLord_S0");
      const memeLord = await memeLordFactory.deploy(registry.address);
      await memeLord.deployed();
      _memeLord = memeLord;

      //await registry.registerAddress(ethers.utils.formatBytes32String("GameManager"), gameManager.address);
      await _registry.registerAddress(ethers.utils.formatBytes32String("ZXP"), _zxp.address, 0);
      await _registry.registerAddress(ethers.utils.formatBytes32String("ItemManager"), _itemManager.address, 0);
      await _registry.registerAddress(ethers.utils.formatBytes32String("CharacterManager"), _characterManager.address, 0);
      await _registry.registerAddress(ethers.utils.formatBytes32String("Character"), _characterS0.address, 1);
      await _registry.registerAddress(ethers.utils.formatBytes32String("Wheel"), _wheel.address, 2);
      await _registry.registerAddress(ethers.utils.formatBytes32String("Beast"), _beast.address, 2);
      await _registry.registerAddress(ethers.utils.formatBytes32String("BeastBattle"), _beastBattle.address, 3);
      await _registry.registerAddress(ethers.utils.formatBytes32String("DeepMeme"), _deepMeme.address, 3);
      await _registry.registerAddress(ethers.utils.formatBytes32String("Meme"), _meme.address, 2);
      await _registry.registerAddress(ethers.utils.formatBytes32String("MemeLord"), _memeLord.address, 1);  
    });
    it("Player 1 creates character", async function () {
      await _characterManager.create();
    });
    it("Player 1 views beast stats", async function (){
      expect(await _zxp.levelOf(0)).to.equal(1);
      expect(await _beast.health(0)).to.equal(1225);
      expect(await _beast.mana(0)).to.equal(610);
      expect(await _beast.power(0)).to.equal(201);
    });
    it("P1 equips wheel", async function () {
      await _characterS0.equipWheel(0);
    });
    it("P1 equips beast", async function () {
      await _characterS0.equipBeast(0);
    });
    //it("P1 uses wheel in game, player and wheel earn XP", async function () {
    //  //_wheelRace.race();
    //});
    it("P1 uses beast in game, player and beast earn XP", async function () {
      await _beastBattle.battle(0);
    });
    it("Beast 0 has 240 xp", async function(){
      expect(await _zxp.xp(0)).to.equal(240);
    });
    it("Player 1 views leveled-up beast stats", async function (){
      expect(await _zxp.levelOf(0)).to.equal(2);
      expect(await _beast.health(0)).to.equal(1300);
      expect(await _beast.mana(0)).to.equal(640);
      expect(await _beast.power(0)).to.equal(204);
    });
    it("DeepMeme tourney official submits results", async function() {
      await _deepMeme.submitTop3Results(0, 1, 2, 0, 0, 0);
    });
  });

  describe("zXP Season 1", function () {
    it("Deploy the managers and register contracts", async function () {
      const CharacterS1Factory = await ethers.getContractFactory("Character_S1");
      const characterS1 = await CharacterS1Factory.deploy(_registry.address);
      await characterS1.deployed();
      _characterS1 = characterS1;
      
      const Wheels = await ethers.getContractFactory("Wheel_S1");
      const wheel = await Wheels.deploy(ethers.utils.formatBytes32String("Wheel_S1"), _registry.address, _wheelToken.address);
      await wheel.deployed();
      _wheel = wheel;

      const Beasts = await ethers.getContractFactory("Beast_S1");
      const beast = await Beasts.deploy(ethers.utils.formatBytes32String("Beast_S1"), _registry.address, _beastToken.address);
      await beast.deployed();
      _beast = beast;

      const beastBattles = await ethers.getContractFactory("BeastBattle_S1");
      const beastBattle = await beastBattles.deploy(_registry.address);
      await beastBattle.deployed();
      _beastBattle = beastBattle;

      await _registry.registerAddress(ethers.utils.formatBytes32String("Wheel_S1"), wheel.address, 1);
      await _registry.registerAddress(ethers.utils.formatBytes32String("Beast_S1"), beast.address, 1);
      await _registry.registerAddress(ethers.utils.formatBytes32String("BeastBattle_S1"), beastBattle.address, 0);
  });
    it("P1 advances season", async function () {
        _characterManager.advance();
    });
  });

});