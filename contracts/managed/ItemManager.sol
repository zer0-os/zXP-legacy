pragma solidity ^0.8.0;

import "./items/base/Item.sol";
import "./Owned.sol";
import "./ItemRegistryClient.sol";
import "./interfaces/IItemRegistry.sol";

contract ItemManager is Owned, ItemRegistryClient{
    mapping(bytes32 => bool) public licensed; //keccak256(itemtype, id, licensee) to licensed?
    //Item logic  
    modifier onlyNftOwner(Item item, uint256 itemId){
        require(msg.sender == ERC721(item.itemToNftContract(itemId)).ownerOf(item.itemToNftId(itemId)));
        _;
    }
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

    constructor(IItemRegistry registry) ItemRegistryClient(registry) {}
    
    function attach(Item item, uint256 itemId, address nftContractAddress, uint256 nftId) external {//onlyNftOwner(item, itemId) consumeLicense(item.itemType(), itemId) {
        item.attach(nftContractAddress, nftId, itemId);
        emit Attached(address(item), itemId, nftContractAddress, nftId);
    }

    function adminAttach(Item item, uint256 itemId, address nftContractAddress, uint256 nftId) external ownerOnly() {
        item.attach(nftContractAddress, nftId, itemId);
        emit Attached(address(item), itemId, nftContractAddress, nftId);
    }

    /// @param typeIdAddressHash the keccak256(abi.encode(itemType, id, licensee)) hash of the items type, its id, and the address of the licensee
    ///todo this is max efficiency, but we should assess if there's a non-unique hash problem with this, if so pass in the params and hash it in issue(), or break it up into nested mappings 
    function issueLicense(bytes32 typeIdAddressHash) external ownerOnly {
        licensed[typeIdAddressHash] = true;
        emit Licensed(typeIdAddressHash);
    }
    event Licensed(bytes32 typeIdAddressHash);
    event Attached(address indexed, uint256, address, uint256);
}