//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract lottery{
    address public manager;
    address payable[] players;
    constructor () payable {
    manager = msg.sender;
    }
    function alreadyentred() view private returns(bool){
        for(uint i=0;i<players.length;i++){
            if(players[i]==msg.sender){
                return true;
            }
        }
        return false;
    }
    function enterplayer() payable public{
        require(manager != msg.sender,"you are manager u cannot enter");
        require(msg.value>=2 ether ,"enter more value");
        require(alreadyentred()==false,"you cannot enter");
        players.push(payable(msg.sender));
    }
    function random() view private returns(uint){
        return uint(sha256(abi.encodePacked(block.difficulty,block.number,players)));
    }
    function pickwinner() public {
        require(msg.sender == manager,"only manager can pick");
        require(players.length>=3,"more particpants are required");
        uint index=random()%players.length;
        players[index].transfer(address(this).balance);
        players=new address payable[](0);
    }
    function getplayers() view public returns (address payable[] memory){
        return players;
    }
    function bal_lot() public view returns(uint){
        require(msg.sender==manager,"only manager can see balance");
         return address(this).balance;
    }
}