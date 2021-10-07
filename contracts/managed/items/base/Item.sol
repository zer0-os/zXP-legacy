pragma solidity ^0.8.0;

import "../../ContractRegistryClient.sol";
import "../../ZXP.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Item is ContractRegistryClient{
    uint256 public xp;
    uint256 public currentSeason;
    bytes32 public itemType;
    bytes32 public generator;
    
    mapping(bytes32 => uint256) public nftToItem;
    mapping(uint256 => address) public itemToNftContract;
    mapping(uint256 => uint256) public itemToNftId;
    mapping(uint256 => uint256) public itemToSeason;
    
    constructor(
        bytes32 itemTypeName,
        bytes32 generatorName,
        IContractRegistry registry
    )
    ContractRegistryClient(registry) {
        itemType = itemTypeName;
        generator = generatorName;
    }

    ///Attaches ItemType to NFT
    function attach(address nftContractAddress, uint256 nftId, uint256 wheelId) external virtual only(ITEM_MANAGER) {
        require(nftToItem[keccak256(abi.encode(nftContractAddress, nftId))] == 0, "Wheel: WheelID taken");
        nftToItem[keccak256(abi.encode(nftContractAddress, nftId))] = wheelId;
        itemToNftContract[wheelId] = nftContractAddress;
        itemToNftId[wheelId] = nftId;
        itemToSeason[wheelId] = currentSeason;
    }
    
    function awardXP(uint256 amount) external only(ZXP) {
        xp += amount;
    }

    function advanceToCurrentSeason(uint256 itemId) external only(ITEM_MANAGER){
        itemToSeason[itemId] = currentSeason;
    }
}