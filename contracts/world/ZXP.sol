// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Owned.sol";
import "./base/XpRecipient.sol";
import "./RegistryClient.sol";
import {ObjectTypes} from "../ObjectTypes.sol";

contract ZXP is Owned, RegistryClient{
    using ObjectTypes for ObjectTypes.ObjectType;

    uint xpCurveBase = 100;
    uint xpCurve = 2;

    mapping(uint => bool) started;
    mapping(address => uint) locked;

    modifier onlyArmory(){
        require(msg.sender == addressOf("Armory", season), "ZXP Sender not armory");
        _;
    }

    //modifier onlyGame(){
    //    require(typeOf(msg.sender == ObjectTypes.ObjectType.GAME), "ZXP: Sender isnt game");
    //    _;
    //}

    constructor(IRegistry registry) RegistryClient(registry) {}
    
    function startSeason() public ownerOnly {
        started[season] = true;
    } 
    /// @dev TODO figure out restriction onlyXpAwarder
    function awardXP(XpRecipient recipient, uint recipientId,  uint amount) public {
        recipient.awardXP(recipientId, amount);
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