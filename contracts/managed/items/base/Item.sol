pragma solidity ^0.8.0;

import "../../ItemRegistryClient.sol";
import "../../ZXP.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../../interfaces/IItemRegistry.sol";

contract Item is ItemRegistryClient{
    uint256 public xp;
    uint256 public currentSeason;
    bytes32 public itemType;
    bytes32 public generator;
    
    mapping(bytes32 => uint256) public nftToItem;
    mapping(uint256 => address) public itemToNftContract;
    mapping(uint256 => uint256) public itemToNftId;
    mapping(uint256 => uint256) public itemToSeason;
    
    modifier onlyItemManager(){
        require(msg.sender == itemManager);
        _;
    }
    constructor(
        bytes32 itemTypeName,
        IItemRegistry registry
    )
    ItemRegistryClient(registry) {
        itemType = itemTypeName;
    }

    ///Attaches ItemType to NFT - Makes NFT owner the implicit owner of an Item of ItemType
    function attach(address nftContractAddress, uint256 nftId, uint256 itemId) external virtual onlyItemManager() {
        require(nftToItem[keccak256(abi.encode(nftContractAddress, nftId))] == 0, "itemID taken");
        nftToItem[keccak256(abi.encode(nftContractAddress, nftId))] = itemId;
        itemToNftContract[itemId] = nftContractAddress;
        itemToNftId[itemId] = nftId;
        itemToSeason[itemId] = currentSeason;
    }

    function incrementSeason() external onlyItemManager() {
        currentSeason++;
    }
    
    function awardXP(uint256 amount) external onlyItemManager() {
        xp += amount;
    }

    function advanceToCurrentSeason(uint256 itemId) external onlyItemManager() {
        itemToSeason[itemId] = currentSeason;
    }
}