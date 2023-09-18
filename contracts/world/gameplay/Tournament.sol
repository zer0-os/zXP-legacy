// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../Officiated.sol";
import "../../interfaces/IZXP.sol";
import "../RegistryClient.sol";
import "../base/XpRecipient.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Tournament is Officiated, RegistryClient {
    mapping(uint => bool) roundResolved;
    mapping(uint => uint) winnings;

    constructor(
        IRegistry registry,
        address official,
        uint roundLength,
        uint roundReward
    ) RegistryClient(registry) Officiated(official, roundLength, roundReward) {}

    ///Each round interval, the official may submit results and divvy rewards
    function submitTop3Results(
        uint firstPlace,
        uint secondPlace,
        uint thirdPlace,
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

        IZXP(addressOf("ZXP", season)).awardXP(firstPlace, roundXpReward);
        IZXP(addressOf("ZXP", season)).awardXP(secondPlace, roundXpReward);
        IZXP(addressOf("ZXP", season)).awardXP(thirdPlace, roundXpReward);
    }

    function claimWinnings(uint character) external virtual {
        address player = IERC721(registry.addressOf("Character", season))
            .ownerOf(character);
        require(player != address(0), "ZXP No character");
        payable(player).transfer(winnings[character]);
    }
}
