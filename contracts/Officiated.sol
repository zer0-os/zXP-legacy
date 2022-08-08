// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/**
  * @dev Provides support and utilities for contract ownership
*/
contract Officiated{
    address public official;
    uint startTime;
    uint roundLength;
    uint roundXpReward = 100;

    /**
      * @dev initializes a new Owned instance
    */
    constructor(address tournamentOfficial, uint _roundLength, uint _reward) {
        official = tournamentOfficial;
        startTime = block.timestamp;
        roundLength = _roundLength;
        roundXpReward = _reward;
    }

    // allows execution by the official only
    modifier officialOnly {
        _officialOnly();
        _;
    }

    function _officialOnly() internal view {
        require(msg.sender == official, "ZXP sender isnt official");
    }
}
