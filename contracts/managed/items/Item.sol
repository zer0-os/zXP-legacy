pragma solidity ^0.8.0;

//import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../managed/Managed.sol";

contract Item is Managed, ItemType{
    uint8 itemType;
    constructor(
        ItemType _itemType
    ) {
        itemType = _itemType;
    }
    
    function use() external generated returns(uint256){
        return 1;
    }
}