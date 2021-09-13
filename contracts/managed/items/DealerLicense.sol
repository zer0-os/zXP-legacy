pragma solidity ^0.8.0;

import "./Item.sol";

contract DealerLicense is Item {
    constructor(bytes32 _generator) Item(_generator) {}
}