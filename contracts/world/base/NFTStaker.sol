// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTStaker{
    mapping(bytes32 => address) public staker;
    mapping(bytes32 => uint) public stakedAtBlock;
    mapping(bytes32 => bytes32) public vaultedIn; //tokenHash to vaultId
    mapping(bytes32 => address) public vaultOwner;
   ///NFT holder locks item for the season by transferring NFT in
    function _stake(address _staker, address contractAddress, uint tokenId) internal {
        bytes32 tokenHash = keccak256(abi.encodePacked(contractAddress, tokenId));
        require(vaultedIn[tokenHash] == bytes32(0), "Token already vaulted");

        //IZXP(addressOf("ZXP", season)).setSeason(uint(tokenHash), season);
        //vaultedIn[tokenHash] = vaultNumber;
        stakedAtBlock[tokenHash] = block.number;
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