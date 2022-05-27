pragma solidity ^0.8.0;

import "./Owned.sol";
import "./items/base/Item.sol";

contract ZXP is Owned{
    function seasonLock() public payable {}

    function awardItemXP(Item item, uint256 amount)  {
        item.awardXP(amount);
    }
    
    function awardCharacterXP(Character char, uint256 amount) {
        character.awardXP(amount);
    }

    function unlock(uint amt) public onlyItemManager{
        payable(msg.sender).transfer(amt);
    }
}