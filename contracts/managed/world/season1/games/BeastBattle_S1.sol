
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "../../RegistryClient.sol";    
import "../../../interfaces/IZXP.sol";

contract BeastBattle_S1 is RegistryClient{

     constructor(IRegistry registry) RegistryClient(registry) {}

     function battle(XpRecipient beast) public {
          IZXP(addressOf("ZXP", season)).awardXP(beast, 100);
     }
}