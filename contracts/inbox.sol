// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Inbox {
    event ContractRegistered(
        address indexed contractAddress,
        address indexed invoker,
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

    mapping(address => RegisteredContract) public registeredCallbacks;

    function registerContract(
        address contractAddress,
        bytes calldata data
    ) public payable {
        // IMPROVEMENT : use key based on address and hash of call data
        //               to allow a contract to have multiple callbacks active
        require(msg.value > 100000, "Ether reward must be greater than minimum reward");

        registeredCallbacks[contractAddress] = RegisteredContract(
            msg.value,
            data,
            false
        );

        emit ContractRegistered(contractAddress, msg.sender, msg.value, data);
    }

    function executeRegisteredContract(address contractAddress) public {
        RegisteredContract storage contractInfo = registeredCallbacks[
            contractAddress
        ];
        require(!contractInfo.executed, "Contract already executed");

        (bool success, ) = contractAddress.call(contractInfo.data);
        require(success, "Contract execution failed");

        contractInfo.executed = true;

        uint256 reward = contractInfo.reward;
        address payable executor = payable(msg.sender);
        executor.transfer(reward);

        emit ContractExecuted(contractAddress, executor, reward);
    }
}
