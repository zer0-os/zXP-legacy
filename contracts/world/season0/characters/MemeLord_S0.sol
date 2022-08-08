// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../base/Character.sol";

contract MemeLord_S0 is Character{
    constructor(IRegistry registry) 
    Character(registry) {}

    function equipPal(uint id) public playerOnly(msg.sender) {
        //require("sender doesnt own pal id");
        equipment[msg.sender].pal = id;
    }
    function equipBeast(uint id) public playerOnly(msg.sender) {
        //require("sender doesnt own beast id");
        equipment[msg.sender].beast = id;
    }
    function equipWheel(uint id) public playerOnly(msg.sender) {
        //require("sender doesnt own wheel id");
        equipment[msg.sender].wheel = id;
    }
}