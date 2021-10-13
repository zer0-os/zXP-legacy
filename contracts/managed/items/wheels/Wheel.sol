pragma solidity ^0.8.0;

import "../base/Item.sol";
//import "./Scrap.sol";
//import "./Engine.sol";
import "../../interfaces/IItemRegistry.sol";

contract Wheel is Item{
    mapping(uint256 => bool) wheelScrapped;

    constructor(bytes32 _generator, IItemRegistry registry) Item("Wheel", registry) {}

    function scrap(uint256 wheelId) external only(ITEM_MANAGER, 0) {
        wheelScrapped[wheelId] = true;
    }

}