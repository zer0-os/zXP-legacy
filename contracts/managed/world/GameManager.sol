pragma solidity ^0.8.0;

import "./base/Game.sol";
import "./RegistryClient.sol";

//Sorts game objects by season
//Awards xp
contract GameManager is RegistryClient{

    //Game logic
     constructor(IRegistry registry) RegistryClient(registry) {}
}