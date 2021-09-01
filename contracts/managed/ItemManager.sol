pragma solidity ^0.8.0;

import "./ZXP.sol";
import "./Owned.sol";

contract ItemManager{
    
    modifier generated(bytes32 itemGenerator) {
        require(addressOf(itemGenerator) != address(0));
        _;
    }

}