// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../../RegistryClient.sol";
import "../../../interfaces/IZXP.sol";

contract NFTStakePool_S0 is RegistryClient{

    constructor(IRegistry registry) RegistryClient(registry) {}
    
    mapping(bytes32 => address) public staker;
    mapping(bytes32 => uint) public stakedAtBlock;
    ///NFT holder locks item for the season by transferring NFT in
    function _stake(address operator, address nftContractAddress, uint tokenId) internal {
        //require(ERC721(nftContractAddress).ownerOf(tokenId) == msg.sender);
        staker[keccak256(abi.encode(nftContractAddress, tokenId))] = operator;
        stakedAtBlock[keccak256(abi.encode(nftContractAddress, tokenId))] = block.number;
    }
    ///ZXP unstakes the nft item on season advancement
    function _unstake(bytes32 tokenHash) public{
        //require(staker[tokenHash] == msg.sender, "sender isnt staker");
        require(currentWorldSeason() > IZXP(addressOf("ZXP", 1)).itemSeason(uint(tokenHash)), "Must advance season to unstake");
        staker[tokenHash] = address(0);
        IERC721()
        //return(stakedAtBlock[tokenHash]);
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public returns(bytes4){
        _stake(operator, from, tokenId);
        return IERC721Receiver.onERC721Received.selector;
    }
} 