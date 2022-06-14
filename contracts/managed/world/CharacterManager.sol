pragma solidity ^0.8.0;

import "./base/Character.sol";
import "./RegistryClient.sol";

contract CharacterManager is RegistryClient{
    uint cost;

    constructor(IRegistry registry) RegistryClient(registry) {}

    ///Creates character by setting season to 1
    function create() public payable {
        require(msg.value == cost, "Invalid payment");
        //require(season[msg.sender] == 0, "Character already created");
        //season[msg.sender] = 1;
        //addressOf("Zxp").call{value: msg.value}(bytes4(sha3("seasonLock()")));
    }

    function advance() public {
        //season[msg.sender]++;
        //addressOf("Zxp").call(bytes4(sha3("seasonAdvance()")));
    }
}