pragma solidity ^0.8.0;


import "./items/Item.sol";
import "./Owned.sol";
import "./ContractRegistryClient.sol";
import "./interfaces/IContractRegistry.sol";

contract ItemManager is Owned, ContractRegistryClient{
    mapping(address => uint32) contractSeason;  

    modifier generated(Item item) {
        require(addressOf(item.generator()) != address(0));
        _;
    }

    constructor(IContractRegistry registry) ContractRegistryClient(registry) {}

    function generate() external {}
    
    function attach(Item item) external {}

    function advanceSeason(bytes32 _contractName, address _contractAddress) public
        ownerOnly
        validAddress(_contractAddress)
    {
        super.registerAddress(_contractName, _contractAddress);
        contractSeason[addressOf(_contractName)]++;
    }
}