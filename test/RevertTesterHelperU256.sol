// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Solarray} from "solarray/Solarray.sol";
import {Uint256Array, add, sub, mul, div, mod, pow, xor} from "src/Uint256Array.sol";

contract RevertTesterHelperU256 {
    using Uint256Array for *;

    Uint256Array.CustomArray private u256;

    constructor() {
        assembly {
            sstore(add(u256.slot, 0x01), keccak256(0x00, 0x20))
        }
        uint256[] memory expectedArray;

        expectedArray = Solarray.uint256s(11, 22, 33, 44, 55, 66, 77);
        u256.concat(expectedArray);
    }

    function tstAdd(uint256 number) external view {
        u256.map(add, number);
    }

    function tstSub(uint256 number) external view {
        u256.map(sub, number);
    }

    function tstMul(uint256 number) external view {
        u256.map(mul, number);
    }

    function tstDiv(uint256 number) external view {
        u256.map(div, number);
    }

    function tstMod(uint256 number) external view {
        u256.map(mod, number);
    }

    function tstPow(uint256 number) external view {
        u256.map(pow, number);
    }
}
