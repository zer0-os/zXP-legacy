pragma solidity ^0.8.0;

import "./items/base/Item.sol";


contract ZXP {
    mapping(address => uint) locked;

    function seasonLock(address a) public payable {
        locked[a] += msg.value;
    }

    function awardItemXP(Item item, uint256 amount) public  {
        item.awardXP(amount);
    }
    
    //function awardCharacterXP(Character char, uint256 amount) public {
    //    character.awardXP(amount);
    //}

    function unlock(uint amt) public {
        payable(msg.sender).transfer(amt);
    }
}