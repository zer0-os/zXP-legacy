// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "../../RegistryClient.sol";
import "../../../interfaces/IZXP.sol";
import "./RewardVault_S0.sol";

///Stakes with address owners
contract Vault_S0 is RegistryClient{

    constructor(IRegistry registry) RegistryClient(registry) {}
    
    mapping(bytes32 => bytes32) public vaultedIn; //tokenHash to vaultId
    mapping(bytes32 => address) public vaultOwner;
    mapping(bytes32 => uint) public stakedAtBlock;
    mapping(bytes32 => uint) public salePrice;

    function createVault(bytes32 vaultNumber) public {
        require(vaultOwner[vaultNumber] == address(0), "Vault number taken");
        vaultOwner[vaultNumber] = msg.sender;
    }
    ///NFT holder locks item for the season by transferring NFT in
    function _stake(bytes32 vaultNumber, address _staker, address contractAddress, uint tokenId) internal {
        bytes32 tokenHash = keccak256(abi.encodePacked(contractAddress, tokenId));
        require(vaultedIn[tokenHash] == bytes32(0), "Token already vaulted");
        require(vaultOwner[vaultNumber] == _staker, "Staker isnt vault owner");

        IZXP(addressOf("ZXP", season)).setSeason(uint(tokenHash), season);
        vaultedIn[tokenHash] = vaultNumber;
        stakedAtBlock[tokenHash] = block.number;
    }
    ///unstakes the nft item on season advancement
    function _unstake(address contractAddress, uint tokenId) public{
        bytes32 tokenHash = keccak256(abi.encodePacked(contractAddress, tokenId));
        require(vaultedIn[tokenHash] != bytes32(0), "Token isnt vaulted");
        require(vaultOwner[vaultedIn[tokenHash]] == msg.sender, "Sender isnt vaultOwner");
        if(currentWorldSeason() > IZXP(addressOf("ZXP", season)).itemSeason(uint(tokenHash))){
            IZXP(addressOf("ZXP", season)).setSeason(uint(tokenHash), currentWorldSeason());
            IZXP(addressOf("ZXP", season)).awardXP(uint(tokenHash), 100);
            RewardVault_S0(addressOf("RewardVault", season)).awardTopItem(msg.sender);
        }
        vaultedIn[tokenHash] = 0;
        IERC721(contractAddress).transferFrom(address(this), msg.sender, tokenId);
    }
    function sell(bytes32 vaultNumber, uint price) public {
        require(vaultOwner[vaultNumber] == msg.sender, "Sender isnt vaultOwner");
        salePrice[vaultNumber] = price;
    }
    function buy(bytes32 vaultNumber) public payable {
        require(salePrice[vaultNumber] > 0, "Vault not for sale");
        require(msg.value == salePrice[vaultNumber], "Invalid payment");
        address seller = vaultOwner[vaultNumber];
        vaultOwner[vaultNumber] = msg.sender;
        payable(seller).transfer(msg.value);
    }

    function getVault(address contractAddress, uint tokenId) public view returns(bytes32){
        return vaultedIn[keccak256(abi.encodePacked(contractAddress, tokenId))];
    }

    function onERC721Received(address, address from, uint256 tokenId, bytes calldata vaultNumber) external returns(bytes4){
        _stake(bytes32(vaultNumber), from, msg.sender, tokenId); //msg.sender is the nftcontract
        return IERC721Receiver.onERC721Received.selector;
    }

} 