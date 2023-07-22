// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICallbackInbox {
    function registerContract(
        address contractAddress,
        bytes calldata data
    ) external payable;

    function executeRegisteredCallback(address contractAddress) external;

    function isConstraintSatisfied(
        address contractAddress
    ) external returns (bool);
}

contract Inbox is ICallbackInbox {
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
        bool constraintSatisfied;
    }

    mapping(address => RegisteredContract) public registeredCallbacks;

    function registerContract(
        address contractAddress,
        bytes calldata data
    ) external payable override {
        // IMPROVEMENT: use key based on address and hash of call data
        // to allow a contract to have multiple callbacks active
        require(
            msg.value > 100000,
            "Ether reward must be greater than minimum reward"
        );

        registeredCallbacks[contractAddress] = RegisteredContract(
            msg.value,
            data,
            false,
            true // IMPROVEMENT : make constraint based on block time or external check
        );

        emit ContractRegistered(contractAddress, msg.sender, msg.value, data);
    }

    function executeRegisteredCallback(
        address contractAddress
    ) external override {
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

    function isConstraintSatisfied(
        address contractAddress
    ) external view override returns (bool) {
        RegisteredContract storage contractInfo = registeredCallbacks[
            contractAddress
        ];
        return
            contractInfo.executed == false &&
            contractInfo.constraintSatisfied == true;
    }
}
