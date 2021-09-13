pragma solidity ^0.8.0;

import "./Item.sol";

contract Engine is Item{
    uint256 fuelType;
    uint256 fuel;
    constructor(bytes32 _generator) Item(_generator) {}
    function refuel() external payable {
        fuel += msg.value;
    }
}