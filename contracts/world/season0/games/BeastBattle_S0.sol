// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../RegistryClient.sol";    
import "../../../interfaces/IZXP.sol";
import "../../../gameplay/Tournament.sol";

contract BeastBattle_S0 is Tournament, RegistryClient{

     constructor(IRegistry registry) RegistryClient(registry) {}

     function battle(XpRecipient beast) public {
          IZXP(addressOf("ZXP", season)).awardXP(beast, 100);
     }
}