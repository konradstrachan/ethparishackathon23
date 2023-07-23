// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICallbackInbox {
    function registerContract(address contractAddress, bytes calldata data) external payable;
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

    function incrementCounter() public payable {
        require(block.number > lastCallBlock + 2, "Function can only be called every 10 blocks");
        counter += 1;
        lastCallBlock = block.number;

        bytes memory callback = abi.encodeCall(this.incrementCounter,());
        inbox.registerContract{value:msg.value}(address(this), callback);
    }
}
