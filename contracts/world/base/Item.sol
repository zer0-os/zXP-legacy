// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../RegistryClient.sol";
import "../../interfaces/IRegistry.sol";
import "./XpRecipient.sol";

contract Item is RegistryClient, XpRecipient{
    bytes32 public itemType;
    
    modifier onlyItemManager(){
        require(msg.sender == addressOf("ItemManager", season), "Unauthorized item manager");
        _;
    }
    constructor(
        bytes32 itemTypeName,
        IRegistry registry
    )
    RegistryClient(registry) {
        itemType = itemTypeName;
    }

    function advanceToCurrentSeason(uint256 itemId) external onlyItemManager() {
        //season[itemId] = currentWorldSeason();
    }
}