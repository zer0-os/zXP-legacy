
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../gameplay/RvBTournament.sol";
import "../../base/XpRecipient.sol";

contract BeastBattle_S1 is RvBTournament{
     mapping(uint => uint) lastBattleRound; //Recorded block of the beast's last battle 
     mapping(uint => uint) redBattles;
     mapping(uint => uint) blueBattles;

     constructor(IRegistry registry)  
     RvBTournament(registry, address(this), 1 days, 100){}

     function battle(uint beast, bool redOrBlue) public {
          //require(lastBattleRound[beast] < block.timestamp/(1 days), "ZXP Already battling today");
          lastBattleRound[beast] = block.timestamp/(1 days);
          if(redOrBlue){
               blueBattles[beast] += 1;
          }else{
               redBattles[beast] += 1;
          }
          IZXP(addressOf("ZXP", season)).awardXP(beast, 100);
     }
}