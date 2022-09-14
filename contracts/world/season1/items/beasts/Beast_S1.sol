// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../../base/Item.sol";
import "../../../../interfaces/IRegistry.sol";
import "../../../../NftOwned.sol";
import "../../../base/Stats.sol";
import "../../../../interfaces/IZXP.sol";

contract Beast_S1 is NftOwned, Item, Stats{
    mapping(uint256 => bool) public wheelScrapped;

    constructor(bytes32 _generator, IRegistry registry, IERC721 nftContractAddress) 
    Item("Beast_S0", registry) 
    NftOwned(IERC721(nftContractAddress)){}

    function health(uint id) public view returns (uint) {
        return _health(IZXP(addressOf("ZXP", season)).levelOf(id));
    }
    function mana(uint id) public view returns (uint) {
        return _mana(IZXP(addressOf("ZXP", season)).levelOf(id));
    }
    function power(uint id) public view returns (uint) {
        return _power(IZXP(addressOf("ZXP", season)).levelOf(id));
    }
}