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
 * [] - length
 * [] - remove
 */

struct CustomArrayUint256 {
    uint256 length;
    uint256 slot;
    uint256 _type;
}

struct CustomArrayUint248 {
    uint256 length;
    uint256 slot;
    uint248 _type;
}

struct CustomArrayUint128 {
    uint256 length;
    uint256 slot;
    uint128 _type;
}

struct CustomArrayUint88 {
    uint256 length;
    uint256 slot;
    uint88 _type;
}

struct CustomArrayUint72 {
    uint256 length;
    uint256 slot;
    uint72 _type;
}

library Array {
    error IndexDoesNotExist();

    // 256
    function at(
        CustomArrayUint256 storage _self,
        int256 index
    ) internal view returns (uint256 result) {
        bytes32 _slot;
        assembly {
            _slot := _self.slot
        }

        _at(_slot, index);

        assembly {
            result := mload(0x00)
        }
    }

    function _at(bytes32 _slot, int256 index) private view {
        assembly {
            let length := sload(_slot)
            if shr(0xff, index) {
                index := sub(length, add(not(index), 0x01))
            }

            if iszero(lt(index, length)) {
                // IndexDoesNotExist()
                mstore(0x00, 0x2238ba58)
                revert(0x1c, 0x04)
            }

            mstore(0x00, sload(add(sload(add(_slot, 0x01)), index)))
        }
    }

    // 128
    function at(
        CustomArrayUint128 storage _self,
        int256 index
    ) internal view returns (uint128 result) {
        bytes32 _slot;
        bytes32 _offset;
        assembly {
            _slot := _self.slot
            _offset := 0x80
        }

        _at(_slot, index, _offset);

        assembly {
            result := mload(0x00)
        }
    }

    // 88
    function at(
        CustomArrayUint88 storage _self,
        int256 index
    ) internal view returns (uint88 result) {
        bytes32 _slot;
        bytes32 _offset;
        assembly {
            _slot := _self.slot
            _offset := 0x58
        }

        _at(_slot, index, _offset);

        assembly {
            result := mload(0x00)
        }
    }

    // 72
    function at(
        CustomArrayUint72 storage _self,
        int256 index
    ) internal view returns (uint72 result) {
        bytes32 _slot;
        bytes32 _offset;
        assembly {
            _slot := _self.slot
            _offset := 0x48
        }

        _at(_slot, index, _offset);

        assembly {
            result := mload(0x00)
        }
    }

    function _at(bytes32 _slot, int256 index, bytes32 _offset) private view {
        assembly {
            let length := sload(_slot)
            let freeSlots := shr(0x80, length)
            length := and(length, 0xffffffffffffffffffffffffffffffff)

            if shr(0xff, index) {
                index := sub(length, add(not(index), 0x01))
            }

            if iszero(lt(index, length)) {
                // IndexDoesNotExist()
                mstore(0x00, 0x2238ba58)
                revert(0x1c, 0x04)
            }

            index := add(index, freeSlots)
            let value

            // 88-128 buts
            if gt(_offset, 0x50) {
                let _valueSlot := add(sload(add(_slot, 0x01)), shr(0x01, index))

                switch and(index, 0x01)
                case 0x00 {
                    value := and(
                        sload(_valueSlot),
                        0xffffffffffffffffffffffffffffffff
                    )
                }
                default {
                    value := shr(0x80, sload(_valueSlot))
                }

                _offset := 0x00
            }

            // 72-80 bits
            if gt(_offset, 0x46) {
                let _valueSlot := add(sload(add(_slot, 0x01)), div(index, 0x03))

                let position := mod(index, 0x03)

                value := and(
                    shr(mul(position, 0x55), sload(_valueSlot)),
                    0xfffffffffffffffffffff
                )

                _offset := 0x00
            }

            mstore(0x00, value)
        }
    }

    // 256
    function push(CustomArrayUint256 storage _self, uint256 value) internal {
        bytes32 _slot;
        bytes32 _value;
        assembly {
            _slot := _self.slot
            _value := value
        }
        _push(_slot, _value);
    }

    function _push(bytes32 _slot, bytes32 _value) private {
        assembly {
            let length := sload(_slot)

            sstore(add(sload(add(_slot, 0x01)), length), _value)
            sstore(_slot, add(length, 0x01))
        }
    }

    // 128
    function push(CustomArrayUint128 storage _self, uint128 value) internal {
        bytes32 _slot;
        bytes32 _value;
        bytes32 _offset;
        assembly {
            _slot := _self.slot
            _value := value
            _offset := 0x80
        }

        _push(_slot, _value, _offset);
    }

    // 88
    function push(CustomArrayUint88 storage _self, uint88 value) internal {
        bytes32 _slot;
        bytes32 _value;
        bytes32 _offset;
        assembly {
            _slot := _self.slot
            _value := value
            _offset := 0x58
        }

        _push(_slot, _value, _offset);
    }

    // 72
    function push(CustomArrayUint72 storage _self, uint72 value) internal {
        bytes32 _slot;
        bytes32 _value;
        bytes32 _offset;
        assembly {
            _slot := _self.slot
            _value := value
            _offset := 0x48
        }

        _push(_slot, _value, _offset);
    }

    function _push(bytes32 _slot, bytes32 _value, bytes32 _offset) private {
        assembly {
            let length := sload(_slot)
            let value

            // 88-128 bits
            if gt(_offset, 0x50) {
                let _valueSlot := add(
                    sload(add(_slot, 0x01)),
                    shr(0x01, length)
                )

                switch and(length, 0x01)
                case 0x00 {
                    sstore(_valueSlot, _value)
                }
                default {
                    sstore(_valueSlot, or(shl(0x80, _value), sload(_valueSlot)))
                }

                _offset := 0x00
            }

            // 72-80 bits
            if gt(_offset, 0x46) {
                let _valueSlot := add(
                    sload(add(_slot, 0x01)),
                    div(length, 0x03)
                )

                let position := mod(length, 0x03)
                sstore(
                    _valueSlot,
                    or(shl(mul(position, 0x55), _value), sload(_valueSlot))
                )

                _offset := 0x00
            }

            sstore(_slot, add(length, 0x01))
        }
    }

    // 72
    function unshift(CustomArrayUint72 storage _self, uint72 value) internal {
        bytes32 _slot;
        bytes32 _value;
        bytes32 _offset;
        assembly {
            _slot := _self.slot
            _value := value
            _offset := 0x48
        }

        _unshift(_slot, _value, _offset);
    }

    function _unshift(bytes32 _slot, bytes32 _value, bytes32 _offset) private {
        assembly {
            let length := sload(_slot)
            let freeSlots := shr(0x80, length)
            length := and(length, 0xffffffffffffffffffffffffffffffff)

            switch length
            case 0x00 {
                sstore(sload(add(_slot, 0x01)), _value)
            }
            default {
                let _valueSlot := sload(add(_slot, 0x01))
                if iszero(freeSlots) {
                    _valueSlot := sub(_valueSlot, 0x01)
                    sstore(add(_slot, 0x01), _valueSlot)
                }

                // 72-80 bits
                if gt(_offset, 0x46) {
                    switch freeSlots
                    case 0x00 {
                        freeSlots := 0x02
                        sstore(_valueSlot, shl(0xaa, _value))
                    }
                    default {
                        freeSlots := sub(freeSlots, 0x01)
                        sstore(
                            _valueSlot,
                            or(
                                sload(_valueSlot),
                                shl(mul(freeSlots, 0x55), _value)
                            )
                        )
                    }

                    _offset := 0x00
                }
            }

            // save new length
            sstore(_slot, add(or(shl(0x80, freeSlots), length), 0x01))
        }
    }

    // function shift(CustomArray storage _self) internal {
    //     assembly {
    //         let slot := sload(add(_self.slot, 0x01))

    //         sstore(slot, 0x00)
    //         sstore(add(_self.slot, 0x01), add(slot, 0x01))

    //         // save new length
    //         sstore(_self.slot, sub(sload(_self.slot), 0x01))
    //     }
    // }

    // function includes(
    //     CustomArray storage _self,
    //     uint256 value
    // ) internal view returns (bool result) {
    //     assembly {
    //         for {
    //             let length := sload(_self.slot)
    //             let i
    //             let slot := sload(add(_self.slot, 0x01))
    //         } lt(i, length) {
    //             i := add(i, 0x01)
    //             slot := add(slot, 0x01)
    //         } {
    //             if eq(sload(slot), value) {
    //                 result := 0x01
    //                 break
    //             }
    //         }
    //     }
    // }
}
