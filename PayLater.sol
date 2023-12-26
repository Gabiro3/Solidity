// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface Payment {
    function executePayment(address _receiver, uint256 amount) external returns (bool success);
    function checkBalance(address _wallet) external view returns (uint256 balance);
    event Pay(address indexed _receiver, uint256 amount);
}

contract PayLater {
    using SafeMath for uint256; // Use SafeMath for uint256 operations

    address public owner;
    mapping(address => uint256) public balances;
    uint256 public deploymentTime;
    uint256 public paymentTime;

    constructor(address _owner, uint256 _initialAmount) {
        owner = _owner;
        balances[msg.sender] = _initialAmount;
        deploymentTime = block.timestamp; // Record the deployment time
        paymentTime = deploymentTime.add(100); // Set the payment time to 100 seconds after deployment
    }

    function checkBalance(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function executePayment(address _receiver, uint256 amount) public returns (bool success) {
        require(block.timestamp >= paymentTime, "Payment can only be executed after 100 seconds.");

        require(balances[msg.sender] >= amount, "Not enough funds to perform the transaction");

        balances[_receiver] = balances[_receiver].add(amount); // Use SafeMath for addition
        balances[msg.sender] = balances[msg.sender].sub(amount, "Subtraction error"); // Use SafeMath for subtraction with error message
        emit Pay(_receiver, amount);
        return true;
    }

    // Function to manually trigger payment after 100 seconds
    function triggerPayment() public returns (bool success) {
        require(block.timestamp >= paymentTime, "Payment can only be triggered after 100 seconds.");

        // Assuming you want to pay the owner, you can replace 'owner' with the desired address
        return executePayment(owner, balances[msg.sender]);
    }
}
