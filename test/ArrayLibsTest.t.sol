// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {console2, Test, stdStorage, StdStyle} from "forge-std/Test.sol";
import {Solarray} from "solarray/Solarray.sol";
import {Uint256Array, lt, lte, gt, gte, eq, add, sub, mul, div, mod, pow, xor} from "src/Uint256Array.sol";

contract ArrayLibsTest is Test {
    using Uint256Array for *;

    Uint256Array.CustomArray private u256;

    function setUp() external {
        assembly {
            sstore(add(u256.slot, 0x01), keccak256(0x00, 0x20))
        }
    }

    function testLength() external {
        u256.push(1);
        assertEq(u256.length(), 1);

        u256.unshift(2);
        assertEq(u256.length(), 2);

        u256.pop();
        assertEq(u256.length(), 1);

        u256.shift();
        assertEq(u256.length(), 0);
    }

    function testAt() external {
        uint256[] memory expectedArray = Solarray.uint256s(
            type(uint8).max,
            type(uint16).max,
            type(uint24).max,
            type(uint32).max
        );
        u256.concat(expectedArray);

        uint256[] memory arr = new uint256[](expectedArray.length);

        int256 index;
        for (uint256 i; i < arr.length; ++i) {
            arr[i] = u256.at(index);
            ++index;
        }

        assertArray(arr, expectedArray);

        expectedArray = Solarray.uint256s(
            type(uint32).max,
            type(uint24).max,
            type(uint16).max,
            type(uint8).max
        );

        index = -1;
        for (uint256 i; i < arr.length; ++i) {
            arr[i] = u256.at(index);
            --index;
        }

        assertArray(arr, expectedArray);
    }

    function testArray() external {
        uint256[] memory expectedArray;

        // Empty array
        assertArray(u256.array(), expectedArray);

        expectedArray = Solarray.uint256s(
            type(uint40).max,
            type(uint48).max,
            type(uint56).max,
            type(uint64).max
        );
        u256.concat(expectedArray);

        // Full array
        assertArray(u256.array(), expectedArray);

        // From 2nd index to end of array
        expectedArray = Solarray.uint256s(type(uint56).max, type(uint64).max);
        assertArray(u256.array(2), expectedArray);

        // From 1st to 2nd index
        expectedArray = Solarray.uint256s(type(uint48).max, type(uint56).max);
        assertArray(u256.array(1, 2), expectedArray);
    }

    function testPush() external {
        uint256[] memory expectedArray;

        expectedArray = Solarray.uint256s(type(uint72).max);
        // Push one element
        u256.push(type(uint72).max);
        assertArray(u256.array(), expectedArray);

        expectedArray = Solarray.uint256s(
            type(uint72).max,
            type(uint80).max,
            type(uint88).max
        );
        // Push two elements
        u256.push(type(uint80).max, type(uint88).max);
        assertArray(u256.array(), expectedArray);

        expectedArray = Solarray.uint256s(
            type(uint72).max,
            type(uint80).max,
            type(uint88).max,
            type(uint96).max,
            type(uint104).max,
            type(uint112).max
        );
        // Push three elements
        u256.push(type(uint96).max, type(uint104).max, type(uint112).max);
        assertArray(u256.array(), expectedArray);
    }

    function testUnshift() external {
        uint256[] memory expectedArray;

        expectedArray = Solarray.uint256s(type(uint72).max);
        // Push one element
        u256.unshift(type(uint72).max);
        assertArray(u256.array(), expectedArray);

        expectedArray = Solarray.uint256s(
            type(uint80).max,
            type(uint88).max,
            type(uint72).max
        );
        // Push two elements
        u256.unshift(type(uint80).max, type(uint88).max);
        assertArray(u256.array(), expectedArray);

        expectedArray = Solarray.uint256s(
            type(uint96).max,
            type(uint104).max,
            type(uint112).max,
            type(uint80).max,
            type(uint88).max,
            type(uint72).max
        );
        // Push three elements
        u256.unshift(type(uint96).max, type(uint104).max, type(uint112).max);
        assertArray(u256.array(), expectedArray);
    }

    function testConcat() external {
        uint256[] memory expectedArray;

        expectedArray = Solarray.uint256s(type(uint120).max, type(uint128).max);
        // Concat two elements
        u256.concat(expectedArray);
        assertArray(u256.array(), expectedArray);

        // Concat another two elements
        expectedArray = Solarray.uint256s(type(uint136).max, type(uint144).max);
        u256.concat(expectedArray);

        expectedArray = Solarray.uint256s(
            type(uint120).max,
            type(uint128).max,
            type(uint136).max,
            type(uint144).max
        );

        assertArray(u256.array(), expectedArray);
    }

    function testPopAndShift() external {
        uint256[] memory expectedArray;

        expectedArray = Solarray.uint256s(
            type(uint152).max,
            type(uint160).max,
            type(uint168).max,
            type(uint176).max
        );
        u256.concat(expectedArray);

        uint256 expectedValue = expectedArray[3];

        expectedArray = Solarray.uint256s(
            type(uint152).max,
            type(uint160).max,
            type(uint168).max
        );

        // pop
        assertEq(u256.pop(), expectedValue);
        assertArray(u256.array(), expectedArray);

        // shift
        expectedValue = expectedArray[0];
        expectedArray = Solarray.uint256s(type(uint160).max, type(uint168).max);

        assertEq(u256.shift(), expectedValue);
        assertArray(u256.array(), expectedArray);
    }

    function testUpdate() external {
        uint256[] memory expectedArray;

        expectedArray = Solarray.uint256s(
            type(uint184).max,
            type(uint192).max,
            type(uint200).max,
            type(uint208).max
        );
        u256.concat(expectedArray);

        expectedArray = Solarray.uint256s(
            type(uint184).max,
            type(uint8).max,
            type(uint200).max,
            type(uint208).max
        );

        // update 1st index to type(uint8).max
        u256.update(1, type(uint8).max);
        assertArray(u256.array(), expectedArray);

        expectedArray = Solarray.uint256s(
            type(uint184).max,
            type(uint8).max,
            type(uint16).max,
            type(uint208).max
        );

        // update -2nd index to type(uint16).max
        u256.update(-2, type(uint16).max);
        assertArray(u256.array(), expectedArray);
    }

    function testRemove() external {
        uint256[] memory expectedArray;

        expectedArray = Solarray.uint256s(
            type(uint216).max,
            type(uint224).max,
            type(uint232).max,
            type(uint240).max
        );
        u256.concat(expectedArray);

        expectedArray = Solarray.uint256s(
            type(uint216).max,
            type(uint240).max,
            type(uint232).max
        );

        // remove 1st index
        u256.remove(1);
        assertArray(u256.array(), expectedArray);

        expectedArray = Solarray.uint256s(type(uint216).max, type(uint232).max);

        // remove -2nd index
        u256.remove(-2);
        assertArray(u256.array(), expectedArray);
    }

    function testIncludes() external {
        uint256[] memory expectedArray;

        expectedArray = Solarray.uint256s(
            type(uint248).max,
            type(uint256).max,
            type(uint8).max,
            type(uint16).max
        );
        u256.concat(expectedArray);

        // includes in all array
        assertTrue(u256.includes(type(uint248).max));
        assertTrue(u256.includes(type(uint256).max));
        assertTrue(u256.includes(type(uint8).max));
        assertTrue(u256.includes(type(uint16).max));
        assertFalse(u256.includes(1));

        // includes from 2nd index to end
        assertFalse(u256.includes(type(uint248).max, 2));
        assertFalse(u256.includes(type(uint256).max, 2));
        assertTrue(u256.includes(type(uint8).max, 2));
        assertTrue(u256.includes(type(uint16).max, 2));
        assertFalse(u256.includes(1, 2));

        // includes from 1st index to 2nd
        assertFalse(u256.includes(type(uint248).max, 1, 2));
        assertTrue(u256.includes(type(uint256).max, 1, 2));
        assertTrue(u256.includes(type(uint8).max, 1, 2));
        assertFalse(u256.includes(type(uint16).max, 1, 2));
        assertFalse(u256.includes(1, 1, 2));
    }

    // TODO return the modified array instead of rewrite state
    function testFill() external {
        uint256[] memory expectedArray;

        expectedArray = Solarray.uint256s(
            type(uint24).max,
            type(uint32).max,
            type(uint40).max,
            type(uint48).max
        );
        u256.concat(expectedArray);
    }

    function testIndexOfAndLastIndexOf() external {
        uint256[] memory expectedArray;

        expectedArray = Solarray.uint256s(
            type(uint56).max,
            type(uint64).max,
            type(uint64).max,
            type(uint56).max
        );
        u256.concat(expectedArray);

        // find index in all array
        assertEq(u256.indexOf(type(uint56).max), 0);
        assertEq(u256.indexOf(type(uint64).max), 1);
        assertEq(u256.lastIndexOf(type(uint56).max), 3);
        assertEq(u256.lastIndexOf(type(uint64).max), 2);

        // find index from 1st index to the of end array
        assertEq(u256.indexOf(type(uint56).max, 1), 3);
        assertEq(u256.indexOf(type(uint64).max, 1), 1);
        assertEq(u256.lastIndexOf(type(uint56).max, 1), 3);
        assertEq(u256.lastIndexOf(type(uint64).max, 1), 2);

        // find index from 1st index to 2nd
        assertEq(u256.indexOf(type(uint56).max, 1, 2), -1);
        assertEq(u256.indexOf(type(uint64).max, 1, 2), 1);
        assertEq(u256.lastIndexOf(type(uint56).max, 1, 2), -1);
        assertEq(u256.lastIndexOf(type(uint64).max, 1, 2), 2);
    }

    function testFilter() external {
        uint256[] memory expectedArray;

        expectedArray = Solarray.uint256s(
            type(uint72).max,
            type(uint80).max,
            type(uint88).max,
            type(uint96).max,
            type(uint104).max,
            type(uint112).max
        );
        u256.concat(expectedArray);

        // filter lt uint104 in all array
        expectedArray = Solarray.uint256s(
            type(uint72).max,
            type(uint80).max,
            type(uint88).max,
            type(uint96).max
        );
        assertArray(u256.filter(lt, type(uint104).max), expectedArray);

        // filter lt uint104 in array from 3rd index to the end
        expectedArray = Solarray.uint256s(type(uint96).max);
        assertArray(u256.filter(lt, type(uint104).max, 3), expectedArray);

        // filter lt uint104 in array from 2nd index to 4th
        expectedArray = Solarray.uint256s(type(uint88).max, type(uint96).max);
        assertArray(u256.filter(lt, type(uint104).max, 2, 4), expectedArray);

        // filter gt uint88 in all array
        expectedArray = Solarray.uint256s(
            type(uint96).max,
            type(uint104).max,
            type(uint112).max
        );
        assertArray(u256.filter(gt, type(uint88).max), expectedArray);

        // filter gt uint88 in array from 4th index to the end
        expectedArray = Solarray.uint256s(type(uint104).max, type(uint112).max);
        assertArray(u256.filter(gt, type(uint88).max, 4), expectedArray);

        // filter gt uint88 in array from 0 index to 2th
        assembly {
            mstore(expectedArray, 0x00)
        }
        assertArray(u256.filter(gt, type(uint88).max, 0, 2), expectedArray);
    }

    function testFindAndFindLast() external {
        uint256[] memory expectedArray;

        expectedArray = Solarray.uint256s(
            type(uint120).max,
            type(uint128).max,
            type(uint136).max,
            type(uint144).max,
            type(uint136).max,
            type(uint128).max,
            type(uint120).max
        );
        u256.concat(expectedArray);

        expectedArray = Solarray.uint256s(type(uint136).max);
        // find elem eq uint136 in all array
        assertArray(u256.find(eq, type(uint136).max), expectedArray);
        assertArray(u256.findLast(eq, type(uint136).max), expectedArray);

        // find elem eq uint136 in array from 3rd index to the end
        assertArray(u256.find(eq, type(uint136).max, 3), expectedArray);
        assertArray(u256.findLast(eq, type(uint136).max, 3), expectedArray);

        // find elem eq uint136 in array from 5th index to 6th
        assembly {
            mstore(expectedArray, 0x00)
        }
        assertArray(u256.find(eq, type(uint136).max, 5, 6), expectedArray);
        assertArray(u256.findLast(eq, type(uint136).max, 5, 6), expectedArray);
    }

    function testFindIndexAndFindLastIndex() external {
        uint256[] memory expectedArray;

        expectedArray = Solarray.uint256s(
            type(uint152).max,
            type(uint160).max,
            type(uint168).max,
            type(uint176).max,
            type(uint168).max,
            type(uint160).max,
            type(uint152).max
        );
        u256.concat(expectedArray);

        // find elem gte uint160 in all array
        assertEq(u256.findIndex(gte, type(uint160).max), 1);
        assertEq(u256.findLastIndex(gte, type(uint160).max), 5);

        // find elem gte uint160 in array from 3rd index to the end
        assertEq(u256.findIndex(gte, type(uint160).max, 3), 3);
        assertEq(u256.findLastIndex(gte, type(uint160).max, 3), 5);

        // find elem gte uint160 in array from 5th index to 6th
        assertEq(u256.findIndex(gte, type(uint160).max, 5, 6), 5);
        assertEq(u256.findLastIndex(gte, type(uint160).max, 5, 6), 5);

        // // find elem lte uint176 in all array
        assertEq(u256.findIndex(lte, type(uint176).max), 0);
        assertEq(u256.findLastIndex(lte, type(uint176).max), 6);

        // // find elem lte uint176 in array from 3rd index to the end
        assertEq(u256.findIndex(lte, type(uint176).max, 3), 3);
        assertEq(u256.findLastIndex(lte, type(uint176).max, 3), 6);

        // // find elem lte uint176 in array from 5th index to 6th
        assertEq(u256.findIndex(lte, type(uint176).max, 5, 6), 5);
        assertEq(u256.findLastIndex(lte, type(uint176).max, 5, 6), 6);
    }

    function testMap() external {
        uint256[] memory expectedArray;

        expectedArray = Solarray.uint256s(
            type(uint184).max,
            type(uint192).max,
            type(uint200).max,
            type(uint208).max,
            type(uint216).max,
            type(uint224).max,
            type(uint232).max
        );
        u256.concat(expectedArray);
    }

    function assertArray(
        uint256[] memory arr,
        uint256[] memory expectedArray
    ) private {
        logArray(arr);

        assertEq(arr.length, expectedArray.length);

        for (uint256 i; i < arr.length; ++i) {
            assertEq(arr[i], expectedArray[i]);
        }
    }

    function logArray(uint256[] memory array) private view {
        console2.log("length: ", array.length);

        uint256 i;
        while (i < array.length) {
            console2.log("index: %s, elem: %s", i, array[i]);
            ++i;
        }
        console2.logString("----------------------------------------");
    }
}
