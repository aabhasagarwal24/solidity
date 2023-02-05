//SPDX-License-Identifier: MIT
//hello world
pragma solidity ^0.8.0;
contract CrowdFunding{
    mapping(address=>uint) public contributors;
    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedamount;
    uint public noOfContributors;
    constructor(uint _target,uint _deadline){
        target=_target;
        deadline=block.timestamp+_deadline;
        minimumContribution=100 wei;
        manager=msg.sender;
    }
    struct Request{
        string description;
        address payable recipent;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address=>bool)voters;
    }
    mapping (uint=>Request) public requests;
    uint public numRequests;
    function sendEth() public payable {
        require(block.timestamp<deadline,"Deadline has passed");
        require(msg.value>=minimumContribution,"You have to pay atleast 100 wei");
        if(contributors[msg.sender]==0){
            noOfContributors++;
        }
        contributors[msg.sender]+=msg.value;
        raisedamount+=msg.value;
    }
    function getContractBalance() public view returns(uint){
        require(msg.sender==manager,"Only Manager can access");
        return address(this).balance;
    }
    function refund()public{
        require(block.timestamp>deadline && raisedamount<target,"You are not eligible");
        require(contributors[msg.sender]>0,"You have not contributed");
        address payable user=payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;
    }
    function createRequest(string memory _description,address payable _recipient,uint _value)public{
        require(msg.sender==manager,"Only Manager can access");
        Request storage newRequest=requests[numRequests];
        numRequests++;
        newRequest.description=_description;
        newRequest.recipent=_recipient;
        newRequest.value=_value;
        newRequest.completed=false;
        newRequest.noOfVoters=0;
    }
    function voteRequest(uint _requestno) public{
        require(contributors[msg.sender]>0,"first you should contribute");
        Request storage thisRequest=requests[_requestno];
        require(thisRequest.voters[msg.sender]==false,"You have already voted");
        thisRequest.voters[msg.sender]=true;
        thisRequest.noOfVoters++;
    }
    function makepayment(uint _requestno) public{
       require(msg.sender==manager,"Only Manager can access"); 
       require(raisedamount>=target,"Target is not met");
       Request storage thisRequest=requests[_requestno];
       require(thisRequest.completed==false,"The request has been already completed");
       require(thisRequest.noOfVoters>noOfContributors/2,"Majority does not support");
       thisRequest.recipent.transfer(thisRequest.value);
       thisRequest.completed=true;
    }
}