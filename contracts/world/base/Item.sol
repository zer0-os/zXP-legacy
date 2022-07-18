// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../RegistryClient.sol";
import "../../interfaces/IRegistry.sol";
import "./XpRecipient.sol";

contract Item is RegistryClient, XpRecipient{
    bytes32 public itemType;
    
    mapping(uint256 => uint256) public itemToSeason;
    
    modifier onlyItemManager(){
        require(msg.sender == addressOf(ITEM_MANAGER, season), "Unauthorized item manager");
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
        itemToSeason[itemId] = season;
    }
}