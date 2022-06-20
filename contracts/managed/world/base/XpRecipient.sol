pragma solidity ^0.8.0;

contract Item is RegistryClient{
    uint256 public xp;

    modifier gameOnly() {
        require(true, "sender isnt registered game");
        _;
    }

    function awardXP(uint amount) gameOnly{
        xp += amount;
    }    
}