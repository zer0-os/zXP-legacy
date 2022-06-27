// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../base/Character.sol";

contract Character_S0 is Character{
    mapping(uint256 => bool) public wheelScrapped;

    constructor(IRegistry registry) 
    Character(registry) {}

}