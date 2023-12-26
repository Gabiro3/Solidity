// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
//This Project requires a frontend client app to interact
//with the user's wallet for a signature hash...
// Importing ECDSA library for signature verification
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

interface System {
    function requestVoteSignature(address voter, string memory vote) external view returns (bytes32 messageHash);

    function placeVote(address voter, string memory vote, bytes memory signature) external returns (bool success);

    event VotePlaced(address indexed voter, string vote);
}

contract VotingSystem is System {
    using ECDSA for bytes32;

    address public admin;
    uint256 public totalVotes;
    mapping(string => uint256) public allVotes;

    constructor() {
        admin = msg.sender;
    }

    // Function to request a vote signature from the user
    function requestVoteSignature(address _voter, string memory _vote) public pure override returns (bytes32 messageHash) {
        return keccak256(abi.encodePacked(_voter, _vote));
    }

    // Function to place a vote with a signature
    function placeVote(address _voter, string memory _vote, bytes memory _signature) public override returns (bool success) {
        // Verify the voter's signature
        bytes32 messageHash = keccak256(abi.encodePacked(_voter, _vote));
        require(messageHash.recover(_signature) == _voter, "Invalid signature");

        // Update the state with the new vote
        allVotes[_vote]++;
        totalVotes++;

        // Emit the VotePlaced event
        emit VotePlaced(_voter, _vote);
        return true;
    }
}