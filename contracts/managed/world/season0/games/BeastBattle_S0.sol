pragma solidity ^0.8.14;

import "../../RegistryClient.sol";    
import "../../../interfaces/IZXP.sol";

contract BeastBattle_S0 is RegistryClient{

     constructor(IRegistry registry) RegistryClient(registry) {}

     function battle() public {
          IZXP(addressOf("ZXP", season)).awardXP(100);
     }
}