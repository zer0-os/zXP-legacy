pragma solidity ^0.8.0;

contract ZXP{
    mapping(address => uint256) public userXP;
    mapping(uint256 => uint256) public itemXP;

    function awardUserXP(address awardee, uint256 amount) internal {
        userXP[awardee] += amount;
    }
    
    function awardItemXP(uint256 awardee, uint256 amount) internal {
        itemXP[awardee] += amount;
    }
}