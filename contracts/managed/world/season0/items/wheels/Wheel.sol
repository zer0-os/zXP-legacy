pragma solidity ^0.8.0;

import "../../../base/Item.sol";
//import "./Scrap.sol";
//import "./Engine.sol";
import "../../../../interfaces/IRegistry.sol";

contract Wheel is Item{
    mapping(uint256 => bool) public wheelScrapped;

    constructor(bytes32 _generator, IRegistry registry) Item("Wheel", registry) {}

    function scrap(uint256 wheelId) external only(ITEM_MANAGER) {
        wheelScrapped[wheelId] = true;
    }

}