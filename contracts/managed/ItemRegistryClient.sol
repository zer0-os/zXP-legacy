pragma solidity ^0.8.0;

import "./Owned.sol";
import "./Utils.sol";
import "./interfaces/IItemRegistry.sol";

/**
  * @dev Base contract for ContractRegistry clients
*/
contract ItemRegistryClient is Owned, Utils {
    bytes32 internal constant ITEM_REGISTRY = "ItemRegistry";
    bytes32 internal constant ITEM_MANAGER = "ItemManager";
    bytes32 internal constant GAME_MANAGER = "GameManager";        
    bytes32 internal constant ZXP = "Zxp";

    address public itemManager; 
    IItemRegistry public registry;      // address of the contract-registry

    /**
      * @dev verifies that the caller is mapped to the given contract name
      *
      * @param _contractName    contract name
    */
    modifier only(bytes32 _contractName) {
        _only(_contractName);
        _;
    }

    // error message binary size optimization
    function _only(bytes32 _contractName) internal view {
        require(msg.sender == addressOf(_contractName), "ERR_ACCESS_DENIED_regcli");
    }

    /**
      * @dev initializes a new ContractRegistryClient instance
      *
      * @param  _registry   address of a contract-registry contract
    */
    constructor(IItemRegistry _registry) validAddress(address(_registry)) {
        registry = IItemRegistry(_registry);
        prevRegistry = IItemRegistry(_registry);
    }


    /**
      * @dev returns the address associated with the given contract name
      *
      * @param _contractName    contract name
      *
      * @return contract address
    */
    function addressOf(bytes32 _contractName) internal view returns (address) {
        return registry.addressOf(_contractName);
    }
    function addressOfItem(bytes32 _contractName, uint256 season) internal view returns (address) {
        return registry.addressOfItem(_contractName, season);
    }
}
