// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./interfaces/IOwned.sol";

/**
  * @dev Provides support and utilities for contract ownership
*/
contract Officiated{
    address public official;
    uint startTime;
    uint roundLength;
    uint roundXpAward = 100;

    /**
      * @dev triggered when the owner is updated
      *
      * @param _prevOwner previous owner
      * @param _newOwner  new owner
    */
    event OwnerUpdate(address indexed _prevOwner, address indexed _newOwner);

    /**
      * @dev initializes a new Owned instance
    */
    constructor(address tournamentOfficial, uint roundLength) {
        official = tournamentOfficial;
        startTime = block.timestamp;
    }

    // allows execution by the official only
    modifier officialOnly {
        _officialOnly();
        _;
    }

    function _officialOnly() internal view {
        require(msg.sender == official, "ZXP sender isnt official");
    }

    /**
      * @dev ZXP: transferring disabled 
      * allows transferring the contract ownership
      * the new owner still needs to accept the transfer
      * can only be called by the contract owner
      *
      * @param _newOwner    new contract owner
    */
    //function transferOwnership(address _newOwner) public override ownerOnly {
    //    require(_newOwner != owner, "ERR_SAME_OWNER");
    //    newOwner = _newOwner;
    //}

    /**
      * @dev used by a new owner to accept an ownership transfer
    */
    //function acceptOwnership() override public {
    //    require(msg.sender == newOwner, "ERR_ACCESS_DENIED_newowner");
    //    emit OwnerUpdate(owner, newOwner);
    //    owner = newOwner;
    //    newOwner = address(0);
    //}
}
