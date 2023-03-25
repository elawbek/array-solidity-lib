// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {Array, CustomArray} from "src/Array.sol";

contract FixMathTest is Test {
    using Array for CustomArray;

    /* initial values 
    struct CustomArray {
        uint256 length; 0
        uint256 slot;   0
    }
    */
    CustomArray private a;

    function test() external {
        uint256 value = 1;

        a.push(value);

        console2.log(a.get(0));

        value = 2;

        a.unshift(value);

        console2.log(a.get(0));
        console2.logBool(a.includes(0));

        a.shift();

        console2.log(a.get(0));
    }
}
