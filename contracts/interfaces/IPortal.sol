// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IPortal{
    function awardXP(uint, uint) external;
    function levelOf(uint) external view returns (uint);
}