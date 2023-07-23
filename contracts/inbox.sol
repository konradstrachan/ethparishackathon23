// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICallbackInbox {
    function registerContract(
        address contractAddress,
        bytes calldata preconditionalCallback,
        bytes calldata executionCallback
    ) external payable;

    function executeRegisteredCallback(address contractAddress) external;
}

contract Inbox is ICallbackInbox {
    event ContractRegistered(
        address indexed contractAddress,
        address indexed invoker,
        uint256 reward
    );

    event ContractExecuted(
        address indexed contractAddress,
        address indexed executor,
        uint256 rewardPaid
    );

    struct RegisteredContract {
        uint256 reward;
        bytes preconditionalCallback;
        bytes executionCallback;
        bool executed;
    }

    mapping(address => RegisteredContract) public registeredCallbacks;

    function registerContract(
        address contractAddress,
        bytes calldata preconditionalCallback,
        bytes calldata executionCallback
    ) external payable override {
        // IMPROVEMENT: use key based on address and hash of call data
        // to allow a contract to have multiple callbacks active
        require(
            msg.value > 100000,
            "Ether reward must be greater than minimum reward"
        );

        registeredCallbacks[contractAddress] = RegisteredContract(
            msg.value,
            preconditionalCallback,
            executionCallback,
            false
        );

        emit ContractRegistered(contractAddress, msg.sender, msg.value);
    }

    function isConstraintSatisfied(
        address contractAddress
    ) public returns (bool) {
        // TODO : Constrain nature of function to enable use of view decorator
        RegisteredContract storage contractInfo = registeredCallbacks[
            contractAddress
        ];

        if (contractInfo.executed == true) {
            return false;
        }
        
        (bool success, bytes memory preconditionData) = contractAddress.call(contractInfo.preconditionalCallback);

        if(success == false || preconditionData.length == 0){
            return false;
        }

        bool preconditionalState = abi.decode(preconditionData, (bool));
        return preconditionalState;
    }

    function executeRegisteredCallback(
        address contractAddress
    ) external override {
        RegisteredContract storage contractInfo = registeredCallbacks[
            contractAddress
        ];
        require(!contractInfo.executed, "Contract already executed");
        uint256 reward = contractInfo.reward;

        require(isConstraintSatisfied(contractAddress), "Contract preconditional failed");

        (bool success, ) = contractAddress.call(contractInfo.executionCallback);
        require(success, "Contract execution execution failed");

        contractInfo.executed = true;

        address payable executor = payable(msg.sender);
        executor.transfer(reward);

        emit ContractExecuted(contractAddress, executor, reward);
    }
}
