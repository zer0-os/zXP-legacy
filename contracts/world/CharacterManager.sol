// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//import "./base/Character.sol";
import "./RegistryClient.sol";
import "./base/NFTStaker.sol";

contract CharacterManager is RegistryClient, NFTStaker{
    uint cost;
    mapping(address => mapping(bytes32 => uint)) public characterSeason;
    mapping(bytes32 => address) equipped;

    constructor(IRegistry registry) RegistryClient(registry) {}

    ///Creates character by setting season to 1
    function create(bytes32 name) public payable {
        require(msg.value == cost, "Invalid payment");
        characterSeason[msg.sender][name] = 1;
    }

    function _equip(bytes32 tokenHash) internal {
        equipped[tokenHash] = msg.sender;
        //increase character stats
    }

    function _unequip(bytes32 name, bytes32 tokenHash) public {
        require(equipped[tokenHash] == msg.sender);
        //decrease character stats
        //advance season & award xp
        advance(name);
    }

    function advance(bytes32 name) public {
        characterSeason[msg.sender][name] = currentWorldSeason();
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public override returns(bytes4){
        data;
        _stake(operator, from, tokenId);
        _equip(keccak256(abi.encode(from, tokenId)));
        return IERC721Receiver.onERC721Received.selector;
    }
}