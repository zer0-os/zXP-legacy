pragma solidity ^0.8.0;

import "../../ContractRegistryClient.sol";
import "./Generated.sol";
import "../../ZXP.sol";

contract Item is ZXP, Generated, ContractRegistryClient{
    constructor(
        bytes32 generator,
        IContractRegistry registry
    )
    Generated(generator) 
    ContractRegistryClient(registry)
    {
    }
}