// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {console2, Test, stdStorage, StdStyle} from "forge-std/Test.sol";
import {Solarray} from "solarray/Solarray.sol";
import {Uint256Array, lt, lte, gt, gte, eq} from "src/Uint256Array.sol";

contract ArrayLibsTest is Test {
    using Uint256Array for *;

    Uint256Array.CustomArray private u256;

    function setUp() external {
        assembly {
            sstore(add(u256.slot, 0x01), keccak256(0x00, 0x20))
        }
    }

    function testUint256() external {
        uint256[] memory arr = Solarray.uint256s(
            type(uint8).max,
            type(uint16).max,
            type(uint24).max
        );

        uint256[] memory arr2 = Solarray.uint256s(
            type(uint32).max,
            type(uint40).max,
            type(uint48).max,
            type(uint56).max
        );

        console2.logString("push1");
        u256.push(arr[0]);
        logArray(u256, u256.length());

        console2.logString("push2");
        u256.push(arr[0], arr[1]);
        logArray(u256, u256.length());

        console2.logString("push3");
        u256.push(arr[0], arr[1], arr[2]);
        logArray(u256, u256.length());

        console2.logString("unshift1");
        u256.unshift(arr[0]);
        logArray(u256, u256.length());

        console2.logString("unshift2");
        u256.unshift(arr[0], arr[1]);
        logArray(u256, u256.length());

        console2.logString("unshift3");
        u256.unshift(arr[0], arr[1], arr[2]);
        logArray(u256, u256.length());

        console2.logString("shift");
        uint256 val = u256.shift();
        console2.logUint(val);
        logArray(u256, u256.length());

        console2.logString("pop");
        val = u256.pop();
        console2.logUint(val);
        logArray(u256, u256.length());

        console2.logString("concat");
        u256.concat(arr2);
        logArray(u256, u256.length());

        console2.logString("fill0");
        u256.fill(0);
        logArray(u256, u256.length());

        console2.logString("fill3 from 2");
        u256.fill(3, 2);
        logArray(u256, u256.length());

        console2.logString("fill10 from 5 to 9");
        u256.fill(10, 5, 10);
        logArray(u256, u256.length());

        console2.logString("update 4 and 9 and 12");
        u256.update(4, 2048);
        u256.update(-5, 2048);
        u256.update(-2, 2048);
        logArray(u256, u256.length());

        console2.logString("remove 4, 6");
        u256.remove(4);
        u256.remove(6);
        logArray(u256, u256.length());

        console2.logString("includes");
        console2.log(
            "Non-existent element from the whole array: ",
            u256.includes(1)
        );
        console2.log(
            "Non-existent element from 4 index: ",
            u256.includes(0, 4)
        );
        console2.log(
            "Non-existent element from 5 to 10 indexes: ",
            u256.includes(3, 5, 10)
        );
        console2.log("Element from the whole array :", u256.includes(2048));
        console2.log("Element from 8 index :", u256.includes(2048, 8));
        console2.log(
            "Element from 7 to 9 indexes :",
            u256.includes(2048, 7, 9)
        );
        console2.logString("----------------------------------------");

        console2.logString("indexOf");
        console2.log(
            "Non-existent element from the whole array: ",
            u256.indexOf(1)
        );
        console2.log("Non-existent element from 2 index: ", u256.indexOf(0, 4));
        console2.log(
            "Non-existent element from 5 to 10 indexes: ",
            u256.indexOf(3, 5, 10)
        );
        console2.log("Element from the whole array :", u256.indexOf(2048));
        console2.log("Element from 8 index :", u256.indexOf(2048, 8));
        console2.log("Element from 7 to 9 indexes :", u256.indexOf(2048, 7, 9));
        console2.logString("----------------------------------------");

        console2.logString("lastIndexOf");
        console2.log(
            "Non-existent element from the whole array: ",
            u256.lastIndexOf(1)
        );
        console2.log(
            "Non-existent element from 2 index: ",
            u256.lastIndexOf(0, 4)
        );
        console2.log(
            "Non-existent element from 5 to 10 indexes: ",
            u256.lastIndexOf(3, 5, 10)
        );
        console2.log("Element from the whole array :", u256.lastIndexOf(2048));
        console2.log("Element from 8 index :", u256.lastIndexOf(2048, 8));
        console2.log(
            "Element from 7 to 9 indexes :",
            u256.lastIndexOf(2048, 7, 9)
        );
        console2.logString("----------------------------------------");
    }

    function logArray(
        Uint256Array.CustomArray storage array,
        uint256 length
    ) private view {
        console2.log("length: ", length);

        int i;
        while (abs(i) < length) {
            console2.log("index: %s, elem: %s", abs(i), array.at(i));
            ++i;
        }
        console2.logString("----------------------------------------");
    }

    function abs(int value) private pure returns (uint256) {
        return value >= 0 ? uint256(value) : uint256(-value);
    }
}
