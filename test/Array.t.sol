// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {Array, CustomArrayUint256, CustomArrayUint128, CustomArrayUint88, CustomArrayUint72} from "src/Array.sol";

contract FixMathTest is Test {
    using Array for CustomArrayUint256;
    using Array for CustomArrayUint128;
    using Array for CustomArrayUint88;
    using Array for CustomArrayUint72;

    /* initial values 
    struct CustomArray {
        uint256 length; 0
        uint256 slot;   0
        _type
    }
    */
    CustomArrayUint256 private a256;
    CustomArrayUint128 private a128;
    CustomArrayUint88 private a88;
    CustomArrayUint72 private a72;

    function setUp() external {
        assembly {
            sstore(add(a256.slot, 0x01), keccak256(0x00, 0x20))
            mstore(0x00, 0x01)
            sstore(add(a128.slot, 0x01), keccak256(0x00, 0x20))
            mstore(0x00, 0x02)
            sstore(add(a88.slot, 0x01), keccak256(0x00, 0x20))
            mstore(0x00, 0x03)
            sstore(add(a72.slot, 0x01), keccak256(0x00, 0x20))
        }
    }

    function test() external {
        // a72.push(1);
        // a72.push(2);
        // a72.push(3);
        // a72.push(4);

        // console2.log(a72.at(0));
        // console2.log(a72.at(1));
        // console2.log(a72.at(2));
        // console2.log(a72.at(3));

        a72.unshift(type(uint72).max);
        a72.unshift(type(uint8).max);
        a72.unshift(type(uint16).max);
        a72.unshift(type(uint24).max);
        console2.log(a72.at(0));
        console2.log(a72.at(1));
        console2.log(a72.at(-2));
        console2.log(a72.at(-1));
    }
}
