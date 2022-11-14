// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//import "./base/Character.sol";
import "./RegistryClient.sol";
import "./base/NFTStaker.sol";

contract CharacterManager is RegistryClient, NFTStaker{
    uint cost;

    mapping(bytes32 => address) characterCreator;
    mapping(bytes32 => address) characterPlayer;
    mapping(address => mapping(bytes32 => uint)) public characterSeason;
    mapping(bytes32 => uint) royalty;
    mapping(bytes32 => address) equipped;

    constructor(IRegistry registry) RegistryClient(registry) {}

    ///Creates character by setting season to 1
    ///@param name Names can be up to 32 characters, names are owned by addresses and transferable
    function create(bytes32 name, uint _royalty) public payable {
        require(msg.value == cost, "Invalid payment");
        characterCreator[name] = msg.sender;
        characterPlayer[name] = msg.sender;
        characterSeason[msg.sender][name] = currentWorldSeason();
        royalty[name] = _royalty;
    }

    function sell() public {}
    function buy() public {}
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

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory) public override returns(bytes4){
        _stake(operator, from, tokenId);
        _equip(keccak256(abi.encode(from, tokenId)));
        return IERC721Receiver.onERC721Received.selector;
    }
}