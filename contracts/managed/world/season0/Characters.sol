pragma solidity ^0.8.14;

import "../RegistryClient.sol";

contract Characters is RegistryClient{
     constructor(IRegistry registry) RegistryClient(registry) {}
}