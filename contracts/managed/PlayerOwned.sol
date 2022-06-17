pragma solidity 0.8.14;

import "./interfaces/IERC721.sol";

contract PlayerOwned {
    address player;

    modifier ownerOnly(address addy){
        require(addy == player, "Sender isnt player");
        _;
    }
}