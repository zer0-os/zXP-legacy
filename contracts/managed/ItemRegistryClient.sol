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
    IItemRegistry public registry;      // address of the current contract-registry
    IItemRegistry public prevRegistry;  // address of the previous contract-registry
    bool public onlyOwnerCanUpdateRegistry; // only an owner can update the contract-registry

    /**
      * @dev verifies that the caller is mapped to the given contract name
      *
      * @param _contractName    contract name
    */
    modifier only(bytes32 _contractName, uint256 _season) {
        _only(_contractName, _season);
        _;
    }

    // error message binary size optimization
    function _only(bytes32 _contractName, uint256 _season) internal view {
        require(msg.sender == addressOf(_contractName, _season), "ERR_ACCESS_DENIED_regcli");
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
      * @dev updates to the new contract-registry
     */
    function updateRegistry() public {
        // verify that this function is permitted
        require(msg.sender == owner || !onlyOwnerCanUpdateRegistry, "ERR_ACCESS_DENIED_regup");

        // get the new contract-registry
        IItemRegistry newRegistry = IItemRegistry(addressOf(ITEM_REGISTRY, 0));

        // verify that the new contract-registry is different and not zero
        require(newRegistry != registry && address(newRegistry) != address(0), "ERR_INVALID_REGISTRY");

        // verify that the new contract-registry is pointing to a non-zero contract-registry
        require(newRegistry.addressOf(ITEM_REGISTRY, 0) != address(0), "ERR_INVALID_REGISTRY");

        // save a backup of the current contract-registry before replacing it
        prevRegistry = registry;

        // replace the current contract-registry with the new contract-registry
        registry = newRegistry;
    }

    /**
      * @dev restores the previous contract-registry
    */
    function restoreRegistry() public ownerOnly {
        // restore the previous contract-registry
        registry = prevRegistry;
    }

    /**
      * @dev restricts the permission to update the contract-registry
      *
      * @param _onlyOwnerCanUpdateRegistry  indicates whether or not permission is restricted to owner only
    */
    function restrictRegistryUpdate(bool _onlyOwnerCanUpdateRegistry) public ownerOnly {
        // change the permission to update the contract-registry
        onlyOwnerCanUpdateRegistry = _onlyOwnerCanUpdateRegistry;
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
}
