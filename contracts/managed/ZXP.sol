pragma solidity ^0.8.0;

import "./Owned.sol";

contract ZXP is Owned{
    function awardUserXP(address awardee, uint256 amount) internal {
        charXP[awardee] += amount;
    }
    
    function awardItemXP(uint256 awardee, uint256 amount) internal {
        itemXP[awardee] += amount;
    }
}