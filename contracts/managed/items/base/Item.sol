pragma solidity ^0.8.0;

import "../../ContractRegistryClient.sol";
import "./Generated.sol";
import "../../ZXP.sol";

contract Item is Generated, ContractRegistryClient{
    uint256 xp;
    /// @param generator the name of the generator in the contract registry
    constructor(
        bytes32 generator,
        IContractRegistry registry
    )
    Generated(generator) 
    ContractRegistryClient(registry) {}

    function awardXP(uint256 amount) external only(ZXP) {
        xp += amount;
    }
}