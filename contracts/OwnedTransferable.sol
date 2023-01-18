// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./interfaces/IOwned.sol";

/**
  * @dev Provides support and utilities for contract ownership
*/
contract Owned is IOwned {
    address public override owner;
    address public newOwner;

    /**
      * @dev initializes a new Owned instance
    */
    constructor() {
        owner = msg.sender;
    }

    // allows execution by the owner only
    modifier ownerOnly {
        _ownerOnly();
        _;
    }

    // error message binary size optimization
    function _ownerOnly() internal view {
        require(msg.sender == owner, "ERR_ACCESS_DENIED_owned");
    }

    /**
      * allows transferring the contract ownership
      * the new owner still needs to accept the transfer
      * can only be called by the contract owner
      *
      * @param _newOwner    new contract owner
    */
    function transferOwnership(address _newOwner) public ownerOnly {
        require(_newOwner != owner, "ERR_SAME_OWNER");
        newOwner = _newOwner;
    }

    /**
      * @dev used by a new owner to accept an ownership transfer
    */
    function acceptOwnership() public {
        require(msg.sender == newOwner, "ERR_ACCESS_DENIED_newowner");
        emit OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }

    /** 
      * @dev transfers without requiring acceptance
    */
    function unsafeTransfer(address _newOwner) public {
      require(_newOwner != owner, "ERR_SAME_OWNER");
      owner = _newOwner;
    }

    event OwnerUpdate(address owner, address newOwner);
}
