pragma solidity ^0.8.0;

import "./Item.sol";
import "./Engine.sol";

contract Wheel is Item{

    mapping(bytes32 => uint256) nftToWheel;
    mapping(uint256 => bool) wheelScrapped;
    mapping(uint256 => uint256) wheelToSeason;

    constructor(bytes32 _generator) Item(_generator) {}

    function scrap() external {}

    function attach(address nftContractAddress, uint256 nftId, uint256 wheelId, uint256 season) internal {
        require(nftToWheel[keccak256(abi.encode(nftContractAddress, nftId))] == 0, "Wheel: WheelID taken");
        nftToWheel[keccak256(abi.encode(nftContractAddress, nftId))] = wheelId;
        wheelToSeason[wheelId] = season;
    }
}