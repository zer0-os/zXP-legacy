// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../tokentest/ERC721TestToken.sol";

contract AdminStaker{
    struct NFT {
        address contractAddress;
        uint token;
    }
    uint limit = 9;
    ///Contract must be admin of the NFT contracts with rights to adminTransfer
    function stake(NFT[] memory nfts) public {
        for (uint i = 0; i < limit; i++) {
            ERC721TestToken(nfts[i].contractAddress).adminTransfer(msg.sender, address(this), nfts[i].token);
        }
    }
}