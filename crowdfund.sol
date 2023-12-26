pragma solidity >=0.5.0 <0.8.0;

contract FundMe {
    address payable sender;
    uint256 amount;
    address payable receiver;

    mapping(address => uint256) public balances;

    constructor(address memory payable _sender) public {
        sender = _sender;
    }
    
    function fundMe(uint256 memory _amount) payable public {
        balances[msg.sender] -= _amount;
        sender.transfer(_amount);
    }
}