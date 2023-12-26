// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
//Address: 0x9bF88fAe8CF8BaB76041c1db6467E7b37b977dD7
interface Policy {
    function createInsurancePolicy(string memory description, uint256 duration, uint256 amount) external returns (uint256 insuranceId);
    function getPolicy(uint256 insuranceId) external view returns(string memory description, uint256 duration, uint256 amount);
    function getInsured(uint256 insuranceId, address account, string memory incidentDescription) external returns (bool success);
    function checkBalance(uint256 insuranceId) external view returns(uint256 balance);
    function withdrawBalance(uint256 insuranceId) external returns (bool success);

    event InsurancePolicyCreated(uint256 insuranceId, string description, uint256 duration, uint256 amount);
    event GetInsured(uint256 insuranceId, address account, string incidentDescription);
    event BalanceWithdrawn(uint256 insuranceId, address account, uint256 amount);
}

contract InsurancePolicy is Policy {
    using SafeMath for uint256;

    address public insuranceCompany;
    uint256 public totalPolicies;
    mapping(uint256 => PolicyDetails) public policies;

    struct PolicyDetails {
        string description;
        uint256 duration;
        uint256 amount;
        mapping(address => bool) clients;
        mapping(address => uint256) balances;
    }

    modifier onlyInsuranceCompany() {
        require(msg.sender == insuranceCompany, "Only the insurance company can perform this action");
        _;
    }

    constructor() {
        insuranceCompany = msg.sender;
    }

    function createInsurancePolicy(string memory _description, uint256 _duration, uint256 _amount) external override onlyInsuranceCompany returns (uint256 insuranceId) {
        insuranceId = totalPolicies;

        PolicyDetails storage newPolicy = policies[insuranceId];
        newPolicy.description = _description;
        newPolicy.duration = _duration;
        newPolicy.amount = _amount;

        totalPolicies++;

        emit InsurancePolicyCreated(insuranceId, _description, _duration, _amount);
    }

    function getPolicy(uint256 insuranceId) external view override returns(string memory _description, uint256 _duration, uint256 _amount) {
        require(insuranceId < totalPolicies, "Invalid insurance ID");
        PolicyDetails storage policy = policies[insuranceId];
        return (policy.description, policy.duration, policy.amount);
    }

    function getInsured(uint256 insuranceId, address account, string memory incidentDescription) external override returns (bool success) {
        require(insuranceId < totalPolicies, "Invalid insurance ID");
        PolicyDetails storage policy = policies[insuranceId];
        
        require(!policy.clients[account], "User is already insured with this policy");
        require(policy.balances[account] == 0, "User has an existing balance");

        // Decrement 100 from the remaining amount
        policy.amount = policy.amount.sub(100 ether);

        policy.clients[account] = true;
        policy.balances[account] = 100 ether;

        emit GetInsured(insuranceId, account, incidentDescription);
        return true;
    }

    function checkBalance(uint256 insuranceId) external view override returns(uint256 balance) {
        require(insuranceId < totalPolicies, "Invalid insurance ID");
        PolicyDetails storage policy = policies[insuranceId];
        return policy.balances[msg.sender];
    }

    function withdrawBalance(uint256 insuranceId) external override returns (bool success) {
        require(insuranceId < totalPolicies, "Invalid insurance ID");
        PolicyDetails storage policy = policies[insuranceId];
        require(policy.clients[msg.sender], "User is not insured with this policy");
        
        uint256 userBalance = policy.balances[msg.sender];
        require(userBalance > 0, "User has no balance to withdraw");

        // Transfer balance to the user
        payable(msg.sender).transfer(userBalance);

        // Reset user's balance
        policy.balances[msg.sender] = 0;

        emit BalanceWithdrawn(insuranceId, msg.sender, userBalance);
        return true;
    }
}

