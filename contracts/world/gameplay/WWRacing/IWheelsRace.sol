// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

interface IWheelsRace is IERC721, IERC721Receiver {
    struct RaceSlip {
        address player;
        address opponent;
        uint raceId;
        uint wheelId;
        uint opponentWheelId;
        uint raceStartTimestamp;
    }

    function wilderWorld() external view returns (address);

    function stakedBy(uint256) external view returns (address);

    function claimWin(
        RaceSlip memory opponentSlip,
        bytes memory opponentSignature,
        bytes memory wilderWorldSignature
    ) external;

    function requestUnstake(uint256 tokenId) external;

    function performUnstake(uint256 tokenId) external;

    function cancelUnstake(uint256 tokenId) external;

    function cancel(RaceSlip calldata slip) external;

    function isCanceled(RaceSlip calldata slip) external view returns (bool);

    function createSlip(
        RaceSlip memory raceSlip
    ) external view returns (bytes32);

    function canRace(
        address p1,
        uint p1TokenId,
        address p2,
        uint p2TokenId
    ) external view returns (bool);

    function setWW(address newAdmin) external;

    function setWheels(IERC721 newWheels) external;

    function setExpirePeriod(uint newLock) external;

    function transferOut(address to, uint tokenId) external;

    function transferLocked(address to, uint tokenId) external;

    function cancelRace(uint raceId) external;
}
