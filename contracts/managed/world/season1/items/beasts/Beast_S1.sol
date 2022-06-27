pragma solidity ^0.8.0;

import "../../../base/Item.sol";
import "../../../../interfaces/IRegistry.sol";
import "../../../../NftOwned.sol";

contract Beast_S1 is NftOwned, Item{
    mapping(uint256 => bool) public wheelScrapped;

    constructor(bytes32 _generator, IRegistry registry, IERC721 nftContractAddress) 
    Item("Beast_S0", registry) 
    NftOwned(IERC721(nftContractAddress)){}

    
}