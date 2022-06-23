pragma solidity 0.8.14;

import "./interfaces/IERC721.sol";

contract PlayerOwned {
    address player;

    modifier playerOnly(address addy){
        require(addy == player, "Sender isnt player");
        _;
    }
}