// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
// import "@openzeppelin";
import "@openzeppelin/contracts/utils/Strings.sol";
contract Lottery {
   address owner=msg.sender;
   uint min_contribution=1000;
   uint max_players=3;
   uint max_num_range=10;
   uint total_contribution=0;
   uint num_players=0;
   uint winning_num=0;
   struct Player{
        uint amountPlaced;
        uint numberPlacedOn;
    }

    mapping (address=>Player) playersInfo;

    address payable [] playersAddresses;
    event Winner(address winner,uint amount);
    event Status(uint players,uint max_players);

    function bet(uint num)public payable  {
require(num_players<max_players,"maximum number of players has been reached");
require(playersInfo[msg.sender].amountPlaced==0,"you have already placed a bet");
require(num>=1&&num<=max_num_range,string.concat("you need to bet a number between 1 and",Strings.toString(max_num_range)));
require(msg.value>min_contribution,string.concat("The minimum contribution is",Strings.toString(min_contribution),"wei"));
Player memory new_player=Player(msg.value,num);
playersInfo[msg.sender]=new_player;
playersAddresses.push(payable (msg.sender));
num_players++;
total_contribution+=msg.value;
emit Status(num_players, max_players);
    }
function getWinners(uint winningNum)public{
require(msg.sender==owner);
winning_num=winningNum;
address payable [3]memory winners;
uint winner_count=0;
uint total_won=0;

for (uint i=0;i<playersAddresses.length;i++){
    address payable playerAddr=playersAddresses[i];
    if (playersInfo[playerAddr].numberPlacedOn==winningNum) {
        winners[winner_count]=playerAddr;
        total_won+=playersInfo[playerAddr].amountPlaced;
        winner_count+=1;
    }
}

for (uint j=0; j<winners.length; j++) {
uint amount_won=(playersInfo[winners[j]].amountPlaced*total_contribution)/total_won;
winners[j].transfer(amount_won);
emit  Winner(winners[j], amount_won);
}
num_players=0;
total_contribution=0;

for (uint i=0;i<playersAddresses.length;i++){
    delete playersInfo[playersAddresses[i]];
    delete playersAddresses[i];
    emit Status(num_players, max_players);
}
    } 
    function gameStatus()public view returns (uint,uint) {
        return (num_players,max_players);
    }
    function getWinningNumber() public  view returns (uint){
        return winning_num;
    }

    function cashOut()public {
        require(msg.sender==owner);
        payable (owner).transfer(address(this).balance);
    }
}