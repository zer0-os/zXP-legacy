pragma solidity ^0.8.0;

import "../base/Item.sol";
//import "./Scrap.sol";
//import "./Engine.sol";
import "../../interfaces/IContractRegistry.sol";

contract Wheel is Item{
    mapping(uint256 => bool) wheelScrapped;

    constructor(bytes32 _generator, IContractRegistry registry) Item(_generator, registry) {}

    function scrap(uint256 wheelId) external only("ItemManager") {
        wheelScrapped[wheelId] = true;
    }

}