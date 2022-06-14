pragma solidity ^0.8.0;

import "./base/Item.sol";
import "./RegistryClient.sol";
import "../interfaces/IRegistry.sol";

contract ItemManager is RegistryClient{
    mapping(bytes32 => bool) public licensed; //keccak256(itemtype, id, licensee) to licensed?
    //Item logic  

    
    /// Has the generator been added to the item yet?
    modifier generated(Item item) {
        require(addressOf(item.generator(), item.currentSeason()) != address(0));
        _;
    }

    constructor(IRegistry registry) RegistryClient(registry) {}
    
    ///does not check erc721 implementation
    function attachItemToNftContract(Item item, address nftContractAddress) public {
        //require("already attached")
        item.attach(nftContractAddress);
        //emit Attached()
    }

    //function attachLicensedItemToNft(LicensedItem item, uint256 itemId, address nftContractAddress, uint256 nftId) external consumeLicense(item.itemType(), itemId) {
    //    item.attach(nftContractAddress, nftId, itemId);
    //    emit Attached(address(item), itemId, nftContractAddress, nftId);
    //}

}