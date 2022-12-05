// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IZXP{
    function setSeason(uint, uint) external;
    function awardXP(uint, uint) external;
    function levelOf(uint) external view returns (uint);
    function advance(uint) external;
    function itemSeason(uint) external view returns(uint);
}