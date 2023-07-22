// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICallbackInbox {
    function registerContract(address contractAddress, bytes calldata data) external payable;
    function executeRegisteredCallback(address contractAddress) external;
}

contract SimpleCounter {
    uint256 public counter;
    ICallbackInbox private inbox;
    uint256 public lastCallBlock;

    constructor(address payable _inbox) {
        counter = 0;
        inbox = ICallbackInbox(_inbox);
        lastCallBlock = block.number;
    }

    function incrementCounter(uint256 amount) public payable {
        require(block.number > lastCallBlock + 10, "Function can only be called every 10 blocks");
        counter += amount;
        lastCallBlock = block.number;

        bytes memory callback = abi.encodeWithSignature("executeRegisteredCallback(address)", address(this));
        inbox.registerContract(address(this), callback);
    }
}
