// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

contract PlayerOwned {
    mapping(address => uint) player;

    modifier playerOnly(address _player){
        require(player[_player] != 0, "Address isnt player");
        _; 
    }


}