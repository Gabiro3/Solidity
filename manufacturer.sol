// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

interface PaymentContract {
    function initiatePayment() external payable returns (bool success);
    function checkBalance(address wallet) external view returns (uint256);
    event PaymentMade(address indexed receiver, uint256 amount, uint256 date);
}

contract Manufacturer is PaymentContract {
    address public owner;
    uint256 public amount;
    mapping(address => uint256) public balances;
    address public beneficiary;
    uint256 public date;

    constructor(address _owner, address _beneficiary, uint256 _amount) {
        owner = _owner;
        beneficiary = _beneficiary;
        amount = _amount;
        date = block.timestamp;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not enough privileges to carry out transaction");
        _;
    }

    function initiatePayment() external override payable onlyOwner returns (bool success) {
        
        balances[owner] = 0;
        balances[beneficiary] = amount;
        emit PaymentMade(beneficiary, amount, block.timestamp);
        return true;
    }

    function checkBalance(address _wallet) external view override returns (uint256) {
        return balances[_wallet];
    }
}