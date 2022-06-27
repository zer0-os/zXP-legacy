// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../RegistryClient.sol";
import "../../interfaces/IRegistry.sol";
import "../../PlayerOwned.sol";
import "./XpRecipient.sol";

contract Character is PlayerOwned, RegistryClient, XpRecipient{
    
    uint cost;
    mapping(address => uint) character;
    
    struct Equips{
        uint pal;
        uint beast;
        uint wheel;
    }
    Equips public equipment;

    modifier zxpOnly() {
        require(addressOf("Zxp", season) == msg.sender, "non-authorized zxp address");
        _;
    }

    constructor(
        IRegistry registry
    )
    RegistryClient(registry) {
    }

    function equipPal(uint id) public playerOnly(msg.sender){
        //require("sender doesnt own wheel id");
        equipment.wheel = id;
    }
    function equipBeast(uint id) public playerOnly(msg.sender){
        //require("sender doesnt own wheel id");
        equipment.wheel = id;
    }
    function equipWheel(uint id) public playerOnly(msg.sender){
        //require("sender doesnt own wheel id");
        equipment.wheel = id;
    }

    function create(string memory name) public payable {
        require(msg.value == cost, "Invalid payment");
        character[msg.sender] = uint(keccak256(abi.encode(msg.sender, name)));
    }

    function advance() public {
    }

    function awardXP(uint amount) external override zxpOnly{

    }

}