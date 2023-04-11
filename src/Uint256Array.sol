// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * [x] at
 *    - [x] negative index (from end)
 * [x] concat
 * [x] fill
 * [] filter
 *    - [] callbacks (?)
 * [] find & findLast
 *    - [] callbacks (?)
 * [] findIndex & findLastIndex
 *    - [] callbacks (?)
 * [] forEach
 *    - [] callbacks (?)
 * [x] includes
 * [x] indexOf & lastIndexOf
 * [] join (???)
 *    - [] (?)
 * [] map
 *    - [] callbacks (?)
 * [x] pop
 * [x] push
 * [] reverse (???)
 *    - [] (?)
 * [x] shift
 * [x] unshift
 *    - unshift array
 * [] slice(?)
 *    - [] negative index (from end)
 * [] some(?)
 *    - [] callbacks (?)
 * [] sort(???)
 * [x] - length
 * [] - remove
 */

library Uint256Array {
    error IndexDoesNotExist();

    struct CustomArray {
        uint256 len;
        uint256 slot;
    }

    function length(
        CustomArray storage _self
    ) internal view returns (uint256 len) {
        assembly {
            len := sload(_self.slot)
        }
    }

    function at(
        CustomArray storage _self,
        int256 index
    ) internal view returns (uint256 result) {
        assembly {
            let len := sload(_self.slot)
            if shr(0xff, index) {
                index := sub(len, add(not(index), 0x01))
            }

            if iszero(lt(index, len)) {
                // IndexDoesNotExist()
                mstore(0x00, 0x2238ba58)
                revert(0x1c, 0x04)
            }

            result := sload(add(sload(add(_self.slot, 0x01)), index))
        }
    }

    function push(CustomArray storage _self, uint256 value) internal {
        assembly {
            // TODO gas
            let len := sload(_self.slot)

            sstore(add(sload(add(_self.slot, 0x01)), len), value)
            sstore(_self.slot, add(len, 0x01))
        }
    }

    function push(
        CustomArray storage _self,
        uint256 value1,
        uint256 value2
    ) internal {
        assembly {
            // TODO gas
            let len := sload(_self.slot)
            let slot := add(sload(add(_self.slot, 0x01)), len)

            sstore(slot, value1)
            sstore(add(slot, 0x01), value2)

            sstore(_self.slot, add(len, 0x02))
        }
    }

    function push(
        CustomArray storage _self,
        uint256 value1,
        uint256 value2,
        uint256 value3
    ) internal {
        assembly {
            // TODO gas
            let len := sload(_self.slot)
            let slot := add(sload(add(_self.slot, 0x01)), len)

            sstore(slot, value1)
            sstore(add(slot, 0x01), value2)
            sstore(add(slot, 0x02), value3)

            sstore(_self.slot, add(len, 0x03))
        }
    }

    function concat(
        CustomArray storage _self,
        uint256[] memory values
    ) internal {
        assembly {
            let len := sload(_self.slot)
            let lenArray := mload(values)

            for {
                let i
                let slot := add(sload(add(_self.slot, 0x01)), len)
                let offset := add(values, 0x20)
            } lt(i, lenArray) {
                i := add(i, 0x01)
                slot := add(slot, 0x01)
                offset := add(offset, 0x20)
            } {
                sstore(slot, mload(offset))
            }

            sstore(_self.slot, add(len, lenArray))
        }
    }

    function pop(CustomArray storage _self) internal returns (uint256 elem) {
        assembly {
            let len := sub(sload(_self.slot), 0x01)
            let slot := add(sload(add(_self.slot, 0x01)), len)
            elem := sload(slot)
            sstore(slot, 0x00)
            sstore(_self.slot, len)
        }
    }

    function unshift(CustomArray storage _self, uint256 value) internal {
        assembly {
            let slot := sub(sload(add(_self.slot, 0x01)), 0x01)

            sstore(slot, value)
            sstore(add(_self.slot, 0x01), slot)

            // save new len
            sstore(_self.slot, add(sload(_self.slot), 0x01))
        }
    }

    function unshift(
        CustomArray storage _self,
        uint256 value1,
        uint256 value2
    ) internal {
        assembly {
            let slot := sub(sload(add(_self.slot, 0x01)), 0x02)

            sstore(add(slot, 0x01), value1)
            sstore(slot, value2)
            sstore(add(_self.slot, 0x01), slot)

            // save new len
            sstore(_self.slot, add(sload(_self.slot), 0x02))
        }
    }

    function unshift(
        CustomArray storage _self,
        uint256 value1,
        uint256 value2,
        uint256 value3
    ) internal {
        assembly {
            let slot := sub(sload(add(_self.slot, 0x01)), 0x03)

            sstore(add(slot, 0x02), value1)
            sstore(add(slot, 0x01), value2)
            sstore(slot, value3)
            sstore(add(_self.slot, 0x01), slot)

            // save new len
            sstore(_self.slot, add(sload(_self.slot), 0x03))
        }
    }

    function shift(CustomArray storage _self) internal returns (uint256 elem) {
        assembly {
            let slot := sload(add(_self.slot, 0x01))
            elem := sload(slot)

            sstore(slot, 0x00)
            sstore(add(_self.slot, 0x01), add(slot, 0x01))

            // save new len
            sstore(_self.slot, sub(sload(_self.slot), 0x01))
        }
    }

    function includes(
        CustomArray storage _self,
        uint256 value
    ) internal view returns (bool result) {
        assembly {
            for {
                let len := sload(_self.slot)
                let i
                let slot := sload(add(_self.slot, 0x01))
            } lt(i, len) {
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

    error WrongArgumentsForFill();

    // TODO return resulted array (?)
    function fill(CustomArray storage _self, uint256 value) internal {
        uint indexEnd;
        assembly {
            indexEnd := sub(sload(_self.slot), 0x01)
        }
        fill(_self, value, 0, indexEnd);
    }

    function fill(
        CustomArray storage _self,
        uint256 value,
        uint256 indexStart
    ) internal {
        uint indexEnd;
        assembly {
            indexEnd := sub(sload(_self.slot), 0x01)
        }
        fill(_self, value, indexStart, indexEnd);
    }

    function fill(
        CustomArray storage _self,
        uint256 value,
        uint256 indexStart,
        uint256 indexEnd
    ) internal {
        assembly {
            if gt(indexStart, indexEnd) {
                // WrongArgumentsForFill()
                mstore(0x00, 0xe40dfb3f)
                revert(0x1c, 0x04)
            }

            let len := sload(_self.slot)

            if iszero(lt(indexStart, len)) {
                // IndexDoesNotExist()
                mstore(0x00, 0x2238ba58)
                revert(0x1c, 0x04)
            }

            for {
                let slot := add(sload(add(_self.slot, 0x01)), indexStart)
            } iszero(gt(indexStart, indexEnd)) {
                indexStart := add(indexStart, 0x01)
                slot := add(slot, 0x01)
            } {
                sstore(slot, value)
            }
        }
    }

    function indexOf(
        CustomArray storage _self,
        uint256 value
    ) internal view returns (int256 index) {
        assembly {
            for {
                let len := sload(_self.slot)
                index := not(0x00)
                let i
                let slot := sload(add(_self.slot, 0x01))
            } lt(i, len) {
                i := add(i, 0x01)
                slot := add(slot, 0x01)
            } {
                if eq(sload(slot), value) {
                    index := i
                    break
                }
            }
        }
    }

    function lastIndexOf(
        CustomArray storage _self,
        uint256 value
    ) internal view returns (int256 index) {
        assembly {
            for {
                let len := sload(_self.slot)
                index := not(0x00)
                let slot := sub(add(sload(add(_self.slot, 0x01)), len), 0x01)
            } gt(len, 0x00) {
                len := sub(len, 0x01)
                slot := sub(slot, 0x01)
            } {
                if eq(sload(slot), value) {
                    index := i
                    break
                }
            }
        }
    }
}
