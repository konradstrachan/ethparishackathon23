# Callhook ⚙️🪝

## Introduction

CallHook was created as a hackathon project during ETH Global Paris 2023 and is aimed at addressing a current limitation in smart contract programming on EVM (Ethereum Virtual Machine) networks. Currently, smart contracts can only be invoked by Externally Owned Accounts (EOA) transactions, meaning they lack the ability to initiate calls by themselves. This limitation hinders the adoption of event-driven architecture in smart contract development.

CallHook creates an economic incentive for external participants to trigger actions on behalf of smart contracts, enabling the implementation of event-driven architecture in the smart contract ecosystem. By introducing this capability, developers can design more sophisticated and flexible smart contracts that can autonomously interact with other contracts and external systems, leading to a more decentralized and efficient blockchain ecosystem.

### Example use cases

* Ticking computation based on updated data from oracles
* Contracts that automatically harvest yield from farming vaults
* Limit orders placed to be immediately based on price preconditions rather than sitting on a DEX revealing pricing strategy
* Triggering governance actions when DAO preconditions are met
* Automatically generating decentralised social graph content (i.e. Lenster posts) based on chain events
* ... any situation where a contract wishes to update state based on internal or external changes

## Features

## Technologies Used

* Solidity for smart contract development
* React, Hardhat, NextJS for rapid prototying and testing (via Scaffold-ETH 2)
* Celo, Neon, Linea, Gnosis, Mantle to deploying and experimenting with smart contracts

## Deployed contractrs

* Polygon zkEVM - 🚀🔗 https://testnet-zkevm.polygonscan.com/address/0x043383e00444f873B95D22db2D609d3355FD3Ff9#code
* Celo - 🚀🔗 https://alfajores.celoscan.io/address/0x043383e00444f873B95D22db2D609d3355FD3Ff9
* Neon - 🚀🔗 https://devnet.neonscan.org/address/0x043383e00444f873B95D22db2D609d3355FD3Ff9
* Linea - 🚀🔗 https://explorer.goerli.linea.build/address/0x043383e00444f873B95D22db2D609d3355FD3Ff9 (deployed via Infura)
* Gnosis - https://gnosis-chiado.blockscout.com/address/0xBEc49fA140aCaA83533fB00A2BB19bDdd0290f25
* Mantle - TBC

## Usage

The Inbox contract has the following main components:

* Interface: ICallbackInbox - Defines the functions that the contract must implement.
* Events: ContractRegistered and ContractExecuted - Used for emitting important contract events.
* Struct: RegisteredContract - Represents the details of a registered contract.
* Mapping: registeredCallbacks - Maps contract addresses to their corresponding RegisteredContract structs.
* Functions: registerContract, isConstraintSatisfied, and executeRegisteredCallback - The main functions to interact with the contract.

### Interface
```
interface ICallbackInbox {
    function registerContract(
        address contractAddress,
        bytes calldata preconditionalCallback,
        bytes calldata executionCallback
    ) external payable;

    function executeRegisteredCallback(address contractAddress) external;
}
```

The ICallbackInbox interface defines two functions that the contract must implement:

* registerContract: Allows an invoker to register a contract with the specified preconditional and execution callbacks, along with a reward in Ether.
executeRegisteredCallback: Allows anyone to execute a registered contract and claim the reward.

### Events

```
event ContractRegistered(
    address indexed contractAddress,
    address indexed invoker,
    uint256 reward
);
```

* contractAddress: The address of the registered contract.
* invoker: The address that invoked the registration of the contract.
* reward: The reward amount in Ether associated with the registered contract.

```
event ContractExecuted(
    address indexed contractAddress,
    address indexed executor,
    uint256 rewardPaid
);
```

* contractAddress: The address of the executed contract.
* executor: The address of the executor who claimed the reward.
* rewardPaid: The reward amount in Ether paid to the executor.

### Struct

```
struct RegisteredContract {
    uint256 reward;
    bytes preconditionalCallback;
    bytes executionCallback;
    bool executed;
}
```

* reward: The reward amount in Ether associated with the registered contract.
* preconditionalCallback: The callback function that must return a boolean value. If false, the contract cannot be executed.
* executionCallback: The callback function that will be executed when the contract is triggered.
* executed: A flag indicating whether the contract has been executed or not.

### Functions

#### registerContract
```
function registerContract(
    address contractAddress,
    bytes calldata preconditionalCallback,
    bytes calldata executionCallback
) external payable;
```

Allows an invoker to register a contract with the specified preconditional and execution callbacks, along with a reward in Ether.

* contractAddress: The address of the contract to be registered.
* preconditionalCallback: The callback function that must return a boolean value. If false, the contract cannot be executed.
* executionCallback: The callback function that will be executed when the contract is triggered.
* payable: The function requires a reward in Ether to be sent along with the registration.

#### isConstraintSatisfied

```
function isConstraintSatisfied(address contractAddress) public returns (bool);
```

Checks if the preconditional callback of a registered contract is satisfied.

* contractAddress: The address of the registered contract.
* Returns: true if the preconditional callback is satisfied, otherwise false.

#### executeRegisteredCallback

```
function executeRegisteredCallback(address contractAddress) external override;
```

Allows anyone to execute a registered contract and claim the reward.

* contractAddress: The address of the contract to be executed.

### Usage

To use the Inbox contract, you can deploy on any EVM blockchain (or use the pre-deployed contracts listed above) and interact with it using a web3-enabled Ethereum wallet or application.

* Register a contract by calling the registerContract function with the desired contract address, preconditional callback, execution callback, and the reward amount in Ether.
* To execute a registered contract, call the executeRegisteredCallback function with the address of the contract to be executed.
* Please note that you must have sufficient Ether to register a contract and claim the reward.

## Example

Below is the example counter.sol contract which demonstrates how a contract programatically registers for async execution.

```
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

contract Counter {
    uint256 public counter;
    ICallbackInbox private inbox;
    uint256 public lastCallBlock;

    constructor(address payable _inbox) {
        counter = 0;
        inbox = ICallbackInbox(_inbox);
        lastCallBlock = block.number;
    }

    function preconditionSatisfied() public view returns (bool) {
        return block.number > lastCallBlock + 2;
    }

    function resetNumber() public {
        counter = 0;
    }

    function incrementCounter() public payable {
        require(preconditionSatisfied(), "Precondition not satisfied");
        
        counter += 1;
        lastCallBlock = block.number;

        bytes memory preconditional = abi.encodeCall(this.preconditionSatisfied,());
        bytes memory callback = abi.encodeCall(this.resetNumber,());
        inbox.registerContract{value:msg.value}(address(this), preconditional, callback);
    }
}

```

# Key Features

* **Event-driven Architecture**: CallHook enables smart contracts to initiate actions in response to events or specific conditions, promoting event-driven programming on EVM networks

* **Decentralized and Trustless**: CallHook system operates in a decentralized manner, ensuring security, transparency, and trustlessness in executing actions on behalf of smart contracts

* **Incentivization**: External participants are incentivized to trigger actions for registered contracts, creating a self-sustaining ecosystem where participants are rewarded for their actions

* **Flexibility**: Smart contract developers have the flexibility to programatically define the events or conditions that should trigger actions, allowing for dynamic and adaptable contract behavior

* **Enhanced DApp Functionality**: DApps can leverage CallHook to create more sophisticated and autonomous smart contracts, reducing the reliance on external systems and manual intervention.

## Contributing
Contributions to CallHook are welcome! If you have any ideas, suggestions, or bug fixes, please submit an issue or pull request to the CallHook GitHub repository.

## License
CallHook is released under the MIT License. You are free to use, modify, and distribute this project in accordance with the terms specified in the license.