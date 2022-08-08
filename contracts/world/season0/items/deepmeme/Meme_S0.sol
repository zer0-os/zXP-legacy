// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../../base/Item.sol";
import "../../../../interfaces/IRegistry.sol";
import "../../../../NftOwned.sol";
import "../../../base/BeastStats.sol";

contract Meme_S0 is NftOwned, Item, BeastStats{

    constructor(bytes32 _generator, IRegistry registry, IERC721 nftContractAddress) 
    Item("Beast", registry) 
    NftOwned(IERC721(nftContractAddress)){}

    function health(uint id) public view returns (uint) {
        _health(level[id]);
    }
    function mana(uint id) public view returns (uint) {
        _mana(level[id]);
    }
    function power(uint id) public view returns (uint) {
        _power(level[id]);
    }
}