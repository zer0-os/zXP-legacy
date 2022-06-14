pragma solidity ^0.8.0;

import "../RegistryClient.sol";
import "../../interfaces/IRegistry.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Character is RegistryClient{

    constructor(
        bytes32 itemTypeName,
        IRegistry registry
    )
    RegistryClient(registry) {
    }

}