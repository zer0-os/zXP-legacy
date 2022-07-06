// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../RegistryClient.sol";
import "../../interfaces/IRegistry.sol";
import "../../PlayerOwned.sol";
import "./XpRecipient.sol";
import "./Traverser.sol";
import "./Stats.sol";

contract Character is PlayerOwned, RegistryClient, XpRecipient, Traverser, Stats{
    mapping(address => uint) public character;
    
    modifier zxpOnly() {
        require(addressOf("Zxp", season) == msg.sender, "ZXP: invalid zxp address");
        _;
    }

    constructor(
        IRegistry registry
    )
    RegistryClient(registry) {
    }


    function create() public virtual{
        //active[msg.sender] = true;
    }

    function advance() public {
        
    }
}