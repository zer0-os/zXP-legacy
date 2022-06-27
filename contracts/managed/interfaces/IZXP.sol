pragma solidity 0.8.14;

import "../world/base/XpRecipient.sol";

interface IZXP{
    function awardXP(XpRecipient, uint) external view returns (address);
}