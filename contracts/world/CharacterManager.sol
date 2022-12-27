// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//import "./base/Character.sol";
import "./RegistryClient.sol";
import "./base/NFTStaker.sol";

contract CharacterManager is RegistryClient, NFTStaker{
    uint cost;

    mapping(bytes32 => address) public characterCreator;
    mapping(bytes32 => address) public characterPlayer;
    mapping(address => mapping(bytes32 => uint)) public characterSeason;
    mapping(bytes32 => uint) public salePrice;
    mapping(bytes32 => uint) public creatorshipPrice;
    mapping(bytes32 => uint) public royalty;
    mapping(bytes32 => address) public equipped;
    mapping(bytes32 => uint) public inventory;

    constructor(IRegistry registry) RegistryClient(registry) {}

    ///Creates character by setting season to 1
    ///@param name Names can be up to 32 characters, names are owned by addresses and transferable
    function create(bytes32 name, uint _royalty) public payable {
        require(msg.value == cost, "CM Invalid payment");
        characterCreator[name] = msg.sender;
        characterPlayer[name] = msg.sender;
        characterSeason[msg.sender][name] = currentWorldSeason();
        royalty[name] = _royalty;
    }

    ///Updates sale price
    ///@param price To cancel set price to 0
    function sellCharacter(bytes32 name, uint price) public {
        require(characterPlayer[name] == msg.sender, "CM Not your name");
        salePrice[name] = price;
    }
    function buyCharacter(bytes32 name) public payable{
        require(msg.value != 0, "CM No sale");
        require(msg.value == salePrice[name], "CM Invalid price");
        characterPlayer[name] = msg.sender;
        
    }
    function sellCreatorship(bytes32 name, uint price) public{
        require(characterPlayer[name] == msg.sender, "CM Not your name");
        creatorshipPrice[name] = price;
    }
    function buyCreatorship(bytes32 name, uint newRoyalty) public payable{
        require(msg.value != 0, "CM No sale");
        require(msg.value == salePrice[name], "CM Invalid price");
        characterCreator[name] = msg.sender;
        royalty[name] = newRoyalty;
    }
    function _equip(bytes32 tokenHash) internal {
        //require(nftContract.ownerOf(tokenId) == msg.sender, "You dont own this NFT");
        equipped[tokenHash] = msg.sender;
        //increase character stats
    }

    function _unequip(bytes32 name, bytes32 tokenHash) public {
        require(equipped[tokenHash] == msg.sender);
        //update character stats
        
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