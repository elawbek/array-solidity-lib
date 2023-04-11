// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {Uint256Array} from "src/Uint256Array.sol";

contract ArrayLibsTest {
    using Uint256Array for *;

    Uint256Array.CustomArray private c256;

    function setUp() external {
        assembly {
            sstore(add(c256.slot, 0x01), keccak256(0x00, 0x20))
        }
    }

    function testUint256() external {
        c256.push(type(uint8).max);
        console2.log(StdStyle.red(c256.at(0)));
        console2.log(StdStyle.red(c256.length()));

        c256.unshift(type(uint16).max);
        console2.log(StdStyle.green(c256.at(0)));
        console2.log(StdStyle.green(c256.at(-1)));
        console2.log(StdStyle.green(c256.length()));

        c256.shift();
        console2.log(StdStyle.blue(c256.at(0)));
        console2.log(StdStyle.blue(c256.length()));

        c256.pop();
        console2.log(StdStyle.magenta(c256.length()));

        uint256[] memory arr = new uint256[](4);
        arr[0] = type(uint8).max;
        arr[1] = type(uint16).max;
        arr[2] = type(uint24).max;
        arr[3] = type(uint32).max;

        c256.concat(arr);
        console2.log(StdStyle.cyan(c256.at(0)));
        console2.log(StdStyle.cyan(c256.at(-3)));
        console2.log(StdStyle.cyan(c256.at(2)));
        console2.log(StdStyle.cyan(c256.at(-1)));
        console2.log(StdStyle.cyan(c256.length()));

        c256.fill(2);
        console2.log(StdStyle.bold(c256.at(0)));
        console2.log(StdStyle.bold(c256.at(-3)));
        console2.log(StdStyle.bold(c256.at(2)));
        console2.log(StdStyle.bold(c256.at(-1)));
        console2.log(StdStyle.bold(c256.length()));

        c256.fill(3, 2);
        console2.log(StdStyle.dim(c256.at(0)));
        console2.log(StdStyle.dim(c256.at(-3)));
        console2.log(StdStyle.dim(c256.at(2)));
        console2.log(StdStyle.dim(c256.at(-1)));
        console2.log(StdStyle.dim(c256.length()));

        c256.fill(4, 0, 1);
        console2.log(StdStyle.italic(c256.at(0)));
        console2.log(StdStyle.italic(c256.at(-3)));
        console2.log(StdStyle.italic(c256.at(2)));
        console2.log(StdStyle.italic(c256.at(-1)));
        console2.log(StdStyle.italic(c256.length()));

        c256.fill(5, 1, 1);
        console2.log(StdStyle.italic(c256.at(0)));
        console2.log(StdStyle.italic(c256.at(-3)));
        console2.log(StdStyle.italic(c256.at(2)));
        console2.log(StdStyle.italic(c256.at(-1)));
        console2.log(StdStyle.italic(c256.length()));
    }
}
