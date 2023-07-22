// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract ExampleContract {
    uint256 public data;

    function execute(uint256 newValue) public returns (bool) {
        data = newValue;
        return true;
    }
}
