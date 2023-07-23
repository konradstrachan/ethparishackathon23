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
