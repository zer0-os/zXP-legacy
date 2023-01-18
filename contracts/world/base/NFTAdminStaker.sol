// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../tokentest/ERC721TestToken.sol";

contract AdminStaker{
    struct NFT {
        address contractAddress;
        uint token;
    }

    address revertTo;   
    uint limit = 9;
    uint mintWindow = 10000;
    uint deployedAt;

    constructor(address revertOwnerTo) {
        revertTo = revertOwnerTo;
        deployedAt = block.number;
    }

    ///Contract must be admin of the NFT contracts with rights to adminTransfer
    function stake(NFT[] memory nfts) public {
        for (uint i = 0; i < limit; i++) {
            ERC721TestToken(nfts[i].contractAddress).adminTransfer(msg.sender, address(this), nfts[i].token);
        }
    }

    /// @dev anyone can revert the owner after the mint is over
    function revertOwner(ERC721TestToken nftContract) public {
        require(block.number >= deployedAt + mintWindow, "Mint is active");
        nftContract.unsafeTransfer(revertTo);
    }
}