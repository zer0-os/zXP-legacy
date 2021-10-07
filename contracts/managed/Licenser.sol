pragma solidity ^0.8.4;

contract Licenser{
    ///todo merkle root setup
    
    mapping(bytes32 => mapping(uint256 => address)) public licensee; //itemType to id to licensee
    function issue(address _licensee, bytes32 itemType, uint256 id) internal {
        licensee[itemType][id] = _licensee;
    }
    //function issueTournamentLicense() internal {}
}