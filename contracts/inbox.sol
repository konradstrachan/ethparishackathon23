// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract Inbox {
    event ContractRegistered(
        address indexed contractAddress,
        address indexed owner,
        uint256 reward,
        bytes data
    );
    event ContractExecuted(
        address indexed contractAddress,
        address indexed executor,
        uint256 rewardPaid
    );

    event RewardClaimed(address indexed executor, uint256 rewardPaid);

    struct RegisteredContract {
        uint256 reward;
        bytes data;
        bool executed;
    }

    mapping(address => RegisteredContract) public registeredContracts;

    function registerContract(
        address contractAddress,
        uint256 reward,
        bytes calldata data
    ) public payable {
        require(
            !registeredContracts[contractAddress].executed,
            "Contract already executed"
        );
        require(reward > 0, "Reward must be greater than 0");

        registeredContracts[contractAddress] = RegisteredContract(
            reward,
            data,
            false
        );

        address(this).transfer(reward);
        emit ContractRegistered(contractAddress, msg.sender, reward, data);
    }

    function executeRegisteredContract(address contractAddress) public {
        RegisteredContract storage contractInfo = registeredContracts[
            contractAddress
        ];
        require(!contractInfo.executed, "Contract already executed");

        (bool success, ) = contractAddress.call(contractInfo.data);
        require(success, "Contract execution failed");

        contractInfo.executed = true;

        uint256 reward = contractInfo.reward;
        address executor = msg.sender;

        emit ContractExecuted(contractAddress, executor, reward);
    }
}
