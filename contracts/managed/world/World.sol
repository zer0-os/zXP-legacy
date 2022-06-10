pragma solidity ^0.8.0;

import "../Owned.sol";

contract World is Owned {
    uint season;
    mapping(uint => bool) started;
    function startSeason() public ownerOnly {
        started[season] = true;
    } 
    function advanceSeason() public ownerOnly {
        season++;
    }
}