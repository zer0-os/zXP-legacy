pragma solidity ^0.8.0;

import "../RegistryClient.sol";
import "../../interfaces/IRegistry.sol";
import "../../PlayerOwned.sol";

contract Character is PlayerOwned, RegistryClient{
    
    uint cost;
    
    struct Equips{
        uint pal;
        uint beast;
        uint wheel;
    }
    Equips internal equipment;

    constructor(
        IRegistry registry
    )
    RegistryClient(registry) {
    }

    function equipWheel(uint id) public ownerOnly(msg.sender){
        //require("sender doesnt own wheel id");
        equipment.wheel = id;
    }

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