// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Utils.sol";
import "../interfaces/IRegistry.sol";

/**
  * @dev Base contract for ContractRegistry clients
*/
contract RegistryClient is Utils {
    address public itemManager; 
    IRegistry public registry;      // address of the contract-registry

    uint public season = 1;

    /**
      * @dev verifies that the caller is mapped to the given contract name
      *
      * @param _contractName    contract name
    */
    modifier only(bytes32 _contractName) {
        _only(_contractName, season);
        _;
    }

    // error message binary size optimization
    function _only(bytes32 _contractName, uint _season) internal view {
        require(msg.sender == addressOf(_contractName, _season), "ERR_ACCESS_DENIED_regcli");
    }

    /**
      * @dev initializes a new ContractRegistryClient instance
      *
      * @param  _registry   address of a contract-registry contract
    */
    constructor(IRegistry _registry) validAddress(address(_registry)) {
        registry = IRegistry(_registry);
    }


    /**
      * @dev returns the address associated with the given contract name
      *
      * @param _contractName    contract name
      *
      * @return contract address
    */
    function addressOf(bytes32 _contractName, uint256 _season) internal view returns (address) {
        return registry.addressOf(_contractName, _season);
    }

    function typeOf(bytes32 _contractName) public view returns (uint) {
        return registry.typeOf(_contractName);
    }

    function currentWorldSeason() public view returns(uint){
      return registry.currentSeason();
    }
}
