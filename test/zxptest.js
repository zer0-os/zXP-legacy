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
  var _battleRoyale;
  var _wheelRace;
  var _characterS0;
  var _deepMeme;
  var _meme;
  var _zxp;
  var _memeLord;
  var _tileSphere;
  var _automaton;
  var p1signer;
  var p2signer;
  var P1;
  var P2;
  var _nftStakePoolS0;
  var _P1name = ethers.utils.formatBytes32String("durienb");
  var _P2name = ethers.utils.formatBytes32String("n3o");
  
  describe("zXP Season 0", function () {
    it("Gets signers for players 1 and 2", async function () {
      const [p1, p2] = await ethers.getSigners();
      p1signer = p1;
      p2signer = p2;
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
      await wheelToken.mint(P2);
      
    });

    it("P1 owns wheel 0", async function () {
      expect(await _wheelToken.ownerOf(0)).to.equal(P1);
    });

    it("P2 owns wheel 1", async function () {
      expect(await _wheelToken.ownerOf(1)).to.equal(P2);
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
      await beastToken.mint(P2);
    });

    it("P1 owns beast 0", async function () {
      expect(await _beastToken.ownerOf(0)).to.equal(P1);
    });

    it("P2 owns beast 1", async function () {
      expect(await _beastToken.ownerOf(1)).to.equal(P2);
    });

    it("Deploys mock wild token", async function () {
      const erc20Token = await ethers.getContractFactory("ERC20TestToken");
      const wildToken = await erc20Token.deploy('Wilder World', 'WILD');
      await wildToken.deployed();
      _wildToken = wildToken;
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

    describe("NFT staking", function(){
      it("Deploys and registers s0 industry staking pool", async function () {
        const nftStakePoolS0Factory = await ethers.getContractFactory("NFTStakePool_S0");
        const nftStakePoolS0 = await nftStakePoolS0Factory.deploy(_registry.address);
        await nftStakePoolS0.deployed();
        _nftStakePoolS0 = nftStakePoolS0;
        await _registry.registerAddress(ethers.utils.formatBytes32String("NFTStakePool"), _nftStakePoolS0.address, 1);
      });
      it("Player 1 stakes beast", async function () {
        await _beastToken["safeTransferFrom(address,address,uint256)"](P1, _nftStakePoolS0.address, 0);
      });
      it("Player 1 unstakes beast", async function () {
        //await _nftStakePoolS0.stake(_beastToken.address, 0);
        await _nftStakePoolS0._unstake(_beastToken.address, 0);
      });
      it("Player 1 stakes beast", async function () {
        //await _nftStakePoolS0.stake(_beastToken.address, 0);
        await _beastToken["safeTransferFrom(address,address,uint256)"](P1, _nftStakePoolS0.address, 0);
        //console.log(tx);
        console.log(await _nftStakePoolS0.test());
        console.log(await _nftStakePoolS0.staker(ethers.utils.solidityKeccak256(["address", "uint"], [_beastToken.address, 0])));
      });
    });

    it("Player 1 creates character", async function () {
      await _characterManager.create(_P1name);
    });
    //it("Player 1 can't create a character again", async function() {
    //  expect(await _characterManager.create()).to.be.reverted();
    //});
    it("Player 1 beast is level 1", async function (){
      let lev = await _zxp.levelOf(0);
      lev = lev.toString();
      expect(lev).to.equal("1");
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
      let xp = await _zxp.xp(0);
      xp = xp.toString();
      expect(xp).to.equal("240");
    });
    it("Player 1 beast is level 2", async function (){
      let lev = await _zxp.levelOf(0);
      lev = lev.toString();
      expect(lev).to.equal("2");
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
    //it("Player 1 can't create a character again", async function() {
    //  expect(await _characterManager.create()).to.be.reverted;
    //});
    it("Player 1 beast is still level 2", async function (){
      let lev = await _zxp.levelOf(0);
      lev = lev.toString();
      expect(lev).to.equal("2");
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
      let lev = await _zxp.xp(0);
      lev = lev.toString();
      expect(lev).to.equal("340");
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
      let xp = await _zxp.xp(0);
      xp = xp.toString();
      expect(xp).to.equal("840");
    });
    it("Player 1 beast levels up to 3", async function (){
      let lev = await _zxp.levelOf(0);
      lev = lev.toString();
      expect(lev).to.equal("3");
    });
    it("DeepMeme tourney official submits results", async function() {
      //await _deepMeme.submitTop3Results(0, 1, 2, 0, 0, 0);
    });

    /*leveling test
    describe("leveling to 99", function () {
      let randSeed = 133250;
      it("gets the random seed value", async function(){
        randSeed = await(_beast.randSeed());
        console.log(randSeed);
      })
      const healthCurve = 25;
      const manaCurve = 10;
      const powerCurve = 1;
      const baseHealth = 120;
      const baseMana = 60;
      const basePower = 20;
      const baseCoef = 10;
      const baseMod = 3;
      const beastID = 1;
      
      for (let level = 1; level < 99; level++) {
        let lto = "levels to " + (level + 1).toString();
        it(lto, async function() {
          await _zxp.levelUp(beastID);
          expect(await _zxp.levelOf(beastID)).to.equal(level + 1);
        });

        let hinc = (1 + randSeed % baseMod) * baseHealth * baseCoef + healthCurve * (level + 1) * (level + 1);
        //console.log(hinc);
        let hincs = "increased health to " + hinc.toString();
        it(hincs, async function() {
          expect(await _beast.health(beastID)).to.equal(hinc);
        });

        let minc = (1 + randSeed % baseMod) * baseMana * baseCoef + manaCurve * (level + 1) * (level + 1);
        let mincs = "increased mana to " + minc.toString();
        it(mincs, async function() {
          expect(await _beast.mana(beastID)).to.equal(minc);
        });

        let pinc = (1 + randSeed % baseMod) * basePower * baseCoef + powerCurve * (level + 1) * (level + 1);
        let pincs = "increased power to " + pinc.toString();
        it(pincs, async function() {
          expect(await _beast.power(beastID)).to.equal(pinc);
        });
      }
    });
    
    //generate tilemap
    /*describe("battle royale tilemap", function () {
      const mapsize = 256;
      for (let x = 0; x < mapsize; x++) {
        for (let y = 0; y < mapsize; y++) {
          let s = "gets tile " + x + "," + y;
          it(s, async function() {
            console.log(await _battleRoyale.get_tile(x,y));
          });
        }
      }
    });
    */
    const unitsBought = "20";
    const dev_lev = "1";
    const xP1 = "100";
    const yP1 = "100";
    const xP2 = "101";
    const yP2 = "100";

    /*describe("battle royale land", function () {
      it("Deploy and registers s0 battle royale", async function () {
        const battleRoyales = await ethers.getContractFactory("BattleRoyale_S0");
        const battleRoyale = await battleRoyales.deploy(_registry.address, _wildToken.address);
        await battleRoyale.deployed();
        _battleRoyale = battleRoyale;
        await _registry.registerAddress(ethers.utils.formatBytes32String("BattleRoyale"), _battleRoyale.address, 3);
      });
      
      const salePrice = 1;
      let landPrice, unitPrice, total, passThresh;
      //let landString = "gets land price of " + xP1 + "," + yP1;
      it("gets passable threshold", async function(){
        passThresh = await _battleRoyale.get_passable_threshold();
      });
      it("gets tile", async function(){
        let tile = await _battleRoyale.get_tile(xP1,yP1);
      });
      it("gets land price of 0,0", async function(){
        landPrice = await _battleRoyale.get_land_price(xP1, yP1);
        landPrice = landPrice.mul(ethers.BigNumber.from(dev_lev));
      });
      it("gets unit price of 0,0", async function(){
        unitPrice = await _battleRoyale.get_unit_price(xP1,yP1);
        unitPrice = unitPrice.mul(unitsBought);
      });
      it("calcs total", async function(){
        total = landPrice.add(unitPrice);
      });
      it("buys tile", async function(){
        await _battleRoyale.buy_land_with_wei(xP1,yP1,unitsBought,dev_lev, {value: total});
      });
      it("posts tile for sale", async function(){
        await _battleRoyale.market_sell(xP1, yP1, salePrice);
      });
      it("buys tile from market", async function(){
        //await _battleRoyale.connect(p2signer).market_buy(xP1, yP1, {value: salePrice});
      });
      it("buys units on tile", async function(){
        await _battleRoyale.buy_units_with_wei(xP1, yP1, unitsBought, {value: unitPrice*unitsBought});
      });

      it("gets land price", async function(){
        landPrice = await _battleRoyale.get_land_price(xP2, yP2);
        landPrice = landPrice.mul(ethers.BigNumber.from(dev_lev));
      });
      it("gets unit price", async function(){
        unitPrice = await _battleRoyale.get_unit_price(xP2,yP2);
        unitPrice = unitPrice.mul(unitsBought);
      });
      it("calcs total", async function(){
        total = landPrice.add(unitPrice);
      });
      it("P2 buys tile", async function(){
        await _battleRoyale.connect(p2signer).buy_land_with_wei(xP2,yP2,unitsBought,dev_lev, {value: total});
      });
      
    });
    describe("tile neighbors", function () {
      it("Deploys tile sphere", async function () {
        const tileSphereFactory = await ethers.getContractFactory("TileSphere");
        const tileSphere = await tileSphereFactory.deploy();
        await tileSphere.deployed();
        _tileSphere = tileSphere;
      });
      
        for (let i = 0; i < 42; i++) {
          let s = "tile " + i + " has neighbors set";
          it(s, async function () {
            var neighbors = [];
            for (let x = 0; x < 6; x++) {
              const neighbor = await _tileSphere.neighbors(i, x);
              neighbors.push(neighbor);
            }
            console.log(neighbors.toString());
          });
        } 
    });
    
    describe("tile automaton", function () {
      it("Deploys automaton library", async function () {
        const automatonFactory = await ethers.getContractFactory("Automata");
        const automaton = await automatonFactory.deploy();
        await automaton.deployed();
        _automaton = automaton
      });
    });

    describe("battle royale combat", function () {
      it("P2 attacks P1", async function(){
        await _battleRoyale.connect(p2signer).move(xP2,yP2,xP1,yP1, 10);
      });
    });
    */
    describe("NFT staking", function(){
     
      it("Player 1 unstakes beast", async function () {
        //await _nftStakePoolS0._unstake(_beastToken.address, 0);
      });
      it("P1 cant unstake again", async function () {
        //await expect(_nftStakePoolS0._unstake(_beastToken.address, 0)).to.be.reverted;
      });
      it("P1 earned XP", async function () {
      });
      it("P1 beast earned XP", async function () {
      });
      it("P1 beast advanced to current world season", async function () {
      });
    });
    /*describe("battle royale passable threshold", function () {
        for(let p = 1000; p <= 100000; p += 5000){
          it("", async function(){
            console.log(await _battleRoyale.get_passable_threshold_at(p));
          });
        }
    });
    describe("battle royale storm closing", function () {
      const mapsize = 60;
      let numpass = [];
      for(let p = 0; p <= 100000; p += 10000){
        let numPassable = 0;
        let pass = 0;
        it("gets passable threshold", async function(){
          pass = await _battleRoyale.get_passable_threshold_at(p);
        });
        
        for (let x = 0; x < mapsize; x++) {
          for (let y = 0; y < mapsize; y++) {
            let s = "gets tile " + x + "," + y;
            it(s, async function() {
              let tile = await _battleRoyale.get_tile(x,y);
              if(tile >= pass){
                numPassable++;
              }
              if(x == mapsize - 1 && y == mapsize - 1){
                console.log(pass.toString() + " " + numPassable)
                numpass.push(numPassable);
                if(p == 100000){
                  console.log(numpass);
                }
              };
            });
          }
        }  
      }
    });
  */
  });
});