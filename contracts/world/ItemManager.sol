// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./base/Item.sol";
import "./RegistryClient.sol";
import "../interfaces/IRegistry.sol";

contract ItemManager is RegistryClient{

    constructor(IRegistry registry) RegistryClient(registry) {}
    
}