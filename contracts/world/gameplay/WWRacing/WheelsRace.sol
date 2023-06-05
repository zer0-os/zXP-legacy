// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract WheelsRace is ERC721URIStorage, EIP712, IERC721Receiver {
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

    ///Admin
    address public admin;

    /// Contract address of Wilder Wheels
    IERC721 public wheels;

    ///RaceIds that have been used
    mapping(uint256 => bool) private consumed;

    /// Mapping from tokenId to holder address
    mapping(uint256 => address) public stakedBy;

    /// Mapping from tokenId to unstake request time
    mapping(uint256 => uint256) public unstakeRequests;

    ///Time delay for unstaking
    uint256 public unstakeDelay = 1 seconds;

    modifier onlyStaker(uint256 tokenId) {
        require(stakedBy[tokenId] == msg.sender, "NFT not staked by sender");
        _;
    }

    modifier onlyAdmin() {
        require(admin == msg.sender, "Sender isnt admin");
        _;
    }

    constructor(
        string memory name,
        string memory version,
        string memory tokenName,
        string memory tokenSymbol,
        address _wilderWorld,
        IERC721 _wheels
    ) EIP712(name, version) ERC721(tokenName, tokenSymbol) {
        wilderWorld = _wilderWorld;
        wheels = _wheels;
        admin = msg.sender;
    }

    function createSlip(
        RaceSlip memory raceSlip
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

    function claimWin(
        RaceSlip memory opponentSlip,
        bytes memory opponentSignature,
        bytes memory wilderWorldSignature
    ) public {
        bytes32 hash = createSlip(opponentSlip);
        address oppSigner = ECDSA.recover(hash, opponentSignature);
        address wwSigner = ECDSA.recover(hash, wilderWorldSignature);

        require(
            block.timestamp < opponentSlip.raceExpiryTimestamp,
            "WR: Race expired"
        );
        require(wwSigner == wilderWorld, "WR: Not signed by Wilder World");
        require(oppSigner == opponentSlip.player, "WR: Not signed by opponent");
        require(msg.sender == opponentSlip.opponent, "WR: Wrong player");
        require(
            stakedBy[opponentSlip.wheelId] == opponentSlip.player,
            "WR: Opponent isnt staker"
        );
        require(!consumed[opponentSlip.raceId], "RaceId already used");

        consumed[opponentSlip.raceId] = true;
        delete stakedBy[opponentSlip.wheelId];
        _burn(opponentSlip.wheelId);

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

        IERC721Metadata token = IERC721Metadata(msg.sender);

        // Get the tokenURI of the incoming token
        string memory incomingTokenURI = token.tokenURI(tokenId);

        // Mint a new token with the same tokenId and tokenURI
        _mint(from, tokenId);
        _setTokenURI(tokenId, incomingTokenURI);

        return this.onERC721Received.selector;
    }

    function requestUnstake(uint256 tokenId) public onlyStaker(tokenId) {
        unstakeRequests[tokenId] = block.timestamp;
    }

    ///breaks if win claimed because NFT is transferred out
    function performUnstake(uint256 tokenId) public onlyStaker(tokenId) {
        require(unstakeRequests[tokenId] != 0, "No unstake request");
        require(
            block.timestamp >= unstakeRequests[tokenId] + unstakeDelay,
            "WR: Unstake delayed"
        );

        wheels.safeTransferFrom(address(this), msg.sender, tokenId);

        delete stakedBy[tokenId];
        delete unstakeRequests[tokenId];
        _burn(tokenId);
    }

    function cancelUnstake(uint256 tokenId) public onlyStaker(tokenId) {
        unstakeRequests[tokenId] = 0;
        _burn(tokenId);
    }

    function canRace(
        address p1,
        uint256 p1TokenId,
        address p2,
        uint256 p2TokenId
    ) public view returns (bool canStart) {
        require(unstakeRequests[p1TokenId] == 0, "P1 has unstake request");
        require(unstakeRequests[p2TokenId] == 0, "P2 has unstake request");
        require(stakedBy[p1TokenId] == p1, "P1 wheel not staked");
        require(stakedBy[p2TokenId] == p2, "P2 wheel not staked");
        canStart = true;
        return canStart;
    }

    function _recoverSigner(
        bytes32 hash,
        bytes memory signature
    ) private pure returns (address) {
        return ECDSA.recover(hash, signature);
    }

    //admin (testnet)
    function setWW(address newWW) public onlyAdmin {
        wilderWorld = newWW;
    }

    function setWheels(IERC721 newWheels) public onlyAdmin {
        wheels = newWheels;
    }

    function setUnstakeDelay(uint256 newDelay) public onlyAdmin {
        unstakeDelay = newDelay;
    }

    ///Ability to return NFTs mistakenly sent with transferFrom instead of safeTransferFrom
    function transferOut(address to, uint256 tokenId) public onlyAdmin {
        require(stakedBy[tokenId] == address(0));
        wheels.safeTransferFrom(address(this), to, tokenId);
    }

    function cancelRace(uint256 raceId) public onlyAdmin {
        consumed[raceId] = true;
    }

    // Overriding transfer function
    function _transfer(address, address, uint256) internal virtual override {
        require(false, "WR: Token is soulbound");
    }
}
