pragma solidity ^0.8.0;

import "./items/base/Item.sol";
import "./Owned.sol";
import "./ContractRegistryClient.sol";
import "./interfaces/IContractRegistry.sol";
import "./Licenser.sol";

contract ItemManager is Owned, Licenser, ContractRegistryClient{
    //Item logic  
    modifier onlyNftOwner(Item item, uint256 itemId){
        require(msg.sender == ERC721(item.itemToNftContract(itemId)).ownerOf(item.itemToNftId(itemId)));
        _;
    }
    modifier consumeLicense(bytes32 itemType, uint256 itemId){
        licensee[itemType][itemId] = address(0);
        _;
    }
    
    /// Has the generator been added to the item yet?
    modifier generated(Item item) {
        require(addressOf(item.generator()) != address(0));
        _;
    }

    constructor(IContractRegistry registry) ContractRegistryClient(registry) {}
    
    function attach(Item item, uint256 itemId, address nftContractAddress, uint256 nftId, uint256 wheelId) external onlyNftOwner(item, itemId) consumeLicense(item.itemType, itemId) {
        item.attach(nftContractAddress, nftId, wheelId);
    }
    
    function adminAttach(Item item, address nftContractAddress, uint256 nftId, uint256 wheelId) external ownerOnly() {
        item.attach(nftContractAddress, nftId, wheelId);
    }
}