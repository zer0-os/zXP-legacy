pragma solidity ^0.8.0;

contract Item {
    
    address public currentSeason;
    bytes32 public generator;

    constructor(
        bytes32 _generator
    ) {
        generator = _generator;
    }

}