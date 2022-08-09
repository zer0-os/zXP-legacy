// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../Officiated.sol";
import "../../interfaces/IZXP.sol";
import "../RegistryClient.sol";
import "../base/XpRecipient.sol";
///Free-for-all style tournament, players don't know what 'team' they're on until they 
contract BattleTournament is Officiated, RegistryClient{
    mapping(uint => bool) roundResolved;
    mapping(uint => uint) winnings; 
    mapping(address => uint) lastRoundBattled;
    mapping(uint => uint) finalization; /// Per-round RNG for determining battle winners
    uint battlerWinnings;

    constructor(IRegistry registry, address official, uint roundLength, uint roundReward) 
    RegistryClient(registry)
    Officiated(official, roundLength, roundReward){}

    /// Each round interval, the official may submit results and divvy rewards 
    function submitTop3Results(
        uint firstPlace, 
        uint secondPlace, 
        uint thirdPlace, 
        uint firstPrize, 
        uint secondPrize, 
        uint thirdPrize) 
        external officialOnly() payable
    {
        require(msg.value == 2 * (firstPrize + secondPrize + thirdPrize), "ZXP invalid payment");
        require(finalization[(block.timestamp - startTime) / roundLength] == 0, "ZXP round already resolved");
        
        winnings[firstPlace] += firstPrize;
        winnings[secondPlace] += secondPrize;
        winnings[thirdPlace] += thirdPrize;
        battlerWinnings += msg.value / 2; ///because we required the value to be 2 * prizes
        finalization[(block.timestamp - startTime) / roundLength] = block.difficulty;
        
        IZXP(addressOf("ZXP", season)).awardXP(firstPlace, roundXpReward);
        IZXP(addressOf("ZXP", season)).awardXP(secondPlace, roundXpReward);
        IZXP(addressOf("ZXP", season)).awardXP(thirdPlace, roundXpReward);
        //IZXP(addressOf("ZXP", season)).awardXP(official, roundXpReward);
    }

    function battle(uint id) public {
        require(lastRoundBattled[msg.sender] < block.timestamp/roundLength, "ZXP already battled");
        lastRoundBattled[msg.sender] = block.timestamp/roundLength;
        IZXP(addressOf("ZXP", season)).awardXP(id, roundXpReward);
    }
}