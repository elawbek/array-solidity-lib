// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * types in solidity:
 * 1. uint / int:
 * 256, 248, 240, 232, 224, 216, 208, 200, 192, 184, 176, 168, 160, 152, 144, 136
 * |
 * 128, 120, 112, 104, 96, 88, 80, 72, 64, 56, 48, 40, 32, 24, 16, 8
 *
 * 2. bytes:
 * 32, 31, 30, 29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19, 18, 17
 * |
 * 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1
 *
 * 3. address
 *
 * 4. bool,
 *
 * (???)
 * 5. bytes and strings
 */

/**
 * [] at
 *    - [x] one-slot value types (uint256)
 *    - [] one-slot value types
 *    - [x] negative index (from end)
 *    - [] small static types
 *    - [] dynamic types (?)
 * [] concat
 *    - [] (?)
 * [] fill
 *    - [] (?)
 * [] filter
 *    - [] callbacks (?)
 * [] find & findLast
 *    - [] callbacks (?)
 * [] findIndex & findLastIndex
 *    - [] callbacks (?)
 * [] forEach
 *    - [] callbacks (?)
 * [] includes
 *    - [x] one-slot value types
 *    - [] all static types
 *    - [] dynamic types (?) (strings, bytes)
 * [] indexOf & lastIndexOf
 *    - [] (?)
 * [] join (???)
 *    - [] (?)
 * [] map
 *    - [] callbacks (?)
 * [] pop
 *    - [] one-slot value types
 *    - [] small static types
 *    - [] dynamic types
 * [] push
 *    - [x] one-slot value types
 *    - [] small static types
 *    - [] dynamic types
 * [] reverse (???)
 *    - [] (?)
 * [] shift
 *    - [x] one-slot value types
 *    - [] small static types
 *    - [] dynamic types
 * [] unshift
 *    - [x] one-slot value types
 *    - [] small static types
 *    - [] dynamic types
 * [] slice(?)
 *    - [] one-slot value types
 *    - [] negative index (from end)
 *    - [] small static types
 *    - [] dynamic types (?)
 * [] some(?)
 *    - [] callbacks (?)
 * [] sort(???)
 *    - [] only number values, addresses and static bytes
 *
 */

struct CustomArray {
    uint256 length;
    uint256 slot;
}

library Array {
    error IndexDoesNotExist();

    function atUint256(
        CustomArray storage _self,
        int256 index
    ) internal view returns (uint256 result) {
        _at(_self, index);
        assembly {
            result := mload(0x00)
        }
    }

    function _at(CustomArray storage _self, int256 index) private view {
        assembly {
            let length := sload(_self.slot)
            if shr(0xff, index) {
                index := sub(length, add(not(index), 0x01))
            }

            if iszero(lt(index, length)) {
                // IndexDoesNotExist()
                mstore(0x00, 0x2238ba58)
                revert(0x1c, 0x04)
            }

            mstore(0x00, sload(add(sload(add(_self.slot, 0x01)), index)))
        }
    }

    function includes(
        CustomArray storage _self,
        uint256 value
    ) internal view returns (bool result) {
        assembly {
            for {
                let length := sload(_self.slot)
                let i
                let slot := sload(add(_self.slot, 0x01))
            } lt(i, length) {
                i := add(i, 0x01)
                slot := add(slot, 0x01)
            } {
                if eq(sload(slot), value) {
                    result := 0x01
                    break
                }
            }
        }
    }

    function push(CustomArray storage _self, uint256 value) internal {
        assembly {
            let length := sload(_self.slot)

            // let slot := add(sload(add(_self.slot, 0x01)), length)
            sstore(add(sload(add(_self.slot, 0x01)), length), value)
            sstore(_self.slot, add(length, 0x01))
        }
    }

    function unshift(CustomArray storage _self, uint256 value) internal {
        assembly {
            let slot := sub(sload(add(_self.slot, 0x01)), 0x01)

            sstore(slot, value)
            sstore(add(_self.slot, 0x01), slot)

            // save new length
            sstore(_self.slot, add(sload(_self.slot), 0x01))
        }
    }

    function shift(CustomArray storage _self) internal {
        assembly {
            let slot := sload(add(_self.slot, 0x01))

            sstore(slot, 0x00)
            sstore(add(_self.slot, 0x01), add(slot, 0x01))

            // save new length
            sstore(_self.slot, add(sload(_self.slot), 0x01))
        }
    }
}
