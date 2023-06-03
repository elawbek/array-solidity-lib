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

        console2.logString("map");
        console2.logString("----------------------------------------");
        console2.logString("map: add 2 to all elements");
        uint256[] memory mapRes = u256.map(add, 2);
        logArray(mapRes);

        console2.logString("----------------------------------------");
        console2.logString("map: mul elements by 3 from 8 index");
        mapRes = u256.map(mul, 3, 8);
        logArray(mapRes);

        console2.logString("----------------------------------------");
        console2.logString("map: mod elements by 15 from 4 to 9 indexes");
        mapRes = u256.map(mod, 15, 4, 9);
        logArray(mapRes);

        // console2.logString("includes");
        // console2.log(
        //     "Non-existent element from the whole array: ",
        //     u256.includes(1)
        // );
        // console2.log(
        //     "Non-existent element from 4 index: ",
        //     u256.includes(0, 4)
        // );
        // console2.log(
        //     "Non-existent element from 5 to 10 indexes: ",
        //     u256.includes(3, 5, 10)
        // );
        // console2.log("Element from the whole array :", u256.includes(2048));
        // console2.log("Element from 8 index :", u256.includes(2048, 8));
        // console2.log(
        //     "Element from 7 to 9 indexes :",
        //     u256.includes(2048, 7, 9)
        // );
        // console2.logString("----------------------------------------");

        // console2.logString("indexOf");
        // console2.log(
        //     "Non-existent element from the whole array: ",
        //     u256.indexOf(1)
        // );
        // console2.log("Non-existent element from 2 index: ", u256.indexOf(0, 4));
        // console2.log(
        //     "Non-existent element from 5 to 10 indexes: ",
        //     u256.indexOf(3, 5, 10)
        // );
        // console2.log("Element from the whole array :", u256.indexOf(2048));
        // console2.log("Element from 8 index :", u256.indexOf(2048, 8));
        // console2.log("Element from 7 to 9 indexes :", u256.indexOf(2048, 7, 9));
        // console2.logString("----------------------------------------");

        // console2.logString("lastIndexOf");
        // console2.log(
        //     "Non-existent element from the whole array: ",
        //     u256.lastIndexOf(1)
        // );
        // console2.log(
        //     "Non-existent element from 2 index: ",
        //     u256.lastIndexOf(0, 4)
        // );
        // console2.log(
        //     "Non-existent element from 5 to 10 indexes: ",
        //     u256.lastIndexOf(3, 5, 10)
        // );
        // console2.log("Element from the whole array :", u256.lastIndexOf(2048));
        // console2.log("Element from 8 index :", u256.lastIndexOf(2048, 8));
        // console2.log(
        //     "Element from 7 to 9 indexes :",
        //     u256.lastIndexOf(2048, 7, 9)
        // );
        // console2.logString("----------------------------------------");

        // console2.logString("filter");
        // console2.logString("----------------------------------------");
        // console2.logString("Filter elems lt 42");
        // uint256[] memory res = u256.filter(lt, 42);
        // logArray(res);

        // console2.logString("Filter elems gt 5 from 3 index");
        // res = u256.filter(gt, 5, 3);
        // logArray(res);

        // console2.logString("Filter elems eq 3 from 4 to 9 indexes");
        // res = u256.filter(eq, 3, 4, 11);
        // logArray(res);

        // console2.logString("Empty array");
        // res = u256.filter(gt, 2048);
        // logArray(res);

        // console2.logString("find/findLast & findIndex/findLastIndex");
        // console2.logString("----------------------------------------");
        // console2.logString("find first > 10");
        // uint256[] memory res = u256.find(gt, 10);
        // logArray(res);

        // console2.logString("find first < 10 in range 5-last");
        // res = u256.find(lt, 10, 5);
        // logArray(res);

        // console2.logString("find first > 0 in range 0-4");
        // res = u256.find(gt, 0, 0, 4);
        // logArray(res);

        // console2.logString("find last > 10");
        // res = u256.findLast(gt, 10);
        // logArray(res);

        // console2.logString("find last < 10 in range 5-last");
        // res = u256.findLast(lt, 10, 5);
        // logArray(res);

        // console2.logString("find last > 0 in range 0-4");
        // res = u256.findLast(gt, 0, 0, 4);
        // logArray(res);

        // console2.logString("find index first > 10");
        // int256 index = u256.findIndex(gt, 10);
        // console2.logInt(index);

        // console2.logString("find index first < 10 in range 5-last");
        // index = u256.findIndex(lt, 10, 5);
        // console2.logInt(index);

        // console2.logString("find index first > 0 in range 0-4");
        // index = u256.findIndex(gt, 0, 0, 4);
        // console2.logInt(index);

        // console2.logString("find index last > 10");
        // index = u256.findLastIndex(gt, 10);
        // console2.logInt(index);

        // console2.logString("find index last < 10 in range 5-last");
        // index = u256.findLastIndex(lt, 10, 5);
        // console2.logInt(index);

        // console2.logString("find index last > 0 in range 0-4");
        // index = u256.findLastIndex(gt, 0, 0, 4);
        // console2.logInt(index);
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

    function logArray(uint256[] memory array) private view {
        console2.log("length: ", array.length);

        uint256 i;
        while (i < array.length) {
            console2.log("index: %s, elem: %s", i, array[i]);
            ++i;
        }
        console2.logString("----------------------------------------");
    }

    function abs(int value) private pure returns (uint256) {
        return value >= 0 ? uint256(value) : uint256(-value);
    }
}
