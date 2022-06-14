pragma solidity ^0.8.14;

import "../RegistryClient.sol";

contract Items is RegistryClient{
     constructor(IRegistry registry) RegistryClient(registry) {}
}