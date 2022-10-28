// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
//import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "../../RegistryClient.sol";
import "../../../interfaces/IZXP.sol";

contract NFTStakePool_S0 is RegistryClient{

    constructor(IRegistry registry) RegistryClient(registry) {}
    
    uint public test;
    mapping(bytes32 => address) public staker;
    mapping(bytes32 => uint) public stakedAtBlock;
    ///NFT holder locks item for the season by transferring NFT in
    function _stake(address _staker, address nftContractAddress, uint tokenId) internal {
        bytes32 tokenHash = keccak256(abi.encodePacked(nftContractAddress, tokenId));
        staker[tokenHash] = _staker;
        stakedAtBlock[tokenHash] = block.number;
        emit Staked(_staker, msg.sender, tokenId);
    }
    ///unstakes the nft item on season advancement
    function _unstake(address contractAddress, uint tokenId) public{
        require(msg.sender == staker[keccak256(abi.encodePacked(contractAddress, tokenId))], "Sender isnt staker");
        
        bytes32 tokenHash = keccak256(abi.encodePacked(contractAddress, tokenId));
        if(currentWorldSeason() > IZXP(addressOf("ZXP", season)).itemSeason(uint(tokenHash))){
            IZXP(addressOf("ZXP", season)).awardXP(uint(tokenHash), 124);
        }
        IERC721(contractAddress).transferFrom(address(this), msg.sender, tokenId);
        staker[tokenHash] = address(0);
    }

    function onERC721Received(address, address from, uint256 tokenId, bytes calldata) external returns(bytes4){
        _stake(from, msg.sender, tokenId);
        return IERC721Receiver.onERC721Received.selector;
    }
    event Staked(address player, address nftContract, uint tokenId);
    event Unstaked(address player, address nftContract, uint tokenId);
} 