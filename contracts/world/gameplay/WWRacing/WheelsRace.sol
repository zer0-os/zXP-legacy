// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./StakedWheel.sol";

contract WheelsRace is EIP712 {
    error NotAdmin(address sender);
    /// The EIP-712 type definitions
    struct RaceSlip {
        address player;
        address opponent;
        uint256 raceId;
        uint256 wheelId;
        uint256 opponentWheelId;
        uint256 raceStartTimestamp;
    }

    /// The EIP-712 domain separators
    bytes32 private constant RACE_SLIP_TYPEHASH =
        keccak256(
            "RaceSlip(address player,address opponent,uint256 raceId,uint256 wheelId,uint256 opponentWheelId,uint256 raceStartTimestamp)"
        );

    /// Wallet address of wilder world used to sign losing opponents race slip
    address public wilderWorld;

    StakedWheel stakedWheels;

    /// Admin
    address public admin;

    /// Length of time before races expire after their startTimestamp
    /// Also controls unstake delay period, making the races secure by disallowing unstaking during a race, as long as canRace is checked before.
    uint256 public expirePeriod = 24 hours;

    ///RaceIds that have been used
    mapping(uint256 => bool) private consumed;

    /// Mapping from slip hash to canceled status
    mapping(bytes32 => bool) private canceled;
    uint256 private cancelBuffer;

    modifier onlyAdmin() {
        if (msg.sender != admin) {
            revert NotAdmin(msg.sender);
        }
        _;
    }

    constructor(
        string memory name,
        string memory version,
        address _admin,
        address _wilderWorld,
        StakedWheel _stakedWheels
    ) EIP712(name, version) {
        stakedWheels = _stakedWheels;
        admin = _admin;
        wilderWorld = _stakedWheels.wilderWorld();
        expirePeriod = _stakedWheels.expirePeriod();
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
    ) public {
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
            block.timestamp >=
                stakedWheels.lockTime(opponentSlip.wheelId) + expirePeriod,
            "WR: Within lock period"
        );
        require(
            msg.sender == opponentSlip.opponent,
            "WR: Sender isnt opponentSlip.opponent"
        );
        require(
            msg.sender == stakedWheels.stakedBy(opponentSlip.opponentWheelId),
            "WR: Player wheel unstaked"
        );
        require(
            stakedWheels.stakedBy(opponentSlip.wheelId) == opponentSlip.player,
            "WR: Opponent wheel unstaked"
        );
        require(!consumed[opponentSlip.raceId], "WR: RaceId used");

        ///Consume raceID
        consumed[opponentSlip.raceId] = true;
        ///Set state for wheel
        stakedWheels.stakedBy(opponentSlip.wheelId) = msg.sender;
        stakedWheels.lockTime(opponentSlip.wheelId) = block.timestamp;
        ///Transfer wheel_staked
        stakedWheels._transfer(
            opponentSlip.player,
            msg.sender,
            opponentSlip.wheelId
        );
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
     * @dev Errors if start conditions arent met.
     * This is a helper function for the offchain element.
     * It should be called in the time window between (startTime - cancelBuffer) and startTime.
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
    ) public view returns (bool) {
        return
            stakedWheels.isStakerOrOperator(p1, p1TokenId) &&
            stakedWheels.isStakerOrOperator(p2, p2TokenId) &&
            stakedWheels.isUnlocked(p1TokenId) &&
            stakedWheels.isUnlocked(p2TokenId);
    }

    function _recoverSigner(
        bytes32 hash,
        bytes calldata signature
    ) private pure returns (address) {
        return ECDSA.recover(hash, signature);
    }

    function cancelRace(uint256 raceId) public onlyAdmin {
        consumed[raceId] = true;
    }

    function unCancelRace(uint256 raceId) public onlyAdmin {
        consumed[raceId] = false;
    }
}
