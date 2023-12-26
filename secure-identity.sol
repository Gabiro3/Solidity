// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface Identity {
    function checkIdentity(uint256 id) external view returns (string memory name, uint256 age, address wallet);
    function addIdentity(string memory name, uint256 age, address wallet) external returns (bool success);
    event IdentityAdded(string name, uint256 age, address indexed wallet);
}

contract IdentityData is Identity {
    using SafeMath for uint256;

    address public owner;
    uint256 public totalPersonnel = 0;
    mapping(uint256 => IdentityList) public identities;

    struct IdentityList {
        string name;
        uint256 age;
        address wallet;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not enough privileges to perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function checkIdentity(uint256 _id) public view override returns (string memory name, uint256 age, address wallet) {
        require(_id < totalPersonnel, "Invalid personnel ID");
        IdentityList storage personnel = identities[_id];
        return (personnel.name, personnel.age, personnel.wallet);
    }

    function addIdentity(string memory _name, uint256 _age, address _wallet) public override onlyOwner returns (bool success) {
        IdentityList storage personnel = identities[totalPersonnel];
        personnel.name = _name;
        personnel.age = _age;
        personnel.wallet = _wallet;
        totalPersonnel++;
        emit IdentityAdded(_name, _age, _wallet);
        return true;
    }
}
