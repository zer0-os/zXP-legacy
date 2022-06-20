pragma solidity ^0.8.0;

import "../Owned.sol";
import "./XpRecipient.sol"

contract ZXP is Owned{
    uint season;
    mapping(uint => bool) started;
    mapping(address => uint) locked;
    
    function startSeason() public ownerOnly {
        started[season] = true;
    } 
    
    function awardXP(XpRecipient awardee, uint amount) public {
        awardee.awardXP(amount);
    }

    function advanceSeason() public ownerOnly {
        season++;
    }

    function seasonLock(address a) public payable {
        locked[a] += msg.value;
    }

    function awardCharacterXP(Character char, uint256 amount) public {
        character.awardXP(amount);
    }

    function awardItemXP(Character char, uint256 amount) public {
        character.awardXP(amount);
    }

    function unlock(uint amt) public {
        payable(msg.sender).transfer(amt);
    }
}