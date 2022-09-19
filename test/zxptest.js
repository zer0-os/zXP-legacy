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
    it("Gets signers for players 1 and 2", async function () {
      const [p1, p2] = await ethers.getSigners();
      P1 = p1.address;
      P2 = p2.address;
    });

    it("Deploys mock wheel token", async function () {
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
      await wheelToken.mint(P1);
      expect(await wheelToken.ownerOf(0)).to.equal(P1);
    });

    it("Deploys mock beast token", async function () {
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
      await beastToken.mint(P1);
      expect(await beastToken.ownerOf(0)).to.equal(P1);
    });
    it("Deploys the registry", async function () {
      const RegistryFactory = await ethers.getContractFactory("Registry");
      const registry = await RegistryFactory.deploy();
      await registry.deployed();
      _registry = registry;
    });

    it("Deploys and registers ZXP manager", async function () {
      const ZXPFactory = await ethers.getContractFactory("ZXP");
      const zxp = await ZXPFactory.deploy(_registry.address);
      await zxp.deployed();
      _zxp = zxp;
      await _registry.registerAddress(ethers.utils.formatBytes32String("ZXP"), _zxp.address, 0);
    });

    it("Deploys and registers item manager", async function () {
      const ItemManagerFactory = await ethers.getContractFactory("ItemManager");
      const itemManager = await ItemManagerFactory.deploy(_registry.address);
      await itemManager.deployed();
      _itemManager = itemManager;
      await _registry.registerAddress(ethers.utils.formatBytes32String("ItemManager"), _itemManager.address, 0);
    });

    it("Deploys and registers character manager", async function () {
      const CharacterManagerFactory = await ethers.getContractFactory("CharacterManager");
      const characterManager = await CharacterManagerFactory.deploy(_registry.address);
      await characterManager.deployed();
      _characterManager = characterManager;
      await _registry.registerAddress(ethers.utils.formatBytes32String("CharacterManager"), _characterManager.address, 0);
    });

    it("Deploys and registers characters", async function () {
      const CharacterS0Factory = await ethers.getContractFactory("Character_S0");
      const characterS0 = await CharacterS0Factory.deploy(_registry.address);
      await characterS0.deployed();
      _characterS0 = characterS0;
      await _registry.registerAddress(ethers.utils.formatBytes32String("Character"), _characterS0.address, 1);
    });

    it("Deploys and registers wheel item", async function () {
      const Wheels = await ethers.getContractFactory("Wheel_S0");
      const wheel = await Wheels.deploy(ethers.utils.formatBytes32String("Wheel_S0"), _registry.address, _wheelToken.address);
      await wheel.deployed();
      _wheel = wheel;
      await _registry.registerAddress(ethers.utils.formatBytes32String("Wheel"), _wheel.address, 2);
    });

    it("Deploys and registers beast item", async function () {
      const Beasts = await ethers.getContractFactory("Beast_S0");
      const beast = await Beasts.deploy(ethers.utils.formatBytes32String("Beast_S0"), _registry.address, _beastToken.address);
      await beast.deployed();
      _beast = beast;
      await _registry.registerAddress(ethers.utils.formatBytes32String("Beast"), _beast.address, 2);
    });

    it("Deploys and registers beast battle game", async function () {
      const beastBattles = await ethers.getContractFactory("BeastBattle_S0");
      const beastBattle = await beastBattles.deploy(_registry.address);
      await beastBattle.deployed();
      _beastBattle = beastBattle;
      await _registry.registerAddress(ethers.utils.formatBytes32String("BeastBattle"), _beastBattle.address, 3);
    });

    it("Deploys and registers deepMeme game", async function () {
      const deepMemeFactory = await ethers.getContractFactory("DeepMeme_S0");
      const deepMeme = await deepMemeFactory.deploy(_registry.address, P1);
      await deepMeme.deployed();
      _deepMeme = deepMeme;
      await _registry.registerAddress(ethers.utils.formatBytes32String("DeepMeme"), _deepMeme.address, 3);
    });

    it("Deploys and registers meme item", async function () {
      const memeFactory = await ethers.getContractFactory("Meme_S0");
      const meme = await memeFactory.deploy(_registry.address, P1);
      await meme.deployed();
      _meme = meme;
      await _registry.registerAddress(ethers.utils.formatBytes32String("Meme"), _meme.address, 2);
    });

    it("Deploys and registers memelord character", async function () {
      const memeLordFactory = await ethers.getContractFactory("MemeLord_S0");
      const memeLord = await memeLordFactory.deploy(_registry.address);
      await memeLord.deployed();
      _memeLord = memeLord;
      await _registry.registerAddress(ethers.utils.formatBytes32String("MemeLord"), _memeLord.address, 1);  
    });

    it("Player 1 creates character", async function () {
      await _characterManager.create();
    });
    //it("Player 1 can't create a character again", async function() {
    //  expect(await _characterManager.create()).to.be.reverted();
    //});
    it("Player 1 views beast stats", async function (){
      expect(await _zxp.levelOf(0)).to.equal(1);
      expect(await _beast.health(0)).to.equal(3625);
      expect(await _beast.mana(0)).to.equal(1810);
      expect(await _beast.power(0)).to.equal(601);
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
    it("Player 1 beast is level 2", async function (){
      expect(await _zxp.levelOf(0)).to.equal(2);
      //expect(await _beast.health(0)).to.equal(3700);
      //expect(await _beast.mana(0)).to.equal(640);
      //expect(await _beast.power(0)).to.equal(204);
    });
    it("Player 1 beast health is now 1300", async function (){
      expect(await _beast.health(0)).to.equal(3700);
    });
    it("Player 1 beast mana is now 640", async function (){
      expect(await _beast.mana(0)).to.equal(1840);
    });
    it("Player 1 power is now 204", async function (){
      expect(await _beast.power(0)).to.equal(604);
    });
    it("DeepMeme tourney official submits results", async function() {
      await _deepMeme.submitTop3Results(0, 1, 2, 0, 0, 0);
    });
  
  });

  describe("zXP Season 1", function () {
    it("Deploys and registers s1 characters", async function () {
      const CharacterS1Factory = await ethers.getContractFactory("Character_S1");
      const characterS1 = await CharacterS1Factory.deploy(_registry.address);
      await characterS1.deployed();
      _characterS1 = characterS1;
      await _registry.advanceSeason(ethers.utils.formatBytes32String("Character"), _characterS1.address);
    });
    
    it("Deploy and registers s1 wheels", async function () {
      const Wheels = await ethers.getContractFactory("Wheel_S1");
      const wheel = await Wheels.deploy(ethers.utils.formatBytes32String("Wheel_S1"), _registry.address, _wheelToken.address);
      await wheel.deployed();
      _wheel = wheel;
      await _registry.advanceSeason(ethers.utils.formatBytes32String("Wheel"), _wheel.address);
    });
    
    it("Deploy and registers s1 beasts", async function () {
      const Beasts = await ethers.getContractFactory("Beast_S1");
      const beast = await Beasts.deploy(ethers.utils.formatBytes32String("Beast_S1"), _registry.address, _beastToken.address);
      await beast.deployed();
      _beast = beast;
      await _registry.advanceSeason(ethers.utils.formatBytes32String("Beast"), _beast.address);
    });
    
    it("Deploy and registers s1 beast battles", async function () {
      const beastBattles = await ethers.getContractFactory("BeastBattle_S1");
      const beastBattle = await beastBattles.deploy(_registry.address);
      await beastBattle.deployed();
      _beastBattle = beastBattle;
      await _registry.advanceSeason(ethers.utils.formatBytes32String("BeastBattle"), beastBattle.address);
    });
    it("P1 advances season", async function () {
      _characterManager.advance();
    });
    it("P1 advances season", async function () {
        _characterManager.advance();
    });
    it("Player 1 creates character", async function () {
      await _characterManager.create();
    });
    //it("Player 1 can't create a character again", async function() {
    //  expect(await _characterManager.create()).to.be.reverted();
    //});
    it("Player 1 beast is still level 2", async function (){
      expect(await _zxp.levelOf(0)).to.equal(2);
      //expect(await _beast.health(0)).to.equal(1225);
      //expect(await _beast.mana(0)).to.equal(610);
      //expect(await _beast.power(0)).to.equal(201);
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
    it("Beast 0 has 340 xp", async function(){
      expect(await _zxp.xp(0)).to.equal(340);
    });
    it("P1 uses beast in game, choosing blue team, player and beast earn XP", async function () {
      await _beastBattle.battle(0, 1);
    });
    it("P1 uses beast in game, choosing blue team, player and beast earn XP", async function () {
      await _beastBattle.battle(0, 1);
    });
    it("P1 uses beast in game, choosing blue team, player and beast earn XP", async function () {
      await _beastBattle.battle(0, 1);
    });
    it("P1 uses beast in game, choosing blue team, player and beast earn XP", async function () {
      await _beastBattle.battle(0, 1);
    });
    it("P1 uses beast in game, choosing blue team, player and beast earn XP", async function () {
      await _beastBattle.battle(0, 1);
    });

    it("Beast 0 has 840 xp", async function(){
      expect(await _zxp.xp(0)).to.equal(840);
    });
    it("Player 1 beast levels up to 3", async function (){
      expect(await _zxp.levelOf(0)).to.equal(3);
    });
    it("Player 1 beast health is now 2625", async function (){
      expect(await _beast.health(0)).to.equal(3825);
    });
    it("Player 1 beast mana is now 1290", async function (){
      expect(await _beast.mana(0)).to.equal(1890);
    });
    it("Player 1 power is now 409", async function (){
      expect(await _beast.power(0)).to.equal(609);
    });
    it("DeepMeme tourney official submits results", async function() {
      //await _deepMeme.submitTop3Results(0, 1, 2, 0, 0, 0);
    });

    //leveling test
    describe("leveling to 99", function () {
      var randSeed = 133250;
      //it("gets the random seed value", async function(){
      //  randSeed = await(_beast.randSeed());
      //  console.log(randSeed);
      //})
      const healthCurve = 25;
      const manaCurve = 10;
      const powerCurve = 1;
      const baseHealth = 120;
      const baseMana = 60;
      const basePower = 20;
      const baseCoef = 10;
      const baseMod = 3;
      
      for (let level = 3; level < 99; level++) {
        let lto = "levels to " + (level + 1).toString();
        it(lto, async function() {
          await _zxp.levelUp(0);
          expect(await _zxp.levelOf(0)).to.equal(level + 1);
        });

        let hinc = (1 + randSeed % baseMod) * baseHealth * baseCoef + healthCurve * (level + 1) * (level + 1);
        //console.log(hinc);
        let hincs = "increased health to " + hinc.toString();
        it(hincs, async function() {
          expect(await _beast.health(0)).to.equal(hinc);
        });

        let minc = (1 + randSeed % baseMod) * baseMana * baseCoef + manaCurve * (level + 1) * (level + 1);
        let mincs = "increased mana to " + minc.toString();
        it(mincs, async function() {
          expect(await _beast.mana(0)).to.equal(minc);
        });

        let pinc = (1 + randSeed % baseMod) * basePower * baseCoef + powerCurve * (level + 1) * (level + 1);
        let pincs = "increased power to " + pinc.toString();
        it(pincs, async function() {
          expect(await _beast.power(0)).to.equal(pinc);
        });
      }
      
    });
  });
});