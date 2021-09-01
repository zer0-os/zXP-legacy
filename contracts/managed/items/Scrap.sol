pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./Item.sol";

contract Scrap is Item{

    constructor() Item("Scrap") {}

}