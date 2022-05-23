pragma solidity ^0.5.0;
 
contract crowdFunding{
    address payable manager;
    mapping(address=>uint) contributors;
    uint target;
    uint deadline;
    uint minContribution;
    uint noOfContributors;
    uint amountReceived;

    struct request{
        string description;
        address payable recipient;
        uint value;
        uint totalVoters;
        bool completed;
        mapping(address=>bool) voters;
    }

    mapping(uint=>request) public requests;
    uint numRequests;


    constructor(uint _deadline, uint _target) public{
    deadline = block.timestamp + _deadline ;
    target= _target;
    minContribution = 100 wei;
    manager = msg.sender;
    }

    function sendEth() public payable{
        require(msg.value >= minContribution);
        require(block.timestamp <= deadline);

        if(contributors[msg.sender]==0) {noOfContributors++;}
        contributors[msg.sender]+=msg.value;
        amountReceived+=msg.value;
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    function refund() public {
        require(block.timestamp>deadline && amountReceived<target);
        require(contributors[msg.sender]>0);

        address payable user=(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0; 
    }

    modifier onlyManager{
        require(manager==msg.sender);
        _;
    }

    function createRequest(string memory _description, address payable _recipient, uint _value) public onlyManager {
        request storage newRequest = requests[numRequests];
        numRequests++;
        newRequest.description= _description;
        newRequest.recipient= _recipient;
        newRequest.value=_value;
        newRequest.completed= false;
        newRequest.totalVoters= 0;
    }

    function makeVotes(uint _requestNo) public{
        require(contributors[msg.sender]>0);
        request storage vote = requests[_requestNo];
        require(vote.voters[msg.sender]==false);
        vote.voters[msg.sender]==true;
        vote.totalVoters++;
    } 

    function makePayment(uint _RequestNo) public payable onlyManager{
        require(msg.value>=amountReceived);
        request storage payment = requests[_RequestNo];
        require(payment.totalVoters>noOfContributors/2);
        require(payment.completed==false);
        payment.recipient.transfer(payment.value);
        payment.completed==true;
    }
    
}
