// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract WheelsRace is EIP712, IERC721Receiver {
    /// The EIP-712 type definitions
    struct RaceStartDeclaration {
        address player;
        address opponent;
        uint256 raceId;
        uint256 wheelId;
        uint256 raceStartTimestamp;
        uint256 raceExpiryTimestamp;
    }

    struct WinnerDeclaration {
        address winner;
        uint256 raceId;
        uint256 winTimestamp;
    }

    /// The EIP-712 domain separators
    bytes32 private constant RACE_START_DECLARATION_TYPEHASH =
        keccak256(
            "RaceStartDeclaration(address player,address opponent,uint256 raceId,uint256 wheelId,uint256 raceStartTimestamp,uint256 raceExpiryTimestamp)"
        );
    bytes32 private constant WINNER_DECLARATION_TYPEHASH =
        keccak256(
            "WinnerDeclaration(address winner,uint256 raceId,uint256 winTimestamp)"
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
        string memory name,
        string memory version,
        address _wilderWorld,
        IERC721 _wheels
    ) EIP712(name, version) {
        wilderWorld = _wilderWorld;
        wheels = _wheels;
    }

    function createRaceStartDeclarationHash(
        RaceStartDeclaration memory raceStartDeclaration
    ) public view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        RACE_START_DECLARATION_TYPEHASH,
                        raceStartDeclaration.player,
                        raceStartDeclaration.opponent,
                        raceStartDeclaration.raceId,
                        raceStartDeclaration.wheelId,
                        raceStartDeclaration.raceStartTimestamp,
                        raceStartDeclaration.raceExpiryTimestamp
                    )
                )
            );
    }

    function createWinDeclarationHash(
        WinnerDeclaration memory winnerDeclaration
    ) public view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        WINNER_DECLARATION_TYPEHASH,
                        winnerDeclaration.winner,
                        winnerDeclaration.raceId,
                        winnerDeclaration.winTimestamp
                    )
                )
            );
    }

    function claimWin(
        WinnerDeclaration memory winnerDeclaration,
        bytes memory wilderworldSignature,
        RaceStartDeclaration memory opponentStartDeclaration,
        bytes memory opponentSignature
    ) public {
        require(
            winnerDeclaration.raceId == opponentStartDeclaration.raceId,
            "RaceID does not match"
        );

        bytes32 hash = createWinDeclarationHash(winnerDeclaration);
        address signer = ECDSA.recover(hash, wilderworldSignature);

        require(signer == wilderWorld, "Not signed by Wilder World");
        require(winnerDeclaration.winner == msg.sender, "Not the winner");

        bytes32 hashStart = createRaceStartDeclarationHash(
            opponentStartDeclaration
        );
        address opponent = _recoverSigner(hashStart, opponentSignature);
        require(
            opponent == opponentStartDeclaration.player,
            "Not signed by opponent"
        );

        delete stakedBy[opponentStartDeclaration.wheelId];

        wheels.safeTransferFrom(
            address(this),
            winnerDeclaration.winner,
            opponentStartDeclaration.wheelId
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
            "Unstake delay not passed"
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
        bytes memory signature
    ) private pure returns (address) {
        return ECDSA.recover(hash, signature);
    }
}
