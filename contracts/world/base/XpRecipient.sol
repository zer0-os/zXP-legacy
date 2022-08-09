// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract XpRecipient{
    uint base = 100;
    uint curve = 2;
    mapping(uint => uint) public xp;
    mapping(uint => uint) level;

    /// awards XP and levels up if the new xp value exceeds the threshold defined by the xp curve
    function awardXP(uint id, uint amount) external {
        xp[id] += amount;
        if(xp[id] > base * levelOf(id) * curve){
            level[id]++;
        }
    }
    ///Level starts at 1
    function levelOf(uint id) public view returns (uint){
        return level[id] + 1;
    }
}