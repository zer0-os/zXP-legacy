// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Automata{
    enum element{INNERT, WATER, EARTH, DARK, FIRE, AIR, LIGHT}
    struct automatons{
        element alignment;
        
        uint[7] ruleset;
    }
    mapping(uint => uint[7]) public rules; ///hexagonal, rules for 0 - 6 neighbors
    function createAutomaton(uint id) public returns(automatons memory automaton){
        //require()
        for (uint r = 0; r < 7; r++) {
                
        }
    }    
    
    ///get the next state of a single tile given its current state, count of neighbors on, and the applicable ruleset.
    ///the ruleset here assumes that 0 = dead, 1 = survive, 2 = born
    function nextState(bool on, uint256 neighborsOn, uint[] calldata ruleset) public pure returns (bool){
        if(ruleset[neighborsOn] == 2 || on && ruleset[neighborsOn] == 1){return true;}
        return false;
    } 
}