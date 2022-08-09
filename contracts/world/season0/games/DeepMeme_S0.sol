// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../gameplay/Tournament.sol";

contract DeepMeme_S0 is Tournament{

    constructor(IRegistry registry, address official) Tournament(registry, official, 1 days, 100){}

    ///This is where custom DeepMeme logic goes
}