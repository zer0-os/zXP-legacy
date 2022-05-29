pragma solidity 0.8.13;

contract Characters is ItemRegistryClient{
    uint cost;
    mapping(address => uint256) season; 

    ///Creates character by setting season to 1
    function create(){
        require(msg.value == cost, "Invalid payment");
        require(season[msg.sender] == 0, "Character already created")
        season[msg.sender] = 1;
        addressOf("Zxp").call{value: msg.value}(bytes4(sha3("seasonLock()")));
    }

    function advance(){
        season[msg.sender]++;
        addressOf("Zxp").call(bytes4(sha3("seasonAdvance()")));
    }
}