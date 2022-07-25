
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../gameplay/Tournament.sol";

contract BeastBattle_S1 is Tournament{

     constructor(IRegistry registry) Tournament(registry, address(this), 1 days){}

     function battle(XpRecipient beast) public {
          IZXP(addressOf("ZXP", season)).awardXP(beast, 100);
     }
}