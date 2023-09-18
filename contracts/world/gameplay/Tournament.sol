// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../Officiated.sol";
import "../../interfaces/IZXP.sol";
import "../RegistryClient.sol";
import "../base/XpRecipient.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../CharacterManager.sol";

contract Tournament is Officiated, RegistryClient {
    mapping(uint => bool) roundResolved;
    mapping(bytes32 => uint) winnings;

    constructor(
        IRegistry registry,
        address official,
        uint roundLength,
        uint roundReward
    ) RegistryClient(registry) Officiated(official, roundLength, roundReward) {}

    ///Each round interval, the official may submit results and divvy rewards
    function submitTop3Results(
        bytes32 firstPlace,
        bytes32 secondPlace,
        bytes32 thirdPlace,
        uint firstPrize,
        uint secondPrize,
        uint thirdPrize
    ) external payable officialOnly {
        require(
            msg.value == firstPrize + secondPrize + thirdPrize,
            "ZXP invalid payment"
        );
        winnings[firstPlace] += firstPrize;
        winnings[secondPlace] += secondPrize;
        winnings[thirdPlace] += thirdPrize;

        IZXP(addressOf("ZXP", season)).awardXP(uint(firstPlace), roundXpReward);
        IZXP(addressOf("ZXP", season)).awardXP(
            uint(secondPlace),
            roundXpReward
        );
        IZXP(addressOf("ZXP", season)).awardXP(uint(thirdPlace), roundXpReward);
    }

    function claimWinnings(bytes32 name) external virtual {
        address player = CharacterManager(
            registry.addressOf("CharacterManager", 1)
        ).characterPlayer(name);
        require(player == msg.sender, "ZXP Not character player");
        payable(player).transfer(winnings[name]);
    }
}
