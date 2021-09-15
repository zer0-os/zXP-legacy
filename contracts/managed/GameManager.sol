pragma solidity ^0.8.0;

import "./ZXP.sol";
import "./ContractRegistry.sol";
import "./Owned.sol";

//Sorts game objects by season
//Awards xp
contract GameManager is Owned{
    ZXP zxp;
    address admin;
    
    mapping(address => uint32) contractSeason;  

    constructor(ZXP _zxp){
        zxp = _zxp;
    }
    
    function advanceSeason(bytes32 _contractName, address _contractAddress) public
        ownerOnly
        validAddress(_contractAddress)
    {
        super.registerAddress(_contractName, _contractAddress);
        contractSeason[addressOf(_contractName)]++;
    }
}