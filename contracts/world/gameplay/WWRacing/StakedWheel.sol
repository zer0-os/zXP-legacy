pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

contract StakedWheel is ERC721URIStorage, IERC721Receiver {
    error NotStaker(address player, uint256 tokenId, address stakedBy);
    error Unstaking(uint256 tokenId, uint256 unstakeTime);
    error Locked(uint256 tokenId, uint256 lockTime);
    error NotAuthorized(address caller);

    /// Contract address of Wilder Wheels
    IERC721 public wheels;

    /// Admin
    address public admin;

    /// Contract that is allowed to transfer staked tokens
    address controller;

    /// Time that must be waited after an unstakeRequest, must be the same as WheelsRace
    uint256 public expirePeriod = 24 hours;

    /// Mapping from tokenId to holder address
    mapping(uint256 => address) public stakedBy;

    /// Mapping from tokenId to unstake request time
    mapping(uint256 => uint256) public unstakeRequests;

    /// Mapping from wheelId to time locked after transfer
    mapping(uint256 => uint256) public lockTime;

    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        address _admin,
        IERC721 _wheels
    ) ERC721(tokenName, tokenSymbol) {
        admin = _admin;
        wheels = _wheels;
    }

    modifier _isStaked(uint256 tokenId) {
        if (unstakeRequests[tokenId] != 0) {
            revert Unstaking(tokenId, unstakeRequests[tokenId]);
        }
        _;
    }
    modifier _isStakerOrOperator(address stakerOperator, uint256 tokenId) {
        if (!isStakerOrOperator(stakerOperator, tokenId)) {
            revert NotStaker(stakerOperator, tokenId, stakedBy[tokenId]);
        }
        _;
    }

    modifier _isUnlocked(uint256 tokenId) {
        if (!isUnlocked(tokenId)) {
            revert Locked(tokenId, lockTime[tokenId]);
        }
        _;
    }

    modifier onlyAdmin(address a) {
        if (a != admin) {
            revert NotAuthorized(msg.sender);
        }
        _;
    }

    modifier onlyController(address c) {
        if (c != controller) {
            revert NotAuthorized(msg.sender);
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
    ) public _isStakerOrOperator(msg.sender, tokenId) _isUnlocked(tokenId) {
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
    ) public _isStakerOrOperator(msg.sender, tokenId) {
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
    ) public _isStakerOrOperator(msg.sender, tokenId) {
        unstakeRequests[tokenId] = 0;
    }

    function updateController(
        address newController
    ) public onlyAdmin(msg.sender) {
        require(newController != address(0), "WR: no controller given");
        controller = newController;
    }

    function setExpirePeriod(uint256 newLock) public onlyAdmin(msg.sender) {
        require(newLock != 0, "WR: missing newLock");
        expirePeriod = newLock;
    }

    ///Ability to return NFTs mistakenly sent with transferFrom instead of safeTransferFrom
    function transferOut(
        address to,
        uint256 tokenId
    ) public onlyAdmin(msg.sender) {
        require(stakedBy[tokenId] == address(0));
        wheels.safeTransferFrom(address(this), to, tokenId);
    }

    /// Ability to 'undo' a completed race by removing a locked nft
    /// Only works within the lock period that is set on transfer
    function transferLocked(
        address to,
        uint256 tokenId
    ) public onlyAdmin(msg.sender) {
        require(block.timestamp >= lockTime[tokenId], "WR: token not locked");
        require(
            block.timestamp < lockTime[tokenId] + expirePeriod,
            "WR: token unlocked"
        );
        wheels.safeTransferFrom(address(this), to, tokenId);
    }

    /**
     * @dev Fails if the transferred token is not a Wilder Wheel NFT.
     *      On successful receive it stakes the Wheel,
     *      mints the StakedWheel token to the transferer,
     *      and sets the token URI of the StakedWheel to the same as the Wheel.
     *
     *      Operators can transfer in, but the StakedWheel token goes to the token owner.
     * @param from The players EOA
     * @param tokenId  The wheel token
     */
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

        string memory incomingTokenURI = token.tokenURI(tokenId);

        _mint(from, tokenId);
        _setTokenURI(tokenId, incomingTokenURI);

        return this.onERC721Received.selector;
    }

    /// Overriding transfer function, token is soulbound
    function transferFrom(
        address from,
        address to,
        uint256 wheelId
    ) public override onlyController(msg.sender) {
        _transfer(from, to, wheelId);
    }

    /// Overriding transfer function, token is soulbound
    function safeTransferFrom(
        address from,
        address to,
        uint256 wheelId,
        bytes memory data
    ) public override onlyController(msg.sender) {
        _safeTransfer(from, to, wheelId, data);
    }

    function _transfer(
        address from,
        address to,
        uint256 id
    ) internal virtual override {
        stakedBy[id] = to;
        lockTime[id] = block.timestamp;
        super._transfer(from, to, id);
    }

    function isStakerOrOperator(
        address stakerOperator,
        uint256 tokenId
    ) public view returns (bool) {
        if (
            stakedBy[tokenId] != stakerOperator &&
            wheels.getApproved(tokenId) != stakerOperator
        ) {
            return false;
        }
        return true;
    }

    function isUnlocked(uint256 tokenId) public view returns (bool) {
        if (block.timestamp <= lockTime[tokenId] + expirePeriod) {
            return false;
        }
        return true;
    }
}
