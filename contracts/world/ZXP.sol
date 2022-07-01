// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Owned.sol";
import "./base/XpRecipient.sol";

contract ZXP is Owned{
    uint season;
    mapping(uint => bool) started;
    mapping(address => uint) locked;
    
    function startSeason() public ownerOnly {
        started[season] = true;
    } 
    
    function awardXP(XpRecipient recipient, uint amount) public {
        recipient.awardXP(amount);
    }

    function advanceSeason() public ownerOnly {
        season++;
    }

    function seasonLock(address a) public payable {
        locked[a] += msg.value;
    }

    function unlock(uint amt) public {
        payable(msg.sender).transfer(amt);
    }
}