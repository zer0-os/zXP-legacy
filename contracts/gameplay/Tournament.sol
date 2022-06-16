pragma solidity ^0.8.0;

contract Tournament{
    uint nextId;
    uint minPrize = 1 ether;
    mapping(uint => uint[3]) top3tournamentPrizes; // 0 is first place 
    mapping(uint => address) tournamentOfficial;
    mapping(address => uint) winnings; 

    modifier onlyOfficial(uint256 id){
        require(msg.sender == tournamentOfficial[id]);
        _;
    }
    
    ///@param first second third prizes
    function declareTop3Tournament(uint first, uint second, uint third) external payable{
        require(msg.value >= minPrize);
        nextId++;
        tournamentPrizes[nextId].push(first);
        tournamentPrizes[nextId].push(second);
        tournamentPrizes[nextId].push(third);
        tournamentOfficial[nextId] = msg.sender;
    }

    function submitTop3Results(uint256 id, address firstplace, address secondplace, address thirdplace) external onlyOfficial(id){
        winnings[firstplace] += tournamentPrizes[id][0];
        winnings[secondplace] += tournamentPrizes[id][1];
        winnings[thirdplace] += tournamentPrizes[id][2];
    }
}