// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../../RegistryClient.sol";

//import "IZXP.sol";

contract NFTStakePool_S0 is RegistryClient{

    constructor(IRegistry registry) RegistryClient(registry) {}
    
    mapping(bytes32 => address) public staker;
    mapping(bytes32 => uint) public stakedAtBlock;
    ///NFT holder locks item for the season
    function stake(address nftContractAddress, uint tokenId) public {
        require(ERC721(nftContractAddress).ownerOf(tokenId) == msg.sender);
        staker[keccak256(abi.encode(nftContractAddress, tokenId))] = msg.sender;
        stakedAtBlock[keccak256(abi.encode(nftContractAddress, tokenId))] = block.number;
    }
    ///ZXP unstakes the nft item on season advancement
    function unstake(bytes32 tokenHash) public only("ZXP") returns(uint){
        require(staker[tokenHash] != address(0));
        staker[tokenHash] = address(0);
        return(stakedAtBlock[tokenHash]);
    }
}