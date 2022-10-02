// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library Automaton{
    ///get the next state of a single tile given its current state, count of neighbors on, and the applicable ruleset.
    ///the ruleset here assumes that 0 = dead, 1 = survive, 2 = born
    function nextState(bool on, uint256 neighborsOn, uint[] calldata rules) public pure returns (bool){
        if(rules[neighborsOn] == 2 || on && rules[neighborsOn] == 1){return true;}
        return false;
    } 
}