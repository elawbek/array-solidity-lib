// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
    [x] at
       - [x] negative index (from end)
    [x] concat
    [x] fill
    [x] filter
       - [x] lt, gt, eq, lte, gte
       - [x] bounds
    [] find & findLast
       - [x] lt, gt, eq, lte, gte
       - [] bounds
    [] findIndex & findLastIndex
       - [x] lt, gt, eq, lte, gte
       - [] bounds
    [x] includes
       - [x] bounds
    [x] indexOf & lastIndexOf
       - [x] bounds
    [] forEach
       - [] callbacks
       - [] bounds
    [] map
       - [] callbacks
       - [] bounds
    [x] pop
    [x] push
    [] reverse (???)
       - [] (?)
       - [] bounds
    [x] shift
    [x] unshift
    [] slice(?)
       - [] negative index (from end)
    [] some(?)
       - [] callbacks
       - [] bounds
    [] sort(???)
    [x] - length
    [x] - remove
    [x] update
 */

library Uint256Array {
    error IndexDoesNotExist();
    error ArrayIsEmpty();
    error WrongArguments();

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

    function update(
        CustomArray storage _self,
        int256 index,
        uint256 value
    ) internal {
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

            sstore(add(sload(add(_self.slot, 0x01)), index), value)
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
                let i := lenArray
                let slot := add(sload(add(_self.slot, 0x01)), len)
                let offset := add(values, 0x20)
            } i {
                i := sub(i, 0x01)
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
            let len := sload(_self.slot)

            if iszero(len) {
                // ArrayIsEmpty()
                mstore(0x00, 0x5585048a)
                revert(0x1c, 0x04)
            }

            len := sub(len, 0x01)
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

            sstore(add(slot, 0x01), value2)
            sstore(slot, value1)
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

            sstore(add(slot, 0x02), value3)
            sstore(add(slot, 0x01), value2)
            sstore(slot, value1)
            sstore(add(_self.slot, 0x01), slot)

            // save new len
            sstore(_self.slot, add(sload(_self.slot), 0x03))
        }
    }

    function shift(CustomArray storage _self) internal returns (uint256 elem) {
        assembly {
            let len := sload(_self.slot)

            if iszero(len) {
                // ArrayIsEmpty()
                mstore(0x00, 0x5585048a)
                revert(0x1c, 0x04)
            }

            let slot := sload(add(_self.slot, 0x01))
            elem := sload(slot)

            sstore(slot, 0x00)
            sstore(add(_self.slot, 0x01), add(slot, 0x01))

            // save new len
            sstore(_self.slot, sub(len, 0x01))
        }
    }

    function remove(CustomArray storage _self, int256 index) internal {
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

            let slot := sload(add(_self.slot, 0x01))

            sstore(add(slot, index), sload(sub(add(slot, len), 0x01)))
        }

        pop(_self);
    }

    function includes(
        CustomArray storage _self,
        uint256 value
    ) internal view returns (bool result) {
        uint256 indexTo;
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }
        result = includes(_self, value, 0, indexTo);
    }

    function includes(
        CustomArray storage _self,
        uint256 value,
        uint256 indexFrom
    ) internal view returns (bool result) {
        uint256 indexTo;
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }
        result = includes(_self, value, indexFrom, indexTo);
    }

    function includes(
        CustomArray storage _self,
        uint256 value,
        uint256 indexFrom,
        uint256 indexTo
    ) internal view returns (bool result) {
        assembly {
            if gt(indexFrom, indexTo) {
                // WrongArguments()
                mstore(0x00, 0x666b2f97)
                revert(0x1c, 0x04)
            }

            let len := sload(_self.slot)

            if iszero(lt(indexTo, len)) {
                // IndexDoesNotExist()
                mstore(0x00, 0x2238ba58)
                revert(0x1c, 0x04)
            }

            for {
                let slot := add(sload(add(_self.slot, 0x01)), indexFrom)
            } iszero(gt(indexFrom, indexTo)) {
                indexFrom := add(indexFrom, 0x01)
                slot := add(slot, 0x01)
            } {
                if eq(sload(slot), value) {
                    result := 0x01
                    break
                }
            }
        }
    }

    function fill(CustomArray storage _self, uint256 value) internal {
        uint256 indexTo;
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }
        fill(_self, value, 0, indexTo);
    }

    function fill(
        CustomArray storage _self,
        uint256 value,
        uint256 indexFrom
    ) internal {
        uint256 indexTo;
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }
        fill(_self, value, indexFrom, indexTo);
    }

    function fill(
        CustomArray storage _self,
        uint256 value,
        uint256 indexFrom,
        uint256 indexTo
    ) internal {
        assembly {
            if gt(indexFrom, indexTo) {
                // WrongArguments()
                mstore(0x00, 0x666b2f97)
                revert(0x1c, 0x04)
            }

            let len := sload(_self.slot)

            if iszero(lt(indexTo, len)) {
                // IndexDoesNotExist()
                mstore(0x00, 0x2238ba58)
                revert(0x1c, 0x04)
            }

            for {
                let slot := add(sload(add(_self.slot, 0x01)), indexFrom)
            } iszero(gt(indexFrom, indexTo)) {
                indexFrom := add(indexFrom, 0x01)
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
        uint256 indexTo;
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        index = indexOf(_self, value, 0, indexTo);
    }

    function indexOf(
        CustomArray storage _self,
        uint256 value,
        uint256 indexFrom
    ) internal view returns (int256 index) {
        uint256 indexTo;
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        index = indexOf(_self, value, indexFrom, indexTo);
    }

    function indexOf(
        CustomArray storage _self,
        uint256 value,
        uint256 indexFrom,
        uint256 indexTo
    ) internal view returns (int256 index) {
        assembly {
            if gt(indexFrom, indexTo) {
                // WrongArguments()
                mstore(0x00, 0x666b2f97)
                revert(0x1c, 0x04)
            }

            let len := sload(_self.slot)

            if iszero(lt(indexTo, len)) {
                // IndexDoesNotExist()
                mstore(0x00, 0x2238ba58)
                revert(0x1c, 0x04)
            }

            for {
                index := not(0x00)
                let slot := add(sload(add(_self.slot, 0x01)), indexFrom)
            } iszero(gt(indexFrom, indexTo)) {
                indexFrom := add(indexFrom, 0x01)
                slot := add(slot, 0x01)
            } {
                if eq(sload(slot), value) {
                    index := indexFrom
                    break
                }
            }
        }
    }

    function lastIndexOf(
        CustomArray storage _self,
        uint256 value
    ) internal view returns (int256 index) {
        uint256 indexTo;
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        index = lastIndexOf(_self, value, 0, indexTo);
    }

    function lastIndexOf(
        CustomArray storage _self,
        uint256 value,
        uint256 indexFrom
    ) internal view returns (int256 index) {
        uint256 indexTo;
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        index = lastIndexOf(_self, value, indexFrom, indexTo);
    }

    function lastIndexOf(
        CustomArray storage _self,
        uint256 value,
        uint256 indexFrom,
        uint256 indexTo
    ) internal view returns (int256 index) {
        assembly {
            if gt(indexFrom, indexTo) {
                // WrongArguments()
                mstore(0x00, 0x666b2f97)
                revert(0x1c, 0x04)
            }

            let len := sload(_self.slot)

            if iszero(lt(indexTo, len)) {
                // IndexDoesNotExist()
                mstore(0x00, 0x2238ba58)
                revert(0x1c, 0x04)
            }

            for {
                let cashedIndexTo := indexTo
                index := not(0x00)
                let slot := add(sload(add(_self.slot, 0x01)), indexTo)
            } iszero(gt(indexFrom, cashedIndexTo)) {
                indexFrom := add(indexFrom, 0x01)
                indexTo := sub(indexTo, 0x01)
                slot := sub(slot, 0x01)
            } {
                if eq(sload(slot), value) {
                    index := indexTo
                    break
                }
            }
        }
    }

    function filter(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue
    ) internal view returns (uint256[] memory filteredArray) {
        uint256 indexTo;
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        filteredArray = filter(_self, callback, comparativeValue, 0, indexTo);
    }

    function filter(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue,
        uint256 indexFrom
    ) internal view returns (uint256[] memory filteredArray) {
        uint256 indexTo;
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        filteredArray = filter(
            _self,
            callback,
            comparativeValue,
            indexFrom,
            indexTo
        );
    }

    function filter(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue,
        uint256 indexFrom,
        uint256 indexTo
    ) internal view returns (uint256[] memory filteredArray) {
        uint256 len;
        bytes32 slot;
        assembly {
            len := sload(_self.slot)

            if iszero(len) {
                return(filteredArray, 0x20)
            }

            if gt(indexFrom, indexTo) {
                // WrongArguments()
                mstore(0x00, 0x666b2f97)
                revert(0x1c, 0x04)
            }

            if iszero(lt(indexTo, len)) {
                // IndexDoesNotExist()
                mstore(0x00, 0x2238ba58)
                revert(0x1c, 0x04)
            }

            slot := add(sload(add(_self.slot, 0x01)), indexFrom)
            indexTo := add(indexTo, 0x01)
            len := sub(indexTo, indexFrom)
        }
        uint256 counter;
        filteredArray = new uint256[](len);

        uint256 value;
        for (; indexFrom < indexTo; ) {
            assembly {
                value := sload(slot)
                indexFrom := add(indexFrom, 0x01)
                slot := add(slot, 0x01)
            }

            if (callback(value, comparativeValue)) {
                filteredArray[counter] = value;
                assembly {
                    counter := add(counter, 0x01)
                }
            }
        }

        assembly {
            mstore(filteredArray, counter)
        }
    }

    function find(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue
    ) internal view returns (uint256[] memory filteredArray) {
        filteredArray = new uint256[](1);

        uint256 len;
        bytes32 slot;
        assembly {
            len := sload(_self.slot)

            if iszero(len) {
                return(filteredArray, 0x20)
            }

            slot := sload(add(_self.slot, 0x01))
        }

        bool success;
        uint256 value;
        for (uint256 i; i < len; ) {
            assembly {
                value := sload(slot)
                i := add(i, 0x01)
                slot := add(slot, 0x01)
            }

            if (callback(value, comparativeValue)) {
                filteredArray[0] = value;
                success = true;
                break;
            }
        }

        assembly {
            if iszero(success) {
                mstore(filteredArray, 0x00)
            }
        }
    }

    function findLast(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue
    ) internal view returns (uint256[] memory filteredArray) {
        filteredArray = new uint256[](1);

        uint256 len;
        bytes32 slot;
        assembly {
            len := sload(_self.slot)

            if iszero(len) {
                return(filteredArray, 0x20)
            }

            slot := sub(add(sload(add(_self.slot, 0x01)), len), 0x01)
        }

        bool success;
        uint256 value;
        for (; len > 0; ) {
            assembly {
                value := sload(slot)
                len := sub(len, 0x01)
                slot := sub(slot, 0x01)
            }

            if (callback(value, comparativeValue)) {
                filteredArray[0] = value;
                success = true;
                break;
            }
        }

        assembly {
            if iszero(success) {
                mstore(filteredArray, 0x00)
            }
        }
    }

    function findIndex(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue
    ) internal view returns (int256 index) {
        uint256 len;
        bytes32 slot;
        assembly {
            index := not(0x00)
            len := sload(_self.slot)
            slot := sload(add(_self.slot, 0x01))
        }

        uint256 value;
        for (uint256 i; i < len; ) {
            assembly {
                value := sload(slot)
            }

            if (callback(value, comparativeValue)) {
                assembly {
                    index := i
                }
                break;
            }

            assembly {
                i := add(i, 0x01)
                slot := add(slot, 0x01)
            }
        }
    }

    function findLastIndex(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue
    ) internal view returns (int index) {
        uint256 len;
        bytes32 slot;
        assembly {
            index := not(0x00)
            len := sload(_self.slot)
            slot := sub(add(sload(add(_self.slot, 0x01)), len), 0x01)
        }

        uint256 value;
        for (; len > 0; ) {
            assembly {
                value := sload(slot)
                len := sub(len, 0x01)
                slot := sub(slot, 0x01)
            }

            if (callback(value, comparativeValue)) {
                assembly {
                    index := len
                }
                break;
            }
        }
    }
}

// -----------------------------------------------------
// callbacks
// -----------------------------------------------------

function lt(uint256 a, uint256 b) pure returns (bool result) {
    assembly {
        result := lt(a, b)
    }
}

function gt(uint256 a, uint256 b) pure returns (bool result) {
    assembly {
        result := gt(a, b)
    }
}

function eq(uint256 a, uint256 b) pure returns (bool result) {
    assembly {
        result := eq(a, b)
    }
}

function lte(uint256 a, uint256 b) pure returns (bool result) {
    assembly {
        result := iszero(gt(a, b))
    }
}

function gte(uint256 a, uint256 b) pure returns (bool result) {
    assembly {
        result := iszero(lt(a, b))
    }
}
