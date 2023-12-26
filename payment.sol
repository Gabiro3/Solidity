pragma solidity ^0.5.1;

//Async nature if the blockchain
contract PayMe {
    //Create a hashmap to keep track of all balances
    mapping(address => uint256) public balances;
    //Create a payable wallet address
    address payable wallet;
    //Creating events, this one will keep track of all purchases that have happened inside the SM
    event Purchase {
        address _buyer;
        uint256 _amount;
    };
    constructor(address payable _wallet) public {
        wallet = _wallet;
    }
    function() external payable { //This is a callback function which will be called outside of the SM
                                  //Hence the modifier external
        buyToken();
    }
    //declare this function payables
    function buyToken() public payable{
        balances[msg.sender] += 1; //increment new key-value pair
        wallet.transfer(msg.value); //get input to transfer funds
        emit Purchase(msg.sender, 1); //Trigger this event
    }
}