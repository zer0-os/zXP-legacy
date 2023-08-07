// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract WheelsRaceSeason is ERC721URIStorage, EIP712, IERC721Receiver {
    error NotStaker(address player, uint256 tokenId, address stakedBy);
    error Unstaking(uint256 tokenId, uint256 unstakeTime);
    error Locked(uint256 tokenId, uint256 lockTime);

    /// The EIP-712 type definitions
    struct RaceSlip {
        address player;
        address opponent;
        uint raceId;
        uint wheelId;
        uint opponentWheelId;
        uint raceStartTimestamp;
    }

    /// The EIP-712 domain separators
    bytes32 private constant RACE_SLIP_TYPEHASH =
        keccak256(
            "RaceSlip(address player,address opponent,uint raceId,uint wheelId,uint opponentWheelId,uint raceStartTimestamp)"
        );

    /// Wallet address of wilder world used to sign losing opponents race slip
    address public wilderWorld;

    /// Admin
    address private admin;

    /// Contract address of Wilder Wheels
    IERC721 public wheels;

    /// Length of time before races expire after their startTimestamp
    /// Also controls unstake delay period, making the races secure by disallowing unstaking during a race, as long as canRace is checked before.
    uint public expirePeriod = 24 hours;

    ///RaceIds that have been used
    mapping(uint => bool) private consumed;

    /// Mapping from tokenId to holder address
    mapping(uint => address) public stakedBy;

    /// Mapping from slip hash to canceled status
    mapping(bytes32 => bool) private canceled;
    uint private cancelBuffer;

    /// Mapping from wheelId to time locked after win claim
    mapping(uint => uint) lockTime;
    //uint private lockPeriod = 24 hours;

    /// Mapping from tokenId to unstake request time
    mapping(uint => uint) private unstakeRequests;

    modifier isStakerOrOperator(address stakerOperator, uint tokenId) {
        if (
            stakedBy[tokenId] != stakerOperator &&
            getApproved(tokenId) != stakerOperator
        ) {
            revert NotStaker(stakerOperator, tokenId, stakedBy[tokenId]);
        }
        _;
    }

    modifier isStaked(uint256 tokenId) {
        if (unstakeRequests[tokenId] != 0) {
            revert Unstaking(tokenId, unstakeRequests[tokenId]);
        }
        _;
    }

    modifier isUnlocked(uint256 tokenId) {
        if (block.timestamp <= lockTime[tokenId] + expirePeriod) {
            revert Locked(tokenId, lockTime[tokenId]);
        }
        _;
    }

    modifier onlyAdmin() {
        require(admin == msg.sender, "Sender isnt admin");
        _;
    }

    uint seasonFinalization;
    modifier seasonOpen() {
        require(seasonFinalization == 0, "WR: Season is running");
        _;
    }
    modifier seasonClosed() {
        require(seasonFinalization != 0, "WR: Season has ended");
        _;
    }

    function finalizeSeason() public onlyAdmin {
        seasonFinalization = block.difficulty;
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

    /**
     * @dev Allows a player to claim a win for a race by validating the race data signed by both the opponent and Wilder World.
     *
     * Requirements:
     * - The race must not have been canceled.
     * - The current time must be after the race's start time.
     * - The current time must be after the lock period of the race.
     * - The current time must be before the race's expiry time.
     * - The race data must have been signed by Wilder World and the opponent.
     * - The sender must be the opponent of the race.
     * - The sender must be the same who staked the opponent wheel.
     * - The player of the race must be the one who staked the race wheel.
     * - The race ID must not have been used before.
     *
     * After successful execution:
     * - The race ID is marked as used.
     * - The stakedBy state for the wheel is set to msg.sender.
     * - The wheelId is locked for the lock period.
     * - The staked wheel is transferred from the player to the sender.
     *
     * @param opponentSlip The race data that the opponent signed
     * @param opponentSignature The opponent's signature on the race data
     * @param wilderWorldSignature Wilder World's signature on the race data
     */
    function claimWin(
        RaceSlip memory opponentSlip,
        bytes memory opponentSignature,
        bytes memory wilderWorldSignature
    ) public seasonOpen {
        bytes32 hash = createSlip(opponentSlip);
        require(
            ECDSA.recover(hash, opponentSignature) == opponentSlip.player,
            "WR: Not signed by opponent"
        );
        require(
            ECDSA.recover(hash, wilderWorldSignature) == wilderWorld,
            "WR: Not signed by WW"
        );
        require(
            block.timestamp < opponentSlip.raceStartTimestamp + expirePeriod,
            "WR: Race expired"
        );
        require(
            block.timestamp > opponentSlip.raceStartTimestamp,
            "WR: Race hasnt started"
        );
        require(!canceled[hash], "WR: Slip Canceled");
        require(
            block.timestamp >= lockTime[opponentSlip.wheelId] + expirePeriod,
            "WR: Within lock period"
        );
        require(
            msg.sender == opponentSlip.opponent,
            "WR: Sender isnt opponent"
        );
        require(
            msg.sender == stakedBy[opponentSlip.opponentWheelId],
            "WR: Player wheel unstaked"
        );
        require(
            stakedBy[opponentSlip.wheelId] == opponentSlip.player,
            "WR: Opponent wheel unstaked"
        );
        require(!consumed[opponentSlip.raceId], "WR: RaceId used");

        ///Consume raceID
        consumed[opponentSlip.raceId] = true;
        ///Set state for wheel
        stakedBy[opponentSlip.wheelId] = msg.sender;
        lockTime[opponentSlip.wheelId] = block.timestamp;
        ///Transfer wheel_staked
        _transfer(opponentSlip.player, msg.sender, opponentSlip.wheelId);
    }

    /**
     * @dev Transfers the token back to the stakedBy address.
     *
     * Requirements:
     * - There must be an unstakeRequest
     * - The current time must be after the delay
     *
     * After successful execution:
     * - The stakedBy state is deleted
     * - The unstakeRequest time is deleted
     * - The staked wheel token is burned
     */
    function unstake(
        uint tokenId
    ) public isStakerOrOperator(msg.sender, tokenId) {
        wheels.safeTransferFrom(address(this), msg.sender, tokenId);

        delete stakedBy[tokenId];
        delete unstakeRequests[tokenId];
        _burn(tokenId);
    }

    /**
     * @dev Allows a player to cancel a slip they may have signed, as long as the race has not started yet.
     *
     * Requirements:
     * - `msg.sender` must be the player that created the slip.
     * - The current time must be before the race start time minus the cancel buffer.
     *
     * @param slip The race data that was signed
     */
    function cancel(RaceSlip calldata slip) public {
        require(msg.sender == slip.player, "WR: Sender isnt player");
        require(
            block.timestamp < slip.raceStartTimestamp - cancelBuffer,
            "WR: Cancel period ended"
        );
        bytes32 hash = createSlip(slip);
        canceled[hash] = true;
    }

    /**
     * @dev Checks if a player canceled their slip
     * @param slip The race data
     */
    function isCanceled(RaceSlip calldata slip) public view returns (bool) {
        bytes32 hash = createSlip(slip);
        return canceled[hash];
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
                        raceSlip.opponentWheelId,
                        raceSlip.raceStartTimestamp
                    )
                )
            );
    }

    /**
     * @dev Fails if the transferred token is not a Wilder Wheel NFT
     * @param from The players EOA
     * @param tokenId  The wheel token
     */
    function onERC721Received(
        address,
        address from,
        uint tokenId,
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

    /**
     * @dev Errors if start conditions arent met.
     * This is a helper function for the offchain element of the game.
     * It should be called in the time window between (startTime - cancelBuffer) and startTime.
     * @param p1 Player 1 address
     * @param p1TokenId Player 1 Wheel Token ID
     * @param p2 Player 2 address
     * @param p2TokenId Player 2 Wheel Token ID
     */
    function canRace(
        address p1,
        uint p1TokenId,
        address p2,
        uint p2TokenId
    )
        public
        view
        isStakerOrOperator(p1, p1TokenId)
        isStakerOrOperator(p2, p2TokenId)
        isUnlocked(p1TokenId)
        isUnlocked(p2TokenId)
        returns (bool)
    {
        return true;
    }

    /**
     *
     */
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

    function setExpirePeriod(uint newLock) public onlyAdmin {
        require(newLock != 0, "WR: missing newLock");
        expirePeriod = newLock;
    }

    ///Ability to return NFTs mistakenly sent with transferFrom instead of safeTransferFrom
    function transferOut(address to, uint tokenId) public onlyAdmin {
        require(stakedBy[tokenId] == address(0));
        wheels.safeTransferFrom(address(this), to, tokenId);
    }

    function cancelRace(uint raceId) public onlyAdmin {
        consumed[raceId] = true;
    }

    // Overriding transfer functions
    function transferFrom(address, address, uint) public pure override {
        require(false, "WR: Token is soulbound");
    }

    // Overriding transfer function
    function safeTransferFrom(address, address, uint) public pure override {
        require(false, "WR: Token is soulbound");
    }
}
