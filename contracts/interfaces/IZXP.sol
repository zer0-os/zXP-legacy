// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IZXP{
    function awardXP(uint, uint) external;
    function levelOf(uint) external view returns (uint);
}