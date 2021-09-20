pragma solidity ^0.8.0;

import "./Owned.sol";
import "./items/base/Item.sol";

contract ZXP is Owned{
    function awardItemXP(Item item, uint256 amount) internal {
        item.awardXP(amount);
    }
}