// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SecureVoting {
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    struct Voting {
        mapping(uint => Candidate) candidates;
        mapping(address => bool) voters;
        mapping(address => uint256) voteTimestamps;
        uint candidatesCount;
        bool active;
    }

    mapping(uint => Voting) public votings;
    mapping(address => bool) public registeredVoters;

    uint public votingCount;
    address public admin;

    event Voted(address indexed voter, uint indexed votingId, uint indexed candidateId, uint256 timestamp);
    event VoterRegistered(address indexed voter);
    event VotingStarted(uint indexed votingId);
    event VotingEnded(uint indexed votingId);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function.");
        _;
    }

    modifier onlyRegisteredVoter() {
        require(registeredVoters[msg.sender], "You must be a registered voter.");
        _;
    }

    modifier votingOpen(uint votingId) {
        require(votings[votingId].active, "Voting is not currently active.");
        _;
    }

    constructor() {
        admin = msg.sender; 
    }

    function createVoting(string[] memory candidateNames) public onlyAdmin {
        votingCount++;
        Voting storage voting = votings[votingCount];
        voting.active = false;
        for (uint i = 0; i < candidateNames.length; i++) {
            addCandidate(voting, candidateNames[i]);
        }
    }

    function addCandidate(Voting storage voting, string memory name) private {
        voting.candidatesCount++;
        voting.candidates[voting.candidatesCount] = Candidate(voting.candidatesCount, name, 0);
    }

    function registerVoter(address voter) public onlyAdmin {
        require(!registeredVoters[voter], "Voter is already registered.");
        registeredVoters[voter] = true;
        emit VoterRegistered(voter);
    }

    function vote(uint votingId, uint candidateId) public onlyRegisteredVoter votingOpen(votingId) {
        Voting storage voting = votings[votingId];
        require(!voting.voters[msg.sender], "You have already voted in this voting.");
        require(candidateId > 0 && candidateId <= voting.candidatesCount, "Invalid candidate ID.");
        
        voting.voters[msg.sender] = true; 
        voting.candidates[candidateId].voteCount++;
        voting.voteTimestamps[msg.sender] = block.timestamp;

        emit Voted(msg.sender, votingId, candidateId, block.timestamp);
    }

    function startVoting(uint votingId) public onlyAdmin {
        require(!votings[votingId].active, "Voting is already active.");
        votings[votingId].active = true;
        emit VotingStarted(votingId);
    }

    function endVoting(uint votingId) public onlyAdmin {
        require(votings[votingId].active, "Voting is not currently active.");
        votings[votingId].active = false;
        emit VotingEnded(votingId);
    }

    function getCandidates(uint votingId) public view returns (Candidate[] memory) {
        Voting storage voting = votings[votingId];
        Candidate[] memory candidateArray = new Candidate[](voting.candidatesCount);
        for (uint i = 1; i <= voting.candidatesCount; i++) {
            candidateArray[i - 1] = voting.candidates[i];
        }
        return candidateArray;
    }


    function getVoteCount(uint votingId, uint candidateId) public view returns (uint) {
        require(candidateId > 0 && candidateId <= votings[votingId].candidatesCount, "Invalid candidate ID.");
        return votings[votingId].candidates[candidateId].voteCount;
    }

    function getVoteTimestamp(uint votingId, address voter) public view returns (uint256) {
        Voting storage voting = votings[votingId];
        require(voting.voters[voter], "This voter has not voted in this voting.");
        return voting.voteTimestamps[voter];
    }
}
