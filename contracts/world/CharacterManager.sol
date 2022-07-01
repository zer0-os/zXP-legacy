// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./base/Character.sol";
import "./RegistryClient.sol";

contract CharacterManager is RegistryClient{
    uint cost;

    mapping(address => uint) characterSeason;
    mapping(address => string) name;

    constructor(IRegistry registry) RegistryClient(registry) {}

    ///Creates character by setting season to 1
    function create() public payable {
        require(msg.value == cost, "Invalid payment");
        characterSeason[msg.sender] = 1;
    }

    function advance() public { 
        //require(characterSeason[msg.sender] < zxpSeason, "ZXP: Cant advance");
        characterSeason[msg.sender] += 1;
    }
}