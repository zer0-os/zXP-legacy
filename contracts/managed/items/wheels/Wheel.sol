pragma solidity ^0.8.0;

import "../base/Item.sol";
//import "./Scrap.sol";
//import "./Engine.sol";
import "../../interfaces/IContractRegistry.sol";

contract Wheel is Item{

    uint256 currentSeason;

    mapping(bytes32 => uint256) nftToWheel;
    mapping(uint256 => bool) wheelScrapped;
    mapping(uint256 => uint256) wheelToSeason;

    constructor(bytes32 _generator, IContractRegistry registry) Item(_generator, registry) {}

    function scrap(uint256 wheelId) external only("ItemManager") {
        wheelScrapped[wheelId] = true;
    }

    function attach(address nftContractAddress, uint256 nftId, uint256 wheelId) external only("ItemManager") {
        require(nftToWheel[keccak256(abi.encode(nftContractAddress, nftId))] == 0, "Wheel: WheelID taken");
        nftToWheel[keccak256(abi.encode(nftContractAddress, nftId))] = wheelId;
        wheelToSeason[wheelId] = currentSeason;
    }
}