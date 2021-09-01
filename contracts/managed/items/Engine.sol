pragma solidity ^0.8.0;

import "./Item.sol";

contract Engine is Item{
    uint256 fuelType;
    uint256 fuel;
    function refuel(uint256 addedFuel) external {
        fuel += addedFuel;
    }
}