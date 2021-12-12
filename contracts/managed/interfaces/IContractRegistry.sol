// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

/*
    Contract Registry interface
*/
interface IContractRegistry {
    function addressOf(bytes32 _contractName) external view returns (address);
    function addressOfItem(bytes32 _contractName, uint32 season) external;
    function advanceSeason(bytes32 _contractName, address _newContractAddress, uint256 xpAward) external;
    function itemCount() external view returns (uint256);
}
