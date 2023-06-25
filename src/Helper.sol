// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract Helper {
    function add(uint256 a, uint256 b) external pure returns (uint256 c) {
        c = a + b;
    }

    function sub(uint256 a, uint256 b) external pure returns (uint256 c) {
        c = a - b;
    }

    function mul(uint256 a, uint256 b) external pure returns (uint256 c) {
        c = a * b;
    }

    function div(uint256 a, uint256 b) external pure returns (uint256 c) {
        c = a / b;
    }

    function mod(uint256 a, uint256 b) external pure returns (uint256 c) {
        c = a % b;
    }

    function exp(uint256 a, uint256 b) external pure returns (uint256 c) {
        c = a ** b;
    }
}
