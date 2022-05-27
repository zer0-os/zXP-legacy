pragma solidity 0.8.13;

contract Characters is ItemRegistryClient{
    mapping(address => uint256) season; 
    uint cost;

    function create(){
        require(msg.value == cost, "Invalid payment");
        addressOf("Zxp").call{value: msg.value}(bytes4(sha3("seasonLock()")));
    }

    function advance(){
        season[msg.sender]++;
    }
}