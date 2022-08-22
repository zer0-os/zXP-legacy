// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./base/Character.sol";
import "./base/Item.sol";
import "./World.sol";
import "../interfaces/IPortal.sol";

contract Portal is IPortal{
    mapping(address => address) link;
    
    modifier contained(){
        require(entered[msg.sender] && !exited[msg.sender], "ZXP: Out of this world");
        _;
    }

    function enter() public{
        require(!entered[msg.sender], "ZXP: Player already entered");
        entered[msg.sender] = true;
        //createCharacter();
    }

    function exit() public{
        //suspendCharacter();
        exited[msg.sender] = true;
    }

    function reenter() public{
        //unsuspendCharacter();
        entered[msg.sender] = true; 
    }

    function createLink() public{

    }
}