// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../base/Character.sol";

contract Character_S0 is Character{
    
    mapping(address => Equips) equipment;

    constructor(IRegistry registry) 
    Character(registry) {}

    uint cost;
    
    struct Equips{
        uint pal;
        uint beast;
        uint wheel;
    }
    Equips public equips;
    

    modifier isActive(){
        require(active[msg.sender]);
        _;
    }

    function create()public override{

    }

    function equipPal(uint id) public playerOnly(msg.sender) isActive(){
        //require("sender doesnt own pal id");
        equipment[msg.sender].pal = id;
    }
    function equipBeast(uint id) public playerOnly(msg.sender) isActive(){
        //require("sender doesnt own beast id");
        equipment[msg.sender].beast = id;
    }
    function equipWheel(uint id) public playerOnly(msg.sender) isActive(){
        //require("sender doesnt own wheel id");
        equipment[msg.sender].wheel = id;
    }
}