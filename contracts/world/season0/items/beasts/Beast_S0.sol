// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../../base/Item.sol";
import "../../../../interfaces/IRegistry.sol";
import "../../../../NftOwned.sol";
import "../../../base/BeastStats.sol";

contract Beast_S0 is NftOwned, Item, BeastStats{

    constructor(bytes32 _generator, IRegistry registry, IERC721 nftContractAddress) 
    Item("Beast", registry) 
    NftOwned(IERC721(nftContractAddress)){}

    function health(uint id) public override view returns (uint) {
        super.health(id, level);
    }
    function mana(uint id) public override view returns (uint) {
        super.mana(id, level);
    }
    function power(uint id) public override view returns (uint) {
        super.power(id, level);
    }
}