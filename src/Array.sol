// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * [] at
 *    - [x] init realization with uint256
 *    - [] negative index (from end)
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
 *    - [x] init realization with uint256
 *    - [] all static types
 *    - dynamic types (?) (strings, bytes)
 * [] indexOf & lastIndexOf
 *    - [] (?)
 * [] join (???)
 *    - [] (?)
 * [] map
 *    - [] callbacks (?)
 * [] pop
 *    - [] init realization with uint256
 *    - [] small static types
 *    - [] dynamic types
 * [] push
 *    - [x] init realization with uint256
 *    - [] small static types
 *    - [] dynamic types
 * [] reverse (???)
 *    - [] (?)
 * [] shift
 *    - [x] init realization with uint256
 *    - [] small static types
 *    - [] dynamic types
 * [] unshift
 *    - [x] init realization with uint256
 *    - [] small static types
 *    - [] dynamic types
 * [] slice(?)
 *    - [] init realization with uint256
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
    function at(
        CustomArray storage _self,
        uint256 index
    ) internal view returns (uint256 result) {
        assembly {
            // let slot := add(sload(add(_self.slot, 0x01)), index)
            result := sload(add(sload(add(_self.slot, 0x01)), index))
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
