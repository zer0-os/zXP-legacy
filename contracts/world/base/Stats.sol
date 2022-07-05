// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Stats{
    mapping(address => Stats) stats;
    struct Stats{
        uint health;
        uint mana;
        uint power;
    }
    function getStats(address a) public view returns(Stats memory){
        return stats[a];
    }
}