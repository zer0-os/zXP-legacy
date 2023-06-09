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

    /// Mapping from slip hash to canceled status
    mapping(bytes32 => bool) private canceled;
    uint256 private cancelBuffer;

    /// Mapping from wheelId to time locked after win claim
    mapping(uint256 => uint256) lockTime;
    uint256 private lockPeriod = 7 days;

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
                        raceSlip.raceStartTimestamp, //slipStartTime
                        raceSlip.raceExpiryTimestamp //slipExpiryTime
                    )
                )
            );
    }

    function claimWin(
        RaceSlip calldata opponentSlip,
        bytes calldata opponentSignature,
        bytes calldata wilderWorldSignature
    ) public {
        bytes32 hash = createSlip(opponentSlip);
        require(!canceled[hash], "Canceled before start");
        require(
            block.timestamp > opponentSlip.raceStartTimestamp,
            "WR: Race hasnt started"
        );
        require(
            block.timestamp >= lockTime[opponentSlip.wheelId] + lockPeriod,
            "WR: Within lock period"
        );

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
        ///Set state for wheel
        stakedBy[opponentSlip.wheelId] = msg.sender;
        lockTime[opponentSlip.wheelId] = block.timestamp;
        ///Transfer wheel_staked
        _transfer(opponentSlip.player, msg.sender, opponentSlip.wheelId);
    }

    function cancel(RaceSlip calldata slip) public {
        require(msg.sender == slip.player, "WR: Sender isnt player");
        require(
            block.timestamp < slip.raceStartTimestamp - cancelBuffer,
            "WR: Cancel period ended"
        );
        bytes32 hash = createSlip(slip);
        canceled[hash] = true;
    }

    function isCanceled(RaceSlip calldata slip) public view returns (bool) {
        bytes32 hash = createSlip(slip);
        return canceled[hash];
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
        require(
            block.timestamp >= lockTime[tokenId] + lockPeriod,
            "WR: Within lock period"
        );
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

    /**
     * @dev Tells you if a race can start by erroring if false
     * @param p1 Player 1 address
     * @param p1TokenId Player 1 Wheel Token ID
     * @param p2 Player 2 address
     * @param p2TokenId Player 2 Wheel Token ID
     */
    function canRace(
        address p1,
        uint256 p1TokenId,
        address p2,
        uint256 p2TokenId
    ) public view {
        require(unstakeRequests[p1TokenId] == 0, "P1 has unstake request");
        require(unstakeRequests[p2TokenId] == 0, "P2 has unstake request");
        require(stakedBy[p1TokenId] == p1, "P1 wheel not staked");
        require(stakedBy[p2TokenId] == p2, "P2 wheel not staked");
        require(
            block.timestamp >= lockTime[p1TokenId] + lockPeriod,
            "WR: P1 within lock period"
        );
        require(
            block.timestamp >= lockTime[p2TokenId] + lockPeriod,
            "WR: P2 within lock period"
        );
    }

    function _recoverSigner(
        bytes32 hash,
        bytes calldata signature
    ) private pure returns (address) {
        return ECDSA.recover(hash, signature);
    }

    ///To turn off claimWin, set this to a burn address other than 0
    function setWW(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0), "WR: missing newAdmin");
        wilderWorld = newAdmin;
    }

    function setWheels(IERC721 newWheels) public onlyAdmin {
        require(address(newWheels) != address(0), "WR: missing newWheels");
        wheels = newWheels;
    }

    function setUnstakeDelay(uint256 newDelay) public onlyAdmin {
        require(newDelay != 0, "WR: missing newDelay");
        unstakeDelay = newDelay;
    }

    function setLockPeriod(uint256 newLock) public onlyAdmin {
        require(newLock != 0, "WR: missing newLock");
        lockPeriod = newLock;
    }

    ///Ability to return NFTs mistakenly sent with transferFrom instead of safeTransferFrom
    function transferOut(address to, uint256 tokenId) public onlyAdmin {
        require(stakedBy[tokenId] == address(0));
        wheels.safeTransferFrom(address(this), to, tokenId);
    }

    ///Ability to 'undo' a race by removing a locked nft
    function transferLocked(address to, uint256 tokenId) public onlyAdmin {
        require(block.timestamp >= lockTime[tokenId], "WR: token not locked");
        require(
            block.timestamp < lockTime[tokenId] + lockPeriod,
            "WR: token unlocked"
        );
        wheels.safeTransferFrom(address(this), to, tokenId);
    }

    function cancelRace(uint256 raceId) public onlyAdmin {
        consumed[raceId] = true;
    }

    // Overriding transfer functions
    function transferFrom(address, address, uint256) public override {
        require(false, "WR: Token is soulbound");
    }

    // Overriding transfer function
    function safeTransferFrom(address, address, uint256) public override {
        require(false, "WR: Token is soulbound");
    }
}
