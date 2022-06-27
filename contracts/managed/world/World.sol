// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Owned.sol";
///To upgrade world functionality you must release a new world and registry, starting a fresh environment
///Players then can choose to move their characters to the new world
contract World is Owned{
    uint season;
    mapping(uint => bool) started;
    mapping(address => uint) locked;
    
    function startSeason() public ownerOnly {
        started[season] = true;
    } 
    
    function advanceSeason() public ownerOnly {
        season++;
    }

    function seasonLock(address a) public payable {
        locked[a] += msg.value;
    }
    
    //function awardCharacterXP(Character char, uint256 amount) public {
    //    character.awardXP(amount);
    //}

    function unlock(uint amt) public {
        payable(msg.sender).transfer(amt);
    }
}