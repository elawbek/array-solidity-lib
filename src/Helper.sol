// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract Helper {
    function add(uint a, uint b) external pure returns (uint c) {
        c = a + b;
    }

    function sub(uint a, uint b) external pure returns (uint c) {
        c = a - b;
    }

    function mul(uint a, uint b) external pure returns (uint c) {
        c = a * b;
    }

    function div(uint a, uint b) external pure returns (uint c) {
        c = a / b;
    }

    function mod(uint a, uint b) external pure returns (uint c) {
        c = a % b;
    }

    function exp(uint a, uint b) external pure returns (uint c) {
        c = a ** b;
    }
}
