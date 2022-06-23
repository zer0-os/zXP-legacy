pragma solidity ^0.8.0;

import "./base/Character.sol";
import "./RegistryClient.sol";

contract CharacterManager is RegistryClient{
    uint cost;

    mapping(address => uint) character;
    mapping(address => string) name;

    constructor(IRegistry registry) RegistryClient(registry) {}

    function create(string memory name) public payable {
        require(msg.value == cost, "Invalid payment");
        character[msg.sender] = uint(keccak256(abi.encode(msg.sender, name)));

    }

    function advance() public { 

    }
}