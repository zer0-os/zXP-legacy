// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./base/Character.sol";
import "./base/Item.sol";
import "./World.sol";
import "../interfaces/IPortal.sol";

contract Portal is IPortal{
    mapping(address => address) link;

    function createLink(address from, address to) public{
        link[from] = to;
    }
}