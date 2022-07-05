// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract XpRecipient{
    uint base = 1000;
    uint curve = 2;
    mapping(uint => uint) public xp;
    mapping(uint => uint) public level;

    function awardXP(uint id, uint amount) external virtual {
        xp[id] += amount;
        if(xp[id] > base * level[id] * curve){
            level[id]++;
        }
    }    
}