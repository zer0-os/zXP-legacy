// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../RegistryClient.sol";
import "../../interfaces/IRegistry.sol";
import "../../PlayerOwned.sol";
import "./XpRecipient.sol";
import "./Traverser.sol";
import "./Stats.sol";
import "./Equipment.sol";

contract Character is RegistryClient, XpRecipient, Traverser, Stats, Equipment{
    mapping(address => uint) public character;
    
    modifier playerOnly(uint id){
        require(character[msg.sender] == id);
        _;
    }

    modifier characterManagerOnly() {
        require(addressOf("CharacterManager", season) == msg.sender, "ZXP: invalid manager address");
        _;
    }

    constructor(
        IRegistry registry
    )
    RegistryClient(registry) {
    }


    function create(address a, uint id) public characterManagerOnly(){
        character[a] = id;
    }

}