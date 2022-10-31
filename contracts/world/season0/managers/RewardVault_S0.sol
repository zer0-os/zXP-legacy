// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "../../RegistryClient.sol";
import "../../../interfaces/IZXP.sol";
import "../../../Owned.sol";

contract RewardVault_S0 is Owned, RegistryClient{
    
    constructor(IRegistry registry) RegistryClient(registry) {}
    
    uint count;
    mapping(uint => address) contractAddress;
    mapping(uint => uint) token; 
    //mapping(address => mapping(uint => address)) originalOwner;
    
    function _vault(address nftContractAddress, uint tokenId) internal{
        contractAddress[count] = nftContractAddress;
        token[count] = tokenId;
        //originalOwner[nftContractAddress][tokenId] = owner; 
        count++;
    }

    function _unvault(address to, address nftContractAddress, uint tokenId) internal{
        //contractAddress[rand] = contractAddress[count];
        //token[rand] = token[count];
        count--;
        IERC721(nftContractAddress).safeTransferFrom(address(this), to, tokenId);
    }

    function awardRandomItem(address to) public only("NFTStakePool"){
        _unvault(
            to,
            contractAddress[count-1], 
            token[count-1]);
    }

    function onERC721Received(address, address, uint256 tokenId, bytes calldata) external returns(bytes4){
        _vault(msg.sender, tokenId);
        return IERC721Receiver.onERC721Received.selector;
    }
}