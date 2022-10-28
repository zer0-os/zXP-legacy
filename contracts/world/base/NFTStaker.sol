// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTStaker{
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
        //require(currentWorldSeason() > IZXP(addressOf("ZXP", 0)).itemSeason(uint(tokenHash)), "Must advance season to unstake");
        staker[tokenHash] = address(0);

        //return(stakedAtBlock[tokenHash]);
    }

    function onERC721Received(address, address from, uint256 tokenId, bytes memory) public virtual returns(bytes4){
        _stake(from, msg.sender, tokenId);
        return IERC721Receiver.onERC721Received.selector;
    }
}