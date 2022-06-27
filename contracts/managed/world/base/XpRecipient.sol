// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract XpRecipient{
    uint256 public xp;

    function awardXP(uint amount) external virtual {
        xp += amount;
    }    
}