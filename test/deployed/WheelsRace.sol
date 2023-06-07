// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
 * @title WheelsRace
 * @dev A contract for staking NFTs and engaging in a race. Winners can claim other's staked NFTs.
 * Uses ERC721 standards for token manipulations.
 */
contract WheelsRace is EIP712, IERC721Receiver {
    /// The EIP-712 type definitions
    struct RaceSlip {
        address player;
        address opponent;
        uint256 raceId;
        uint256 wheelId;
        uint256 raceStartTimestamp;
        uint256 raceExpiryTimestamp;
    }

    /// The EIP-712 domain separators
    bytes32 private constant RACE_SLIP_TYPEHASH =
        keccak256(
            "RaceSlip(address player,address opponent,uint256 raceId,uint256 wheelId,uint256 raceStartTimestamp,uint256 raceExpiryTimestamp)"
        );

    /// Wallet address of wilder world used to sign WinnerDeclarations
    address public wilderWorld;

    /// Contract address of Wilder Wheels
    IERC721 public wheels;

    /// Mapping from tokenId to holder address
    mapping(uint256 => address) public stakedBy;

    /// Mapping from tokenId to unstake request time
    mapping(uint256 => uint256) public unstakeRequests;

    uint256 private UNSTAKE_DELAY = 1 days;

    modifier onlyStaker(uint256 tokenId) {
        require(stakedBy[tokenId] == msg.sender, "NFT not staked by sender");
        _;
    }

    constructor(
        string calldata name,
        string calldata version,
        address _wilderWorld,
        IERC721 _wheels
    ) EIP712(name, version) {
        wilderWorld = _wilderWorld;
        wheels = _wheels;
    }

    /**
     * @dev Generates a hash for a race slip.
     */
    function createSlip(
        RaceSlip calldata raceSlip
    ) public view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        RACE_SLIP_TYPEHASH,
                        raceSlip.player,
                        raceSlip.opponent,
                        raceSlip.raceId,
                        raceSlip.wheelId,
                        raceSlip.raceStartTimestamp,
                        raceSlip.raceExpiryTimestamp
                    )
                )
            );
    }

    /**
     * @dev Allows players to claim wins. This function accepts the race details,
     * opponent's signature and Wilder World's signature as proof.
     * @param opponentSlip The EIP-712 typedData.message the opponent signed
     * @param opponentSignature The player's signature on the opponentSlip
     * @param wilderWorldSignature The official Wilder World signature on the opponentSlip
     */
    function claimWin(
        RaceSlip calldata opponentSlip,
        bytes calldata opponentSignature,
        bytes calldata wilderWorldSignature
    ) public {
        bytes32 hash = createSlip(opponentSlip);
        require(!canceled[hash], "Canceled before start");
        address oppSigner = ECDSA.recover(hash, opponentSignature);
        address wwSigner = ECDSA.recover(hash, wilderWorldSignature);

        require(wwSigner == wilderWorld, "WR: Not signed by Wilder World");
        require(oppSigner == opponentSlip.player, "WR: Not signed by opponent");
        require(msg.sender == opponentSlip.opponent, "WR: Wrong player");

        delete stakedBy[opponentSlip.wheelId];

        wheels.safeTransferFrom(
            address(this),
            msg.sender,
            opponentSlip.wheelId
        );
    }

    function onERC721Received(
        address,
        address from,
        uint256 tokenId,
        bytes calldata
    ) public override returns (bytes4) {
        require(msg.sender == address(wheels), "NFT isnt Wilder Wheel");
        stakedBy[tokenId] = from;
        unstakeRequests[tokenId] = 0;
        return this.onERC721Received.selector;
    }

    function requestUnstake(uint256 tokenId) public onlyStaker(tokenId) {
        require(stakedBy[tokenId] == msg.sender, "NFT not staked by sender");
        unstakeRequests[tokenId] = block.timestamp;
    }

    ///breaks if win claimed because NFT is transferred out
    function performUnstake(uint256 tokenId) public onlyStaker(tokenId) {
        require(unstakeRequests[tokenId] != 0, "No unstake request");
        require(
            block.timestamp >= unstakeRequests[tokenId] + UNSTAKE_DELAY,
            "WR: Unstake delayed"
        );

        wheels.safeTransferFrom(address(this), msg.sender, tokenId);

        delete stakedBy[tokenId];
        delete unstakeRequests[tokenId];
    }

    function cancelUnstake(uint256 tokenId) public onlyStaker(tokenId) {
        unstakeRequests[tokenId] = 0;
    }

    function canRace(uint256 tokenId) public view returns (bool) {
        return unstakeRequests[tokenId] == 0;
    }

    function _recoverSigner(
        bytes32 hash,
        bytes calldata signature
    ) private pure returns (address) {
        return ECDSA.recover(hash, signature);
    }

    //testnet only, remove for main
    function setWW(address newWW) public {
        wilderWorld = newWW;
    }

    //testnet only, remove for main
    function setWheels(IERC721 newWheels) public {
        wheels = newWheels;
    }
}
