// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../RegistryClient.sol";
import "../../interfaces/IRegistry.sol";
import "./XpRecipient.sol";

contract Equipment {
    mapping(address => Equips) public equipment;
        
    struct Equips{
        uint pal;
        uint beast;
        uint wheel;
    }
    Equips public equips;
}