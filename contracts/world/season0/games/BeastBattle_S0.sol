// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../gameplay/BattleTournament.sol";

contract BeastBattle_S0 is BattleTournament{

     constructor(IRegistry registry) BattleTournament(registry, address(this), 1 days, 100){}

}