pragma solidity ^0.8.0;

contract Tournament{
    uint256 nextId;
    uint256 minPrize = 1 ether;
    mapping(uint256 => uint256) tournamentPrize;
    mapping(uint256 => address) tournamentOfficial;

    modifier onlyOfficial(uint256 id){
        require(msg.sender == tournamentOfficial[id]);
        _;
    }

    function declareTournament() external payable{
        require(msg.value >= minPrize);
        nextId++;
        tournamentPrize[nextId] = msg.value;
    }

    function submitResults(uint256 id/*, merkleRoot*/) external onlyOfficial(id){
    }

    function claimPrize(uint256 id) external {
        //verify merkle leaf
    }
}