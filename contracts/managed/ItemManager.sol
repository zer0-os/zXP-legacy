pragma solidity ^0.8.0;


import "./items/Item.sol";
import "./Owned.sol";
import "./ContractRegistryClient.sol";
import "./interfaces/IContractRegistry.sol";

contract ItemManager is Owned, ContractRegistryClient{
    modifier generated(Item item) {
        require(addressOf(item.generator()) != address(0));
        _;
    }

    constructor(IContractRegistry registry) ContractRegistryClient(registry) {}

    function generate() external view returns(bool){}
    function attach(Item item) external {}
}