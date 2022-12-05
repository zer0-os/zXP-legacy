// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "../../RegistryClient.sol";
import "../../../interfaces/IZXP.sol";
import "./RewardVault_S0.sol";

///Stakes with address owners
contract NFTStakePool_S0 is RegistryClient{

    constructor(IRegistry registry) RegistryClient(registry) {}
    
    mapping(uint => address) public staker;
    mapping(uint => uint) public stakedAtBlock;
    ///NFT holder locks item for the season by transferring NFT in
    function _stake(address _staker, address nftContractAddress, uint tokenId) internal {
        uint tokenHash = uint(keccak256(abi.encodePacked(nftContractAddress, tokenId)));
        IZXP(addressOf("ZXP", season)).setSeason(tokenHash, season);
        staker[tokenHash] = _staker;
        stakedAtBlock[tokenHash] = block.number;
    }
    ///unstakes the nft item on season advancement
    function _unstake(address contractAddress, uint tokenId) public{
        uint tokenHash = uint(keccak256(abi.encodePacked(contractAddress, tokenId)));
        require(msg.sender == staker[tokenHash], "Sender isnt staker");
        if(currentWorldSeason() > IZXP(addressOf("ZXP", season)).itemSeason(uint(tokenHash))){
            //@todo increment item season
            IZXP(addressOf("ZXP", season)).awardXP(tokenHash, 100);
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