// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BeastStats{
    uint randSeed;
    uint levelCoef = 25;
    uint baseHealth = 120;
    uint baseMana = 60;
    uint basePower = 20;
    uint baseCoef = 10;
    uint baseMod = 3;

    constructor() {
        randSeed = block.difficulty;
    }

    function health(address a, uint level) public virtual view returns (uint){
        return (1 + randSeed % baseMod) * baseHealth * baseCoef + levelCoef * level;
    } 
    function mana(address a, uint level) public virtual view returns (uint){
        return (1 + randSeed % baseMod) * baseHealth * baseCoef + levelCoef * level;
    }
    function power(address a, uint level) public virtual view returns (uint){
        return (1 + randSeed % baseMod) * baseHealth * baseCoef + levelCoef * level;
    }
}