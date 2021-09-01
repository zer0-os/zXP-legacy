pragma solidity ^0.8.0;

import "./ZXP.sol";
import "../utility/Owned.sol";

//Sorts game objects by season
//Awards xp
contract GameManager is Owned{
    ZXP zxp;
    address admin;
    constructor(ZXP _zxp){
        zxp = _zxp;
    }
    
}