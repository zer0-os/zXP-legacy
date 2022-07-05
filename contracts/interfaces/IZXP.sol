// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "../world/base/XpRecipient.sol";

interface IZXP{
    function awardXP(XpRecipient, uint) external view returns (address);
}