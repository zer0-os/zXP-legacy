pragma solidity 0.8.14;

import "../Owned.sol";

contract World is Owned {
    uint season;
    mapping(uint => bool) started;
    function startSeason() ownerOnly {
        started[season] = true;
    } 
    function advanceSeason() ownerOnly {
        season++;
    }
}