pragma solidity ^0.8.0;

import "./WildVault.sol";

contract ControllerContract {
    WildVault public vault;

    constructor(WildVault _vault) {
        vault = _vault;
    }

    function withdrawFromVault(uint256 amount) external {
        vault.withdraw(amount);
    }
}
