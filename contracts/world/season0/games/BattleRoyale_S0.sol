// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../../gameplay/BattleRoyale/BattleRoyale.sol";

contract BattleRoyale_S0 is BattleRoyale{
     constructor(IRegistry registry, address rewardToken) BattleRoyale(rewardToken, registry){}
}