// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

interface Chain {
    function createSupplyBlock(string memory client, uint256 containers, string memory from, string memory to, uint256 estimatedTime) external  returns (uint256 blockId);
    function viewBlock(uint256 blockId) external view returns (string memory client, uint256 containers, string memory from, string memory to, uint256 estimatedTime);
    function supplyLength() external view returns (string memory _details);

    event BlockCreated(uint256 blockId, string client, uint256 containers, string from, string to, uint256 estimatedTime);

}

contract SupplyChain is Chain {
    address public logisticsCompany;
    uint256 public totalBlocks;
    mapping(uint256 => BlockDetails) public supplyblocks;

    struct BlockDetails {
        string client;
        uint256 containers;
        string to;
        string from;
        uint256 estimatedTime;
    }

    modifier onlyLogisticsCompany () {
        require(msg.sender == logisticsCompany, "Only the logistics company can create a new supply chain block!");
        _;
    }

    constructor() {
        logisticsCompany = msg.sender;
    }

    function createSupplyBlock(string memory _client, uint256 _containers, string memory _from, string memory _to, uint256 _estimatedTime) public override onlyLogisticsCompany returns (uint256 blockId) {
        blockId = totalBlocks;
        BlockDetails storage newBlock = supplyblocks[blockId];
        newBlock.client = _client;
        newBlock.containers = _containers;
        newBlock.to = _to;
        newBlock.from = _from;
        newBlock.estimatedTime = _estimatedTime;

        totalBlocks ++;

        emit BlockCreated(blockId, _client, _containers, _to, _from, _estimatedTime);
        return blockId;
    }

    function viewBlock(uint256 _blockId) public override view returns (string memory client, uint256 containers, string memory from, string memory to, uint256 estimatedTime) {
        require(_blockId < totalBlocks, "Block id out of range");
        BlockDetails storage supply = supplyblocks[_blockId];
        return (supply.client, supply.containers, supply.from, supply.to, supply.estimatedTime);
    }

    function supplyLength() public override view returns (string memory _details) {
        _details = string(abi.encodePacked("Total SupplyChain blocks are: ", toString(totalBlocks), "Thank You"));
        return _details;
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