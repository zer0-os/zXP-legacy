pragma solidity ^0.8.0;

import "./Item.sol";
import "./Engine.sol";

contract Wheel is Item{

    mapping(uint256 => uint256) nftToWheel;
    mapping(uint256 => bool) wheelScrapped;
    mapping(uint256 => uint256) wheelToSeason;

    constructor() Item("Wheel") {}

    function scrap() external {}

    function attachWheel(address nftContractAddress, uint256 nftId, uint256 wheelId, uint256 season) internal {
        nftToWheel[keccak256(abi.encode(nftContractAddress, nftId))] = wheelId;
        wheelToSeason[wheelId] = season;
    }
}