pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

contract StakedWheel is ERC721URIStorage, IERC721Receiver {
    error NotStaker(address player, uint256 tokenId, address stakedBy);
    error Unstaking(uint256 tokenId, uint256 unstakeTime);
    error Locked(uint256 tokenId, uint256 lockTime);
    error NotAdmin(address sender);

    /// Contract address of Wilder Wheels
    IERC721 public wheels;

    /// Admin
    address public admin;

    /// Wheel Stake manager
    address public wheelStaker;

    /// Time that must be waited after an unstakeRequest
    uint256 private expirePeriod;

    /// Mapping from tokenId to holder address
    mapping(uint256 => address) public stakedBy;

    /// Mapping from tokenId to unstake request time
    mapping(uint256 => uint256) private unstakeRequests;

    /// Mapping from wheelId to time locked after win claim
    mapping(uint256 => uint256) lockTime;

    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        IERC721 _wheels,
        uint256 _expirePeriod
    ) ERC721(tokenName, tokenSymbol) {
        wheels = _wheels;
        admin = msg.sender;
        expirePeriod = _expirePeriod;
    }

    modifier isStakerOrOperator(address stakerOperator, uint256 tokenId) {
        if (
            stakedBy[tokenId] != stakerOperator &&
            wheels.getApproved(tokenId) != stakerOperator
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

    /**
     * @dev Allows a player to remove a staked token in two steps.
     * The player must wait for a delay period as long as the race expiration.
     *
     * Requirements:
     * - The wheel token must not be currently locked.
     *
     * @param tokenId The wheel token
     */
    function requestUnstake(
        uint256 tokenId
    ) public isStakerOrOperator(msg.sender, tokenId) isUnlocked(tokenId) {
        unstakeRequests[tokenId] = block.timestamp;
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
    function performUnstake(
        uint256 tokenId
    ) public isStakerOrOperator(msg.sender, tokenId) {
        require(unstakeRequests[tokenId] != 0, "No unstake request");
        require(
            block.timestamp >= unstakeRequests[tokenId] + expirePeriod,
            "WR: Unstake delayed"
        );

        wheels.safeTransferFrom(address(this), msg.sender, tokenId);

        delete stakedBy[tokenId];
        delete unstakeRequests[tokenId];
        _burn(tokenId);
    }

    function cancelUnstake(
        uint256 tokenId
    ) public isStakerOrOperator(msg.sender, tokenId) {
        unstakeRequests[tokenId] = 0;
    }

    // Overriding transfer functions
    function transferFrom(address, address, uint256) public pure override {
        require(false, "WR: Token is soulbound");
    }

    // Overriding transfer function
    function safeTransferFrom(address, address, uint256) public pure override {
        require(false, "WR: Token is soulbound");
    }
}
