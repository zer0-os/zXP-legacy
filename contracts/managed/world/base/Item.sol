// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../RegistryClient.sol";
import "../../interfaces/IRegistry.sol";
import "./XpRecipient.sol";

contract Item is RegistryClient, XpRecipient{
    uint256 public currentSeason;
    bytes32 public itemType;
    bytes32 public generator;
    address public nftcontract;
    
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

    ///Attaches ItemType to NFT - Makes NFT owner the implicit owner of an Item of ItemType.
    function attach(address nftContractAddress) external onlyItemManager() {
        nftcontract = nftContractAddress;
    }

    function incrementSeason() external onlyItemManager() {
        currentSeason++;
    }

    function advanceToCurrentSeason(uint256 itemId) external onlyItemManager() {
        itemToSeason[itemId] = currentSeason;
    }
}