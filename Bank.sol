// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
//Address: 0xA831F4e5dC3dbF0e9ABA20d34C3468679205B10A
interface Bank {
    function balanceOf(address _owner) external view returns (uint256 balance);
    function sendMoney(address _receiver, uint256 amount) external returns (bool success);
    function getLoan(uint256 amount, uint256 duration) external returns (string memory details); // Changed return type
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event LoanApproval(address indexed _owner, uint256 amount, string interest, uint256 duration); // Changed interest type
}

contract Standard_Bank is Bank {
    using SafeMath for uint256;
    mapping(address => uint256) public balances;
    address public owner; // Made owner public
    string public interest; // Made interest public
    uint256 public loanCounter; // Added loan counter

    constructor(address _owner, uint256 _initialAmount) {
        balances[msg.sender] = _initialAmount;
        owner = _owner;
    }

    function balanceOf(address _owner) public override view returns (uint256 balance) {
        return balances[_owner];
    }

    function sendMoney(address _receiver, uint256 amount) public override returns (bool success) {
    require(balances[msg.sender] >= amount, "You don't have enough funds to carry out this transaction!");
    balances[_receiver] += amount;
    balances[msg.sender] -= amount;
    emit Transfer(msg.sender, _receiver, amount);
    return true;
}


    function getLoan(uint256 amount, uint256 duration) public override returns (string memory details) {
        require(amount == balances[msg.sender].mul(2), "You are not eligible for this loan, minimal balance required is 10% of the loan amount");
        balances[msg.sender] += amount;
        interest = "20%"; // Set interest as a string
        loanCounter++; // Increment loan counter
        emit LoanApproval(msg.sender, amount, interest, duration);
        details = string(abi.encodePacked("You have been granted a loan of ", toString(amount), " lasting ", toString(duration), " months on interest of ", interest)); // Updated string concatenation
        return details;
    }

    // Helper function to convert uint to string
    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
