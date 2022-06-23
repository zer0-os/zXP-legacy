pragma solidity ^0.8.0;

import "../RegistryClient.sol";
import "../../interfaces/IRegistry.sol";
import "../../PlayerOwned.sol";
import "./XpRecipient.sol";

contract Character is PlayerOwned, RegistryClient, XpRecipient{
    
    mapping(address => uint) character;
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

    function create(string memory name) public payable {
        require(msg.value == cost, "Invalid payment");
        character[msg.sender] = uint(keccak256(abi.encode(msg.sender, name)));
    }

    function advance() public {
    }

}