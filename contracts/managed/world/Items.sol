pragma solidity ^0.8.0;

import "./items/base/Item.sol";
import "./RegistryClient.sol";
import "../interfaces/IRegistry.sol";

contract Items is RegistryClient{
    mapping(bytes32 => bool) public licensed; //keccak256(itemtype, id, licensee) to licensed?
    //Item logic  
    ///on consumption, the license hash submitted by the admin in issue must match the hashed item data requested by user
    modifier consumeLicense(bytes32 itemType, uint256 itemId){
        require(licensed[keccak256(abi.encode(itemType, itemId, msg.sender))] == true, "Unlicensed");
        licensed[keccak256(abi.encode(itemType, itemId, msg.sender))] = false;
        _;
    }
    
    /// Has the generator been added to the item yet?
    modifier generated(Item item) {
        require(addressOfItem(item.generator(), item.currentSeason()) != address(0));
        _;
    }

    constructor(IRegistry registry) RegistryClient(registry) {}
    
    function attachItemToNftContract(Item item, address nftContractAddress) public {
        item.attach(nftContractAddress);
        //emit Attached()
    }

    //function attachLicensedItemToNft(LicensedItem item, uint256 itemId, address nftContractAddress, uint256 nftId) external consumeLicense(item.itemType(), itemId) {
    //    item.attach(nftContractAddress, nftId, itemId);
    //    emit Attached(address(item), itemId, nftContractAddress, nftId);
    //}

}