// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {console2, Test} from "forge-std/Test.sol";
import {Solarray} from "solarray/Solarray.sol";
import {Uint256Array, lt, lte, gt, gte, eq, add, sub, mul, div, mod, pow, xor} from "src/Uint256Array.sol";
import {RevertTesterHelperU256} from "./RevertTesterHelperU256.sol";

contract Uint256ArrayLibTests is Test {
    using Uint256Array for *;

    Uint256Array.CustomArray private u256;
    RevertTesterHelperU256 private revertHelper;

    function setUp() external {
        assembly {
            sstore(add(u256.slot, 0x01), keccak256(0x00, 0x20))
        }
        revertHelper = new RevertTesterHelperU256();
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
        assertArray(u256.slice(), expectedArray);

        expectedArray = Solarray.uint256s(
            type(uint40).max,
            type(uint48).max,
            type(uint56).max,
            type(uint64).max
        );
        u256.concat(expectedArray);

        // Full array
        assertArray(u256.slice(), expectedArray);

        // From 2nd index to end of array
        expectedArray = Solarray.uint256s(type(uint56).max, type(uint64).max);
        assertArray(u256.slice(2), expectedArray);

        // From 1st to 2nd index
        expectedArray = Solarray.uint256s(type(uint48).max, type(uint56).max);
        assertArray(u256.slice(1, 2), expectedArray);
    }

    function testPush() external {
        uint256[] memory expectedArray;

        expectedArray = Solarray.uint256s(type(uint72).max);
        // Push one element
        u256.push(type(uint72).max);
        assertArray(u256.slice(), expectedArray);

        expectedArray = Solarray.uint256s(
            type(uint72).max,
            type(uint80).max,
            type(uint88).max
        );
        // Push two elements
        u256.push(type(uint80).max, type(uint88).max);
        assertArray(u256.slice(), expectedArray);

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
        assertArray(u256.slice(), expectedArray);
    }

    function testUnshift() external {
        uint256[] memory expectedArray;

        expectedArray = Solarray.uint256s(type(uint72).max);
        // Push one element
        u256.unshift(type(uint72).max);
        assertArray(u256.slice(), expectedArray);

        expectedArray = Solarray.uint256s(
            type(uint80).max,
            type(uint88).max,
            type(uint72).max
        );
        // Push two elements
        u256.unshift(type(uint80).max, type(uint88).max);
        assertArray(u256.slice(), expectedArray);

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
        assertArray(u256.slice(), expectedArray);
    }

    function testConcat() external {
        uint256[] memory expectedArray;

        expectedArray = Solarray.uint256s(type(uint120).max, type(uint128).max);
        // Concat two elements
        u256.concat(expectedArray);
        assertArray(u256.slice(), expectedArray);

        // Concat another two elements
        expectedArray = Solarray.uint256s(type(uint136).max, type(uint144).max);
        u256.concat(expectedArray);

        expectedArray = Solarray.uint256s(
            type(uint120).max,
            type(uint128).max,
            type(uint136).max,
            type(uint144).max
        );

        assertArray(u256.slice(), expectedArray);
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
        assertArray(u256.slice(), expectedArray);

        // shift
        expectedValue = expectedArray[0];
        expectedArray = Solarray.uint256s(type(uint160).max, type(uint168).max);

        assertEq(u256.shift(), expectedValue);
        assertArray(u256.slice(), expectedArray);
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
        assertArray(u256.slice(), expectedArray);

        expectedArray = Solarray.uint256s(
            type(uint184).max,
            type(uint8).max,
            type(uint16).max,
            type(uint208).max
        );

        // update -2nd index to type(uint16).max
        u256.update(-2, type(uint16).max);
        assertArray(u256.slice(), expectedArray);
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
        assertArray(u256.slice(), expectedArray);

        expectedArray = Solarray.uint256s(type(uint216).max, type(uint232).max);

        // remove -2nd index
        u256.remove(-2);
        assertArray(u256.slice(), expectedArray);
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

    function testFillState() external {
        uint256[] memory expectedArray;

        expectedArray = Solarray.uint256s(
            type(uint24).max,
            type(uint32).max,
            type(uint40).max,
            type(uint48).max
        );
        u256.concat(expectedArray);

        // fill all array by 2
        expectedArray = Solarray.uint256s(2, 2, 2, 2);
        u256.fillState(2);
        assertArray(u256.slice(), expectedArray);

        // fill array from 2nd index to the end by 10000
        expectedArray = Solarray.uint256s(2, 2, 10000, 10000);
        u256.fillState(10000, 2);
        assertArray(u256.slice(), expectedArray);

        // fill array from 1st index to 2nd by 100
        expectedArray = Solarray.uint256s(2, 100, 100, 10000);
        u256.fillState(100, 1, 2);
        assertArray(u256.slice(), expectedArray);
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

    error Overflow();
    error Underflow();
    error DivisionByZero();

    function testMap() external {
        uint256[] memory expectedArray;

        expectedArray = Solarray.uint256s(11, 22, 33, 44, 55, 66, 77);
        u256.concat(expectedArray);

        // map through all array and add, sub, mul, div, pow, xor every elem by 5
        (
            uint256[] memory _add,
            uint256[] memory _sub,
            uint256[] memory _mul,
            uint256[] memory _div,
            uint256[] memory _mod,
            uint256[] memory _pow,
            uint256[] memory _xor
        ) = helper(expectedArray, 5, 0, 7);
        assertArray(u256.map(add, 5), _add);
        assertArray(u256.map(sub, 5), _sub);
        assertArray(u256.map(mul, 5), _mul);
        assertArray(u256.map(div, 5), _div);
        assertArray(u256.map(mod, 5), _mod);
        assertArray(u256.map(pow, 5), _pow);
        assertArray(u256.map(xor, 5), _xor);

        // map through array from 4th index to the end and add, sub, mul, div, pow, xor every elem by 5
        (_add, _sub, _mul, _div, _mod, _pow, _xor) = helper(
            expectedArray,
            5,
            4,
            3
        );
        assertArray(u256.map(add, 5, 4), _add);
        assertArray(u256.map(sub, 5, 4), _sub);
        assertArray(u256.map(mul, 5, 4), _mul);
        assertArray(u256.map(div, 5, 4), _div);
        assertArray(u256.map(mod, 5, 4), _mod);
        assertArray(u256.map(pow, 5, 4), _pow);
        assertArray(u256.map(xor, 5, 4), _xor);

        // map through array from 2nd index to 5th and add, sub, mul, div, pow, xor every elem by 5
        (_add, _sub, _mul, _div, _mod, _pow, _xor) = helper(
            expectedArray,
            5,
            2,
            4
        );
        assertArray(u256.map(add, 5, 2, 5), _add);
        assertArray(u256.map(sub, 5, 2, 5), _sub);
        assertArray(u256.map(mul, 5, 2, 5), _mul);
        assertArray(u256.map(div, 5, 2, 5), _div);
        assertArray(u256.map(mod, 5, 2, 5), _mod);
        assertArray(u256.map(pow, 5, 2, 5), _pow);
        assertArray(u256.map(xor, 5, 2, 5), _xor);
    }

    function testReverts() external {
        vm.expectRevert(Overflow.selector);
        revertHelper.tstAdd(type(uint256).max);

        vm.expectRevert(Underflow.selector);
        revertHelper.tstSub(type(uint256).max);

        vm.expectRevert(Overflow.selector);
        revertHelper.tstMul(type(uint256).max);

        vm.expectRevert(DivisionByZero.selector);
        revertHelper.tstDiv(0);

        vm.expectRevert(DivisionByZero.selector);
        revertHelper.tstMod(0);

        vm.expectRevert(Overflow.selector);
        revertHelper.tstPow(type(uint16).max);
    }

    function testForEach() external {
        uint256[] memory expectedArray;
        uint256[] memory _add;
        uint256[] memory _sub;
        uint256[] memory _mul;
        uint256[] memory _div;
        uint256[] memory _mod;
        uint256[] memory _pow;
        uint256[] memory _xor;

        expectedArray = Solarray.uint256s(11, 22, 33, 44, 55, 66, 77);
        u256.concat(expectedArray);

        // iterate through all array and add, sub, mul, div, pow, xor every elem by 3
        (_add, , , , , , ) = helper(u256.slice(), 3, 0, 7);
        u256.forEach(add, 3);
        assertArray(u256.slice(), _add);

        (, _sub, , , , , ) = helper(u256.slice(), 3, 0, 7);
        u256.forEach(sub, 3);
        assertArray(u256.slice(), _sub);

        (, , _mul, , , , ) = helper(u256.slice(), 3, 0, 7);
        u256.forEach(mul, 3);
        assertArray(u256.slice(), _mul);

        (, , , _div, , , ) = helper(u256.slice(), 3, 0, 7);
        u256.forEach(div, 3);
        assertArray(u256.slice(), _div);

        (, , , , _mod, , ) = helper(u256.slice(), 3, 0, 7);
        u256.forEach(mod, 3);
        assertArray(u256.slice(), _mod);

        u256.forEach(add, 11);

        (, , , , , _pow, ) = helper(u256.slice(), 3, 0, 7);
        u256.forEach(pow, 3);
        assertArray(u256.slice(), _pow);

        (, , , , , , _xor) = helper(u256.slice(), 3, 0, 7);
        u256.forEach(xor, 3);
        assertArray(u256.slice(), _xor);

        // iterate through array from 4th index to the end and add, sub, mul, div, pow, xor every elem by 5
        (_add, , , , , , ) = helper(u256.slice(4), 5, 0, 3);
        u256.forEach(add, 5, 4);
        assertArray(u256.slice(4), _add);

        (, _sub, , , , , ) = helper(u256.slice(4), 5, 0, 3);
        u256.forEach(sub, 5, 4);
        assertArray(u256.slice(4), _sub);

        (, , _mul, , , , ) = helper(u256.slice(4), 5, 0, 3);
        u256.forEach(mul, 5, 4);
        assertArray(u256.slice(4), _mul);

        (, , , _div, , , ) = helper(u256.slice(4), 5, 0, 3);
        u256.forEach(div, 5, 4);
        assertArray(u256.slice(4), _div);

        (, , , , _mod, , ) = helper(u256.slice(4), 5, 0, 3);
        u256.forEach(mod, 5, 4);
        assertArray(u256.slice(4), _mod);

        u256.forEach(add, 41);

        (, , , , , _pow, ) = helper(u256.slice(4), 5, 0, 3);
        u256.forEach(pow, 5, 4);
        assertArray(u256.slice(4), _pow);

        (, , , , , , _xor) = helper(u256.slice(4), 5, 0, 3);
        u256.forEach(xor, 5, 4);
        assertArray(u256.slice(4), _xor);

        // iterate through array from 1st index to 4th and add, sub, mul, div, pow, xor every elem by 2
        (_add, , , , , , ) = helper(u256.slice(1, 4), 2, 0, 4);
        u256.forEach(add, 2, 1, 4);
        assertArray(u256.slice(1, 4), _add);

        (, _sub, , , , , ) = helper(u256.slice(1, 4), 2, 0, 4);
        u256.forEach(sub, 2, 1, 4);
        assertArray(u256.slice(1, 4), _sub);

        (, , _mul, , , , ) = helper(u256.slice(1, 4), 2, 0, 4);
        u256.forEach(mul, 2, 1, 4);
        assertArray(u256.slice(1, 4), _mul);

        (, , , _div, , , ) = helper(u256.slice(1, 4), 2, 0, 4);
        u256.forEach(div, 2, 1, 4);
        assertArray(u256.slice(1, 4), _div);

        (, , , , _mod, , ) = helper(u256.slice(1, 4), 2, 0, 4);
        u256.forEach(mod, 2, 1, 4);
        assertArray(u256.slice(1, 4), _mod);

        u256.forEach(add, 41);

        (, , , , , _pow, ) = helper(u256.slice(1, 4), 2, 0, 4);
        u256.forEach(pow, 2, 1, 4);
        assertArray(u256.slice(1, 4), _pow);

        (, , , , , , _xor) = helper(u256.slice(1, 4), 2, 0, 4);
        u256.forEach(xor, 2, 1, 4);
        assertArray(u256.slice(1, 4), _xor);
    }

    function testReverse() external {
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

        // reverse all array
        expectedArray = Solarray.uint256s(
            type(uint232).max,
            type(uint224).max,
            type(uint216).max,
            type(uint208).max,
            type(uint200).max,
            type(uint192).max,
            type(uint184).max
        );
        u256.reverse();
        assertArray(u256.slice(), expectedArray);

        // reverse array from 3rd index to the end
        expectedArray = Solarray.uint256s(
            type(uint232).max,
            type(uint224).max,
            type(uint216).max,
            type(uint184).max,
            type(uint192).max,
            type(uint200).max,
            type(uint208).max
        );
        u256.reverse(3);
        assertArray(u256.slice(), expectedArray);

        // reverse array from 0 index to 2nd
        expectedArray = Solarray.uint256s(
            type(uint216).max,
            type(uint224).max,
            type(uint232).max,
            type(uint184).max,
            type(uint192).max,
            type(uint200).max,
            type(uint208).max
        );
        u256.reverse(0, 2);
        assertArray(u256.slice(), expectedArray);
    }

    function testSome() external {
        uint256[] memory expectedArray;

        expectedArray = Solarray.uint256s(
            type(uint240).max,
            type(uint248).max,
            type(uint256).max,
            type(uint8).max,
            type(uint16).max,
            type(uint24).max,
            type(uint32).max
        );
        u256.concat(expectedArray);

        // iterate through all array and find elem lt type(uint8).max
        assertFalse(u256.some(lt, type(uint8).max));
        // iterate through all array and find elem lte type(uint8).max
        assertTrue(u256.some(lte, type(uint8).max));

        // iterate through array from 4th index to the end and find elem eq type(uint24).max + 1
        assertFalse(u256.some(eq, uint256(type(uint24).max) + 1, 4));
        // iterate through array from 4th index to the end and find elem eq type(uint24).max
        assertTrue(u256.some(eq, type(uint24).max, 4));

        // iterate through array from 3rd index to 5th and find elem gt type(uint24).max
        assertFalse(u256.some(gt, type(uint24).max, 3, 5));
        // iterate through array from 3rd index to 5th and find elem gte type(uint24).max
        assertTrue(u256.some(gte, type(uint24).max, 3, 5));
    }

    function testEvery() external {
        uint256[] memory expectedArray;

        expectedArray = Solarray.uint256s(
            type(uint40).max,
            type(uint48).max,
            type(uint56).max,
            type(uint64).max,
            type(uint72).max,
            type(uint80).max,
            type(uint88).max
        );
        u256.concat(expectedArray);

        // iterate through all array and check that all elems lt type(uint64).max
        assertFalse(u256.every(lt, type(uint64).max));
        // iterate through all array and check that all elems lte type(uint96).max
        assertTrue(u256.every(lte, type(uint96).max));

        // iterate through array from 4th index to the end and check that all elems eq type(uint56).max
        assertFalse(u256.every(eq, uint256(type(uint56).max), 4));
        // iterate through array from 6th index to the end and find elem eq type(uint88).max
        assertTrue(u256.every(eq, type(uint88).max, 6));

        // iterate through array from 3rd index to 5th and check that all elems gt type(uint72).max
        assertFalse(u256.every(gt, type(uint72).max, 3, 5));
        // iterate through array from 3rd index to 5th and check that all elems gte type(uint64).max
        assertTrue(u256.every(gte, type(uint64).max, 3, 5));
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

    function helper(
        uint256[] memory expectedArray,
        uint256 number,
        uint256 indexStart,
        uint256 length
    )
        private
        pure
        returns (
            uint256[] memory _add,
            uint256[] memory _sub,
            uint256[] memory _mul,
            uint256[] memory _div,
            uint256[] memory _mod,
            uint256[] memory _pow,
            uint256[] memory _xor
        )
    {
        _add = new uint256[](length);
        _sub = new uint256[](length);
        _mul = new uint256[](length);
        _div = new uint256[](length);
        _mod = new uint256[](length);
        _pow = new uint256[](length);
        _xor = new uint256[](length);

        for (uint256 i; i < length; ++i) {
            _add[i] = expectedArray[indexStart] + number;
            _sub[i] = expectedArray[indexStart] - number;
            _mul[i] = expectedArray[indexStart] * number;
            _div[i] = expectedArray[indexStart] / number;
            _mod[i] = expectedArray[indexStart] % number;
            _pow[i] = expectedArray[indexStart] ** number;
            _xor[i] = expectedArray[indexStart] ^ number;
            ++indexStart;
        }
    }
}
