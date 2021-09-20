pragma solidity ^0.8.0;

import "../../ContractRegistryClient.sol";
import "./Generated.sol";
import "../../ZXP.sol";
//import "";

contract Item is Generated, ContractRegistryClient{
    uint256 xp;
    uint256 currentSeason;
    mapping(bytes32 => uint256) nftToItem;
    mapping(uint256 => uint256) itemToSeason;

    //modifier onlyNftOwner(){
    //}

    /// @param generator the name of the generator in the contract registry
    constructor(
        bytes32 generator,
        IContractRegistry registry
    )
    Generated(generator) 
    ContractRegistryClient(registry) {}

    ///Attaches ItemType to NFT
    function attach(address nftContractAddress, uint256 nftId, uint256 wheelId) external virtual only(ITEM_MANAGER) {
        require(nftToItem[keccak256(abi.encode(nftContractAddress, nftId))] == 0, "Wheel: WheelID taken");
        nftToItem[keccak256(abi.encode(nftContractAddress, nftId))] = wheelId;
        itemToSeason[wheelId] = currentSeason;
    }
    
    function awardXP(uint256 amount) external only(ZXP) {
        xp += amount;
    }
}