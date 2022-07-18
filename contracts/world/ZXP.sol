// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Owned.sol";
import "./base/XpRecipient.sol";
import "./RegistryClient.sol";
import {ObjectTypes} from "../ObjectTypes.sol";

contract ZXP is Owned, RegistryClient{
    using ObjectTypes for ObjectTypes.ObjectType;
    mapping(uint => bool) started;
    mapping(address => uint) locked;

    modifier onlyArmory(){
        require(msg.sender == addressOf("Armory", season), "ZXP Sender not armory");
        _;
    }

    modifier onlyGame(){
        require(typeOf(msg.sender == ObjectTypes.ObjectType.GAME), "ZXP: Sender isnt game");
        _;
    }

    constructor(IRegistry registry) RegistryClient(registry) {}
    
    function startSeason() public ownerOnly {
        started[season] = true;
    } 
    
    function awardXP(XpRecipient recipient, uint amount) public {
        //recipient.awardXP(amount);
    }

    function advanceSeason() public ownerOnly {
        season++;
    }
    function equipLock(address a) public payable onlyGame(){
        locked[a] += msg.value;
    }
    function equipLock(address a) public payable onlyArmory(){
        locked[a] += msg.value;
    }

    function unlock(uint amt) public {
        payable(msg.sender).transfer(amt);
    }
}