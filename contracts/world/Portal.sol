// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./base/Character.sol";
import "./base/Item.sol";

contract Portal{
    mapping(address => bool) entered;
    mapping(address => bool) exited;

    modifier contained(){
        require(entered[msg.sender] && !exited[msg.sender], "ZXP: Out of this world");
        _;
    }

    function enter() public{
        require(!entered[msg.sender], "Player already entered");
        entered[msg.sender] = true;
        //createCharacter();
    }

    function exit() public{
        //suspendCharacter();
        exited[msg.sender] = true;
    }

    function reenter() public{
        //unsuspendCharacter();
        exited[msg.sender] = true; 
    }
}