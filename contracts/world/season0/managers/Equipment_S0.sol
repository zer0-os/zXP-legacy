// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "../../RegistryClient.sol";
import "../../../interfaces/IZXP.sol";
import "./RewardVault_S0.sol";

///Stakes with address owners
contract Equipment_S0 is RegistryClient{

    constructor(IRegistry registry) RegistryClient(registry) {}
    
    mapping(bytes32 => address) public staker;
    mapping(bytes32 => uint) public stakedAtBlock;
    ///NFT holder locks item for the season by transferring NFT in
    function _stake(address _staker, address nftContractAddress, uint tokenId) internal {
        bytes32 tokenHash = keccak256(abi.encodePacked(nftContractAddress, tokenId));
        staker[tokenHash] = _staker;
        stakedAtBlock[tokenHash] = block.number;
    }
    ///unstakes the nft item on season advancement
    function _unstake(address contractAddress, uint tokenId) public{
        require(msg.sender == staker[keccak256(abi.encodePacked(contractAddress, tokenId))], "Sender isnt staker");
        bytes32 tokenHash = keccak256(abi.encodePacked(contractAddress, tokenId));
        if(currentWorldSeason() > IZXP(addressOf("ZXP", season)).itemSeason(uint(tokenHash))){
            IZXP(addressOf("ZXP", season)).awardXP(uint(tokenHash), 100);
            RewardVault_S0(addressOf("RewardVault", season)).awardTopItem(msg.sender);
        }
        staker[tokenHash] = address(0);
        IERC721(contractAddress).transferFrom(address(this), msg.sender, tokenId);
    }

    function onERC721Received(address, address from, uint256 tokenId, bytes calldata) external returns(bytes4){
        _stake(from, msg.sender, tokenId);
        return IERC721Receiver.onERC721Received.selector;
    }
} 