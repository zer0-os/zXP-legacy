pragma solidity ^0.8.0;

import "../../../base/Item.sol";
//import "./Scrap.sol";
//import "./Engine.sol";
import "../../../../interfaces/IRegistry.sol";
import "../../../../interfaces/IERC721.sol";
import "../../../../NftOwned.sol";

contract Wheel_S0 is NftOwned, Item{
    mapping(uint256 => bool) public wheelScrapped;

    constructor(bytes32 _generator, IRegistry registry, IERC721 nftContractAddress) 
    Item("Wheel_S0", registry) 
    NftOwned(IERC721(nftContractAddress)){}

    function scrap(uint256 wheelId) external only(ITEM_MANAGER) {
        wheelScrapped[wheelId] = true;
    }

}