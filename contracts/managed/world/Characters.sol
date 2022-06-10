pragma solidity ^0.8.0;

import "./RegistryClient.sol";

contract Characters is RegistryClient{
    uint cost;
    mapping(address => uint256) season; 

    constructor(IRegistry registry) RegistryClient(registry) {}

    ///Creates character by setting season to 1
    /*function create() public {
        require(msg.value == cost, "Invalid payment");
        require(season[msg.sender] == 0, "Character already created");
        season[msg.sender] = 1;
        addressOf("Zxp").call{value: msg.value}(bytes4(sha3("seasonLock()")));
    }

    function advance() public {
        season[msg.sender]++;
        addressOf("Zxp").call(bytes4(sha3("seasonAdvance()")));
    }*/
}