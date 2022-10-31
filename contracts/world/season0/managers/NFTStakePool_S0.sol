// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "../../RegistryClient.sol";
import "../../../interfaces/IZXP.sol";

contract NFTStakePool_S0 is RegistryClient{

    constructor(IRegistry registry) RegistryClient(registry) {}
    
    mapping(bytes32 => address) public staker;
    mapping(bytes32 => uint) public stakedAtBlock;
    ///NFT holder locks item for the season by transferring NFT in
    function _stake(address _staker, address nftContractAddress, uint tokenId) internal {
        //require(ERC721(nftContractAddress).ownerOf(tokenId) == msg.sender);
        staker[keccak256(abi.encodePacked(nftContractAddress, tokenId))] = _staker;
        stakedAtBlock[keccak256(abi.encodePacked(nftContractAddress, tokenId))] = block.number;
    }
    ///ZXP unstakes the nft item on season advancement
    function _unstake(address contractAddress, uint tokenId) public{
        require(msg.sender == staker[keccak256(abi.encodePacked(contractAddress, tokenId))], "Sender isnt staker");
        IERC721(contractAddress).transferFrom(address(this), msg.sender, tokenId);
    }

    function onERC721Received(address, address from, uint256 tokenId, bytes calldata) external returns(bytes4){
        _stake(from, msg.sender, tokenId);
        emit Staked(from, msg.sender, tokenId);
        return IERC721Receiver.onERC721Received.selector;
    }
    event Staked(address player, address nftContract, uint tokenId);
} 