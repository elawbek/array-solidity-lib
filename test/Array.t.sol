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
        a.push(0);
        a.push(1);
        a.push(2);
        a.push(3);

        console2.log(a.atUint256(3));
        console2.log(a.atUint256(1));
        console2.log(a.atUint256(-4));
    }
}
