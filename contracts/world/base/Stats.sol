// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Stats {
    uint public randSeed;
    uint healthCurve = 25;
    uint manaCurve = 10;
    uint powerCurve = 1;
    uint baseHealth = 120;
    uint baseMana = 60;
    uint basePower = 20;
    uint baseCoef = 10;
    uint baseMod = 3;

    constructor() {
        randSeed = 1; //block.difficulty;
    }

    function _health(uint level) internal view returns (uint) {
        return
            (1 + (randSeed % baseMod)) *
            baseHealth *
            baseCoef +
            healthCurve *
            level *
            level;
    }

    function _mana(uint level) internal view returns (uint) {
        return
            (1 + (randSeed % baseMod)) *
            baseMana *
            baseCoef +
            manaCurve *
            level *
            level;
    }

    function _power(uint level) internal view returns (uint) {
        return
            (1 + (randSeed % baseMod)) *
            basePower *
            baseCoef +
            powerCurve *
            level *
            level;
    }
}
