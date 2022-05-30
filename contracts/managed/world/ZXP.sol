pragma solidity ^0.8.14;

import "./items/base/Item.sol";

contract ZXP {
    mapping(address => uint) locked;

    function seasonLock(address a) public payable {
        locked[a] += msg.value;
    }

    function awardXP(uint256 amount)  {
        item.awardXP(amount);
    }
    
    function awardCharacterXP(Character char, uint256 amount) {
        character.awardXP(amount);
    }

    function unlock(uint amt) public only(){
        payable(msg.sender).transfer(amt);
    }
}