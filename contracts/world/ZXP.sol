// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Owned.sol";
import "./base/XpRecipient.sol";
import "./RegistryClient.sol";

contract ZXP is Owned, RegistryClient{
    uint curve = 200;
    mapping(uint => uint) public xp;
    mapping(uint => uint) public itemSeason; 
    mapping(uint => uint) level;
    mapping(uint => uint) seasonFinalization;
    mapping(uint => uint) seasonFinalBlock;

    /// awards XP and levels up if the new xp value exceeds the threshold defined by the xp curve
    function awardXP(uint id, uint amount) public onlyGame(){
        _awardXP(id, amount);
    }
    
    //test
    function levelUp(uint id) public ownerOnly(){
        _awardXP(id, levelOf(id) * levelOf(id) * curve);        
    }

    function _awardXP(uint id, uint amount) internal {
        xp[id] += amount;
        if(xp[id] > levelOf(id) * levelOf(id) * curve){
            level[id]++;
        }
    }

    ///Level starts at 1
    function levelOf(uint id) public view returns (uint){
        return level[id] + 1;
    }

    mapping(uint => bool) started;
    mapping(address => uint) locked;

    modifier onlyType(uint t){
        require(typeOf(registry.name(msg.sender)) == t, "ZXP: Sender isnt type");
        _;
    }
    modifier onlyArmory(){
        require(msg.sender == addressOf("Armory", season), "ZXP Sender not armory");
        _;
    }

    modifier onlyGame(){
        require(typeOf(registry.name(msg.sender)) == 3, "ZXP: Sender isnt game");
        _;
    }

    constructor(IRegistry registry) RegistryClient(registry) {}
    
    function startSeason() public ownerOnly {
        started[season] = true;
    } 

    function endSeason() public ownerOnly {
        seasonFinalization[season] = uint(keccak256(abi.encode(block.difficulty, season)));
        seasonFinalBlock[season] = block.number;
        season++;
    }

    function advance(uint id) public onlyType(2){
        itemSeason[id]++; 
    }

    function equipLock(address a) public payable onlyArmory(){
        locked[a] += msg.value;
    }
    /// @param tokenHash keccak256(nftContractAddress, tokenId)
    function unlock(uint tokenHash) public {
       // payable(msg.sender).transfer(amt);
    }
}