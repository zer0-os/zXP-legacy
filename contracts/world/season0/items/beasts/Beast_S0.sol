// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../../base/Item.sol";
import "../../../../interfaces/IRegistry.sol";
import "../../../../NftOwned.sol";
import "../../../base/Stats.sol";

contract Beast_S0 is NftOwned, Item, Stats{

    constructor(bytes32 _generator, IRegistry registry, IERC721 nftContractAddress) 
    Item("Beast_S0", registry) 
    NftOwned(IERC721(nftContractAddress)){}
}