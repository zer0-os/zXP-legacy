// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../../base/Item.sol";
import "../../../../interfaces/IRegistry.sol";
import "../../../../NftOwned.sol";

contract Meme_S0 is NftOwned, Item{

    constructor(IRegistry registry, IERC721 nftContractAddress) 
    Item("Meme", registry) 
    NftOwned(IERC721(nftContractAddress)){}

    ///This is where custom Meme logic goes
}