pragma solidity ^0.8.0;

import "../../base/Character.sol";

contract Character_S0 is Character{
    mapping(uint256 => bool) public wheelScrapped;

    constructor(bytes32 _generator, IRegistry registry, IERC721 nftContractAddress) 
    Character(registry) {}

}