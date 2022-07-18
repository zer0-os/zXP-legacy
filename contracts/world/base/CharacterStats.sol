// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CharacterStats{
    mapping(address => Stats) stats;
    struct Stats{
        uint health;
        uint mana;
        uint power;
    }
    function getStats(address a) public view returns(Stats memory){
        return stats[a];
    }
    function getHealth(address a) public view returns (uint){
        return stats[a].health;
    }
    function getMana(address a) public view returns (uint){
        return stats[a].mana;
    }
    function getPower(address a) public view returns (uint){
        return stats[a].power;
    }
}