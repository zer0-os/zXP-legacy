pragma solidity ^0.8.4;
import "./Owned.sol";
contract Licenser{
    /*
    mapping(bytes32 => bool) public licensed; //keccak256(itemtype, id, licensee) to licensed?
    ///on consumption, the license hash submitted by the admin in issue must match the hashed item data requested by user
    modifier consumeLicense(bytes32 itemType, uint256 itemId){
        require(licensed[keccak256(abi.encode(itemType, itemId, msg.sender))] == true, "Unlicensed");
        licensed[keccak256(abi.encode(itemType, itemId, msg.sender))] = false;
        _;
    }
    ///todo merkle root setup
    mapping(bytes32 => bool) licensed; //keccak256(itemtype, id, licensee) to licensed?
    //mapping(bytes32 => mapping(uint256 => address)) public licensee; //itemType to id to licensee
    /// @param typeIdAddressHash the keccak256(abi.encode(itemType, id, licensee)) hash of the items type, its id, and the address of the licensee
        ///todo this is max efficiency, but we should assess if there's a non-unique hash problem with this, if so pass in the params and hash it in issue(), or break it up into nested mappings 
    function issue(bytes32 typeIdAddressHash) internal {
        licensed[typeIdAddressHash] = true;
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
    //function issueTournamentLicense() internal {}
    */
}