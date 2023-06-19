// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Owned.sol";
import "../Utils.sol";
import "../interfaces/IRegistry.sol";

contract Registry is IRegistry, Owned, Utils {
    
    enum ObjectType{MANAGER, CHAR, ITEM, GAME}

    struct RegistryObject {
        mapping(uint => address) contractAddress;    
        uint seasonZero;
        ObjectType objectType;
    }

    uint public currentSeason = 1;
    mapping (bytes32 => RegistryObject) private objects;    // name to season to registry object
    //string[] public contractNames;                      // list of all registered contract names
    mapping(address => bytes32) public name;
    //function objectCount() public view override returns (uint256) {
    //    return contractNames.length;
    //}
    function addressOf(bytes32 _contractName, uint256 season) public view override returns (address) {
        return objects[_contractName].contractAddress[season];
    }
    
    function seasonZeroOf(bytes32 _contractName) public view override returns (uint){
        return objects[_contractName].seasonZero;
    }

    function typeOf(bytes32 _contractName) public view returns (uint) {
        return uint(objects[_contractName].objectType);
    }

    ///contract names are limited to 32 bytes UTF8 encoded ASCII strings to optimize gas costs
    function registerAddress(bytes32 _contractName, address _contractAddress, ObjectType objectType)
        public
        ownerOnly
        validAddress(_contractAddress)
    {
        // validate input
        require(_contractName.length > 0, "ERR_INVALID_NAME");
        //Prevent overwrite
        //require(addressOf(_contractName, currentSeason + 1) == address(0), "ERR_NAME_TAKEN");

        if (seasonZeroOf(_contractName) == 0){
            objects[_contractName].seasonZero = currentSeason;
            objects[_contractName].objectType = objectType;
        }

        // update the address in the registry
        objects[_contractName].contractAddress[currentSeason] = _contractAddress;
        name[_contractAddress] = _contractName;
    }
    
    /// @dev Deploys a new season of a registered contract
    function advanceSeason(bytes32 _contractName, address _newContractAddress)
        public
        ownerOnly
        validAddress(_newContractAddress)
    {
        // validate input
        require(_contractName.length > 0, "ERR_INVALID_NAME");
        // validate contract name is registered
        require(objects[_contractName].seasonZero != 0, "ERR_UNREGISTERED_NAME");
        
        // update the address in the registry
        objects[_contractName].contractAddress[currentSeason + 1] = _newContractAddress;
        name[_newContractAddress] = _contractName;
    }

    function newSeason() public ownerOnly{
        currentSeason++;
    }

    //function startSeason() public ownerOnly {
    //    started[season] = true;
    //} 

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
