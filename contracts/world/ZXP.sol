// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Owned.sol";
import "./base/XpRecipient.sol";
import "./RegistryClient.sol";

contract ZXP is Owned, RegistryClient{
    uint base = 100;
    uint curve = 2;
    mapping(uint => uint) public xp;
    mapping(uint => uint) level;

    /// awards XP and levels up if the new xp value exceeds the threshold defined by the xp curve
    function awardXP(uint id, uint amount) external onlyGame(){
        xp[id] += amount;
        if(xp[id] > base * levelOf(id) * curve){
            level[id]++;
        }
    }
    ///Level starts at 1
    function levelOf(uint id) public view returns (uint){
        return level[id] + 1;
    }

    mapping(uint => bool) started;
    mapping(address => uint) locked;

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

    function advanceSeason() public ownerOnly {
        season++;
    }

    function equipLock(address a) public payable onlyArmory(){
        locked[a] += msg.value;
    }

    function unlock(uint amt) public {
        payable(msg.sender).transfer(amt);
    }
}