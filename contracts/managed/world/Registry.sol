// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "../Owned.sol";
import "../Utils.sol";
import "../interfaces/IRegistry.sol";
import "./base/Item.sol";

/**
  * @dev Contract Registry
  *
  * The contract registry keeps contract addresses by name.
  * The owner can update contract addresses so that a contract name always points to the latest version
  * of the given contract.
  * Other contracts can query the registry to get updated addresses instead of depending on specific
  * addresses.
  *
  * Note that contract names are limited to 32 bytes UTF8 encoded ASCII strings to optimize gas costs
*/
contract Registry is IRegistry, Owned, Utils {
    struct RegistryObject {
        address contractAddress;    
        uint256 nameIndex;          // index in contractNames     
    }

    uint public currentSeason;
    mapping (bytes32 => mapping(uint256 => RegistryObject)) private objects;    // name to season to registry object
    string[] public contractNames;                      // list of all registered contract names

    /**
      * @dev returns the number of objects in the registry
      *
      * @return number of objects
    */
    function objectCount() public view override returns (uint256) {
        return contractNames.length;
    }

    /**
      * @dev returns the address associated with the given contract name
      *
      * @param _contractName    contract name
      *
      * @return contract address
    */
    function addressOf(bytes32 _contractName, uint256 season) public view override returns (address) {
        return objects[_contractName][season].contractAddress;
    }
    /**
      * @dev registers a new address for the contract name in the registry
      *
      * @param _contractName     contract name
      * @param _contractAddress  contract address
    */
    function registerAddress(bytes32 _contractName, address _contractAddress)
        public
        ownerOnly
        validAddress(_contractAddress)
    {
        //Prevent overwrite
        require(addressOf(_contractName, 0) == address(0), "ERR_NAME_TAKEN");
        // validate input
        require(_contractName.length > 0, "ERR_INVALID_NAME");

        // check if any change is needed
        // season 0
        address currentAddress = objects[_contractName][0].contractAddress; 
        if (_contractAddress == currentAddress)
            return;

        if (currentAddress == address(0)) {
            // update the item's index in the list
            objects[_contractName][0].nameIndex = contractNames.length;

            // add the contract name to the name list
            contractNames.push(bytes32ToString(_contractName));
        }

        // update the address in the registry
        objects[_contractName][0].contractAddress = _contractAddress;
    }

    ///Index 0 should always be the base Item contract first deployed and registered, and then advanceSeason adds generators at the following season indices
    ///This automatically persists the basic data on the Item contract, and allows new stats/functionality to be deployed each season.

    function advanceSeason(bytes32 _contractName, address _newContractAddress, uint256 xpAward)
        public
        override
        ownerOnly
        validAddress(_newContractAddress)
    {
        // validate input
        require(_contractName.length > 0, "ERR_INVALID_NAME");
        // validate contract name is registered
        require(objects[_contractName][0].contractAddress != address(0), "ERR_UNREGISTERED_NAME");
        
        //Increment season on item
        Item item = Item(addressOf(_contractName, currentSeason));
        item.incrementSeason();
        item.awardXP(xpAward);
        //associate new address with new season
        objects[_contractName][currentSeason + 1].contractAddress = _newContractAddress;
    }

    /**
      * @dev utility, converts bytes32 to a string
      * note that the bytes32 argument is assumed to be UTF8 encoded ASCII string
      *
      * @return string representation of the given bytes32 argument
    */
    function bytes32ToString(bytes32 _bytes) private pure returns (string memory) {
        bytes memory byteArray = new bytes(32);
        for (uint256 i = 0; i < 32; i++) {
            byteArray[i] = _bytes[i];
        }

        return string(byteArray);
    }

    /**
      * @dev utility, converts string to bytes32
      * note that the bytes32 argument is assumed to be UTF8 encoded ASCII string
      *
      * @return string representation of the given bytes32 argument
    */
    function stringToBytes32(string memory _string) private pure returns (bytes32) {
        bytes32 result;
        assembly {
            result := mload(add(_string,32))
        }
        return result;
    }
}
