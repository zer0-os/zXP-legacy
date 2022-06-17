pragma solidity 0.8.14;

import "./interfaces/IERC721.sol";

contract NftOwned {
    IERC721 public nftContract;

    constructor(IERC721 nftContractAddress){
        nftContract = nftContractAddress;
    }

    modifier tokenHolderOnly(uint id){
        require(nftContract.ownerOf(id) == msg.sender, "Sender isnt nft holder");
        _;
    }
}