// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
//Address : 0xB302F922B24420f3A3048ddDC4E2761CE37Ea098
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// External service contracts providing financial services
import "./Bank.sol";
import "./insurance.sol";

contract CBDC is ERC20 {
    using SafeMath for uint256;

    Bank public loanService; // External contract for providing loans
    InsurancePolicy public insuranceService; // External contract for providing insurance
    address public centralAuthority; // Central authority to monitor and enforce rules
    mapping(address => uint256) public spendingHistory; // Mapping to track spending history
    mapping(address => uint256) public crimeCount; // Mapping to track crimes committed by a certain user
    mapping(address => bool) public isSanctioned; //To keep track of user sanctions
    // Events for financial service interactions
    event LoanRequested(address indexed user, uint256 amount);
    event InsurancePurchased(address indexed user, uint256 premium);
    event CrimeRecorded(address indexed user, string  description);
    event Transaction(address indexed sender, address indexed receiver, uint256 amount);
    event UserSanctioned(address indexed user);
    event UserUnsanctioned(address indexed user);

    modifier notSanctioned() {
        require(!isSanctioned[msg.sender], "User is currently sanctioned");
        _;
    }

    modifier onlyCentralAuthority() {
        require(msg.sender == centralAuthority, "Only central authority can call this function");
        _;
    }

    constructor(
        address _centralAuthority,
        address _loanService,
        address _insuranceService
    ) ERC20("CBDC Token", "CBDC") {
        centralAuthority = _centralAuthority;
        loanService = Bank(_loanService);
        insuranceService = InsurancePolicy(_insuranceService);
        // Mint initial supply (1,000,000 CBDC tokens)
        _mint(msg.sender, 1000000 * (10**uint256(decimals())));
        balances[centralAuthority] = 1000000 * (10**uint256(decimals()));
    }
     function transfer(address to, uint256 value) public override  notSanctioned returns (bool) {
        // Record the transaction
        emit Transaction(msg.sender, to, value);

        // Check spending history and increment crime count if necessary
        checkSpendingHistory(msg.sender, value);

        //Increment the receiver's wallet with the amount
        balances[to] += value;
        //Decrement the central authority's wallet a well
        balances[msg.sender] -= value;

        // Accumulate spending history
        spendingHistory[msg.sender] = spendingHistory[msg.sender].add(value);

        // Check spending history and increment crime count if necessary
        checkSpendingHistory(msg.sender, value);

        // Call the parent ERC20 transfer function
        return super.transfer(to, value);
    }

    function checkSpendingHistory(address user, uint256 value) internal {
        // Simulated condition: If the user spends more than 100 tokens, record a "crime"
        if (value > 3000) {
            crimeCount[user] = crimeCount[user].add(1);
            emit CrimeRecorded(user, "Excessive spending");
        }

        // You can add more conditions based on your use case
    }

    // Function for the central authority to sanction a user based on their "crimes"
    function sanctionUser(address user) public onlyCentralAuthority {
        require(crimeCount[user] >= 3, "Not enough crimes to warrant sanctions");
        
        // Implement your sanction logic here, such as freezing assets, restricting transactions, etc.
        isSanctioned[user] = true;
        emit UserSanctioned(user);
        // Reset the crime count after sanctions
        crimeCount[user] = 0;
    }
    function unsanctionUser(address user) public onlyCentralAuthority {
        isSanctioned[user] = false;
        emit UserUnsanctioned(user);
    }
    // Function to request a loan from the external loan service
    function requestLoan(uint256 amount, uint256 duration) public {
        require(balances[msg.sender] >= amount, "Insufficient CBDC balance to request the loan");
        
        // Execute the loan request in the external service
        loanService.getLoan(amount, duration);

        // Update the CBDC balance after the loan is granted
        _transfer(msg.sender, address(loanService), amount);

        // Emit an event for tracking the loan request
        emit LoanRequested(msg.sender, amount);
    }

    // Function to purchase insurance from the external insurance service
    function purchaseInsurance(uint256 insuranceId, address account, string memory incidentDescription, uint256 premium) public {


        // Execute the insurance purchase in the external service
        insuranceService.getInsured(insuranceId, account, incidentDescription);

        // Update the CBDC balance after purchasing insurance
        _transfer(msg.sender, address(insuranceService), premium);

        // Emit an event for tracking the insurance purchase
        emit InsurancePurchased(msg.sender, premium);
    }

    // Function for the central authority to interact with financial services on behalf of users
    function centralAuthorityAction(address user) public view onlyCentralAuthority returns (string memory _spending){
        //I'll be able to view all tokens that are in the system and where they're being spent most
        _spending = string(abi.encodePacked("Total tokens transacted: ", toString(spendingHistory[user])));
        //_crimes = string(abi.encodePacked("Total crimes committed: ", toString(crimeCount[user]), "Thank You"));
        return _spending;

    }
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


