// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
    [x] length
    [x] at
       - [x] negative index (from end)
    [x] slice
    [x] push
    [x] unshift
    [x] concat
    [x] pop
    [x] shift
    [x] update
    [x] remove
    [x] includes
    [x] fill
    [x] indexOf & lastIndexOf
    [x] filter
       - [x] lt, gt, eq, lte, gte
    [x] find & findLast
       - [x] lt, gt, eq, lte, gte
    [x] findIndex & findLastIndex
       - [x] lt, gt, eq, lte, gte
    [x] map
       - [x] add, sub, mul, div, mod, pow, xor
    [x] forEach
       - [x] add, sub, mul, div, mod, pow, xor
    [x] reverse
    [x] some
       - [x] lt, gt, eq, lte, gte
    [x] every
       - [x] lt, gt, eq, lte, gte
    [x] sort
       - [x] bubbleSort
       - [x] quickSort
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

    function slice(
        CustomArray storage _self
    ) internal view returns (uint256[] memory arr) {
        uint256 indexTo;
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }
        arr = slice(_self, 0, indexTo);
    }

    function slice(
        CustomArray storage _self,
        uint256 indexFrom
    ) internal view returns (uint256[] memory arr) {
        uint256 indexTo;
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }
        arr = slice(_self, indexFrom, indexTo);
    }

    function slice(
        CustomArray storage _self,
        uint256 indexFrom,
        uint256 indexTo
    ) internal view returns (uint256[] memory arr) {
        assembly {
            if gt(indexFrom, indexTo) {
                // WrongArguments()
                mstore(0x00, 0x666b2f97)
                revert(0x1c, 0x04)
            }

            let len := sload(_self.slot)

            if len {
                if iszero(lt(indexTo, len)) {
                    // IndexDoesNotExist()
                    mstore(0x00, 0x2238ba58)
                    revert(0x1c, 0x04)
                }

                arr := mload(0x40)
                let offset := add(arr, 0x20)

                for {
                    indexTo := add(indexTo, 0x01)
                    mstore(arr, sub(indexTo, indexFrom))
                    let slot := add(sload(add(_self.slot, 0x01)), indexFrom)
                    let value
                } lt(indexFrom, indexTo) {
                    indexFrom := add(indexFrom, 0x01)
                    slot := add(slot, 0x01)
                    offset := add(offset, 0x20)
                } {
                    mstore(offset, sload(slot))
                }

                mstore(0x40, add(offset, 0x20))
            }
        }
    }

    function push(CustomArray storage _self, uint256 value) internal {
        assembly {
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
            let len := sload(_self.slot)
            let slot := add(sload(add(_self.slot, 0x01)), len)

            sstore(slot, value1)
            sstore(add(slot, 0x01), value2)
            sstore(add(slot, 0x02), value3)

            sstore(_self.slot, add(len, 0x03))
        }
    }

    function unshift(CustomArray storage _self, uint256 value) internal {
        assembly {
            let slot := sub(sload(add(_self.slot, 0x01)), 0x01)

            sstore(slot, value)
            sstore(add(_self.slot, 0x01), slot)

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

            sstore(_self.slot, add(sload(_self.slot), 0x03))
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

            sstore(_self.slot, sub(len, 0x01))
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

    function fillState(CustomArray storage _self, uint256 value) internal {
        uint256 indexTo;
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }
        fillState(_self, value, 0, indexTo);
    }

    function fillState(
        CustomArray storage _self,
        uint256 value,
        uint256 indexFrom
    ) internal {
        uint256 indexTo;
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }
        fillState(_self, value, indexFrom, indexTo);
    }

    function fillState(
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
            if gt(indexFrom, indexTo) {
                // WrongArguments()
                mstore(0x00, 0x666b2f97)
                revert(0x1c, 0x04)
            }

            len := sload(_self.slot)

            if len {
                if iszero(lt(indexTo, len)) {
                    // IndexDoesNotExist()
                    mstore(0x00, 0x2238ba58)
                    revert(0x1c, 0x04)
                }

                slot := add(sload(add(_self.slot, 0x01)), indexFrom)
                indexTo := add(indexTo, 0x01)
                len := sub(indexTo, indexFrom)
            }
        }

        if (len > 0) {
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
    }

    function find(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue
    ) internal view returns (uint256[] memory findedValue) {
        uint256 indexTo;
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        findedValue = find(_self, callback, comparativeValue, 0, indexTo);
    }

    function find(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue,
        uint256 indexFrom
    ) internal view returns (uint256[] memory findedValue) {
        uint256 indexTo;
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        findedValue = find(
            _self,
            callback,
            comparativeValue,
            indexFrom,
            indexTo
        );
    }

    function find(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue,
        uint256 indexFrom,
        uint256 indexTo
    ) internal view returns (uint256[] memory findedValue) {
        uint256 len;
        bytes32 slot;
        assembly {
            if gt(indexFrom, indexTo) {
                // WrongArguments()
                mstore(0x00, 0x666b2f97)
                revert(0x1c, 0x04)
            }

            len := sload(_self.slot)

            if len {
                if iszero(lt(indexTo, len)) {
                    // IndexDoesNotExist()
                    mstore(0x00, 0x2238ba58)
                    revert(0x1c, 0x04)
                }

                slot := add(sload(add(_self.slot, 0x01)), indexFrom)
                indexTo := add(indexTo, 0x01)
            }
        }
        if (len > 0) {
            findedValue = new uint256[](1);

            bool success;
            uint256 value;
            for (; indexFrom < indexTo; ) {
                assembly {
                    value := sload(slot)
                    indexFrom := add(indexFrom, 0x01)
                    slot := add(slot, 0x01)
                }

                if (callback(value, comparativeValue)) {
                    findedValue[0] = value;
                    success = true;
                    break;
                }
            }

            assembly {
                if iszero(success) {
                    mstore(findedValue, 0x00)
                }
            }
        }
    }

    function findLast(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue
    ) internal view returns (uint256[] memory findedValue) {
        uint256 indexTo;
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        findedValue = findLast(_self, callback, comparativeValue, 0, indexTo);
    }

    function findLast(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue,
        uint256 indexFrom
    ) internal view returns (uint256[] memory findedValue) {
        uint256 indexTo;
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        findedValue = findLast(
            _self,
            callback,
            comparativeValue,
            indexFrom,
            indexTo
        );
    }

    function findLast(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue,
        uint256 indexFrom,
        uint256 indexTo
    ) internal view returns (uint256[] memory findedValue) {
        uint256 len;
        bytes32 slot;
        assembly {
            if gt(indexFrom, indexTo) {
                // WrongArguments()
                mstore(0x00, 0x666b2f97)
                revert(0x1c, 0x04)
            }

            len := sload(_self.slot)

            if len {
                if iszero(lt(indexTo, len)) {
                    // IndexDoesNotExist()
                    mstore(0x00, 0x2238ba58)
                    revert(0x1c, 0x04)
                }

                slot := add(sload(add(_self.slot, 0x01)), indexTo)
                indexTo := add(indexTo, 0x01)
            }
        }
        if (len > 0) {
            findedValue = new uint256[](1);

            bool success;
            uint256 value;

            for (; indexFrom < indexTo; ) {
                assembly {
                    value := sload(slot)
                    indexFrom := add(indexFrom, 0x1)
                    slot := sub(slot, 0x01)
                }

                if (callback(value, comparativeValue)) {
                    findedValue[0] = value;
                    success = true;
                    break;
                }
            }

            assembly {
                if iszero(success) {
                    mstore(findedValue, 0x00)
                }
            }
        }
    }

    function findIndex(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue
    ) internal view returns (int256 index) {
        uint256 indexTo;
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        index = findIndex(_self, callback, comparativeValue, 0, indexTo);
    }

    function findIndex(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue,
        uint256 indexFrom
    ) internal view returns (int256 index) {
        uint256 indexTo;
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        index = findIndex(
            _self,
            callback,
            comparativeValue,
            indexFrom,
            indexTo
        );
    }

    function findIndex(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue,
        uint256 indexFrom,
        uint256 indexTo
    ) internal view returns (int256 index) {
        bytes32 slot;
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

            slot := add(sload(add(_self.slot, 0x01)), indexFrom)
            indexTo := add(indexTo, 0x01)

            index := not(0x00)
        }

        uint256 value;
        for (; indexFrom < indexTo; ) {
            assembly {
                value := sload(slot)
            }

            if (callback(value, comparativeValue)) {
                assembly {
                    index := indexFrom
                }
                break;
            }

            assembly {
                indexFrom := add(indexFrom, 0x01)
                slot := add(slot, 0x01)
            }
        }
    }

    function findLastIndex(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue
    ) internal view returns (int256 index) {
        uint256 indexTo;
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        index = findLastIndex(_self, callback, comparativeValue, 0, indexTo);
    }

    function findLastIndex(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue,
        uint256 indexFrom
    ) internal view returns (int256 index) {
        uint256 indexTo;
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        index = findLastIndex(
            _self,
            callback,
            comparativeValue,
            indexFrom,
            indexTo
        );
    }

    function findLastIndex(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue,
        uint256 indexFrom,
        uint256 indexTo
    ) internal view returns (int256 index) {
        bytes32 slot;
        uint256 indexToCashed;
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

            slot := add(sload(add(_self.slot, 0x01)), indexTo)
            indexToCashed := add(indexTo, 0x01)

            index := not(0x00)
        }

        uint256 value;
        for (; indexFrom < indexToCashed; ) {
            assembly {
                value := sload(slot)
            }

            if (callback(value, comparativeValue)) {
                assembly {
                    index := indexTo
                }
                break;
            }

            assembly {
                indexFrom := add(indexFrom, 0x01)
                indexTo := sub(indexTo, 0x01)
                slot := sub(slot, 0x01)
            }
        }
    }

    function map(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (uint256) callback,
        uint256 calculationValue
    ) internal view returns (uint256[] memory newArray) {
        uint256 indexTo;
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        newArray = map(_self, callback, calculationValue, 0, indexTo);
    }

    function map(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (uint256) callback,
        uint256 calculationValue,
        uint256 indexFrom
    ) internal view returns (uint256[] memory newArray) {
        uint256 indexTo;
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        newArray = map(_self, callback, calculationValue, indexFrom, indexTo);
    }

    function map(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (uint256) callback,
        uint256 calculationValue,
        uint256 indexFrom,
        uint256 indexTo
    ) internal view returns (uint256[] memory newArray) {
        bytes32 slot;
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

            slot := add(sload(add(_self.slot, 0x01)), indexFrom)
            indexTo := add(indexTo, 0x01)

            newArray := mload(0x40)
            mstore(newArray, sub(indexTo, indexFrom))
        }

        bytes32 offset;
        assembly {
            offset := add(newArray, 0x20)
        }

        uint256 value;
        for (; indexFrom < indexTo; ) {
            assembly {
                value := sload(slot)
            }
            value = callback(value, calculationValue);

            assembly {
                mstore(offset, value)
                offset := add(offset, 0x20)
                indexFrom := add(indexFrom, 0x01)
                slot := add(slot, 0x01)
            }
        }

        assembly {
            mstore(0x40, offset)
        }
    }

    function forEach(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (uint256) callback,
        uint256 calculationValue
    ) internal {
        uint256 indexTo;
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        forEach(_self, callback, calculationValue, 0, indexTo);
    }

    function forEach(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (uint256) callback,
        uint256 calculationValue,
        uint256 indexFrom
    ) internal {
        uint256 indexTo;
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        forEach(_self, callback, calculationValue, indexFrom, indexTo);
    }

    function forEach(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (uint256) callback,
        uint256 calculationValue,
        uint256 indexFrom,
        uint256 indexTo
    ) internal {
        bytes32 slot;
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

            slot := add(sload(add(_self.slot, 0x01)), indexFrom)
            indexTo := add(indexTo, 0x01)
        }

        uint256 value;
        for (; indexFrom < indexTo; ) {
            assembly {
                value := sload(slot)
            }
            value = callback(value, calculationValue);

            assembly {
                sstore(slot, value)
                indexFrom := add(indexFrom, 0x01)
                slot := add(slot, 0x01)
            }
        }
    }

    function reverse(CustomArray storage _self) internal {
        uint256 indexTo;
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        reverse(_self, 0, indexTo);
    }

    function reverse(CustomArray storage _self, uint256 indexFrom) internal {
        uint256 indexTo;
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        reverse(_self, indexFrom, indexTo);
    }

    function reverse(
        CustomArray storage _self,
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

            len := add(sub(indexTo, indexFrom), 0x01)
            switch and(len, 0x01)
            case 0x00 {
                len := shr(0x01, len)
            }
            case 0x01 {
                len := shr(0x01, sub(len, 0x01))
            }

            for {
                let slot := sload(add(_self.slot, 0x01))
                let slotIndexFrom := add(slot, indexFrom)
                let slotIndexTo := add(slot, indexTo)

                let value
            } len {
                len := sub(len, 0x01)
                slotIndexFrom := add(slotIndexFrom, 0x01)
                slotIndexTo := sub(slotIndexTo, 0x01)
            } {
                value := sload(slotIndexFrom)
                sstore(slotIndexFrom, sload(slotIndexTo))
                sstore(slotIndexTo, value)
            }
        }
    }

    function some(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue
    ) internal view returns (bool exists) {
        uint256 indexTo;
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        exists = some(_self, callback, comparativeValue, 0, indexTo);
    }

    function some(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue,
        uint256 indexFrom
    ) internal view returns (bool exists) {
        uint256 indexTo;
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        exists = some(_self, callback, comparativeValue, indexFrom, indexTo);
    }

    function some(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue,
        uint256 indexFrom,
        uint256 indexTo
    ) internal view returns (bool exists) {
        bytes32 slot;
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

            slot := add(sload(add(_self.slot, 0x01)), indexFrom)
            indexTo := add(indexTo, 0x01)
        }

        uint256 value;
        for (; indexFrom < indexTo; ) {
            assembly {
                value := sload(slot)
            }

            if (callback(value, comparativeValue)) {
                assembly {
                    exists := 0x01
                }
                break;
            }

            assembly {
                indexFrom := add(indexFrom, 0x01)
                slot := add(slot, 0x01)
            }
        }
    }

    function every(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue
    ) internal view returns (bool exists) {
        uint256 indexTo;
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        exists = every(_self, callback, comparativeValue, 0, indexTo);
    }

    function every(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue,
        uint256 indexFrom
    ) internal view returns (bool exists) {
        uint256 indexTo;
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        exists = every(_self, callback, comparativeValue, indexFrom, indexTo);
    }

    function every(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue,
        uint256 indexFrom,
        uint256 indexTo
    ) internal view returns (bool exists) {
        bytes32 slot;
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

            slot := add(sload(add(_self.slot, 0x01)), indexFrom)
            indexTo := add(indexTo, 0x01)
            exists := 0x01
        }

        uint256 value;
        for (; indexFrom < indexTo; ) {
            assembly {
                value := sload(slot)
            }

            if (!callback(value, comparativeValue)) {
                assembly {
                    exists := 0x00
                }
                break;
            }

            assembly {
                indexFrom := add(indexFrom, 0x01)
                slot := add(slot, 0x01)
            }
        }
    }

    function sort(CustomArray storage _self) internal {
        uint256 indexTo;
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        sort(_self, 0, indexTo);
    }

    function sort(CustomArray storage _self, uint256 indexFrom) internal {
        uint256 indexTo;
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        sort(_self, indexFrom, indexTo);
    }

    function sort(
        CustomArray storage _self,
        uint256 indexFrom,
        uint256 indexTo
    ) internal {
        uint256 len;
        assembly {
            if gt(indexFrom, indexTo) {
                // WrongArguments()
                mstore(0x00, 0x666b2f97)
                revert(0x1c, 0x04)
            }

            len := sload(_self.slot)

            if iszero(lt(indexTo, len)) {
                // IndexDoesNotExist()
                mstore(0x00, 0x2238ba58)
                revert(0x1c, 0x04)
            }
        }
        quickSort(_self, indexFrom, indexTo);
    }

    function bubbleSort(
        CustomArray storage _self,
        uint256 indexFrom,
        uint256 indexTo
    ) internal {
        assembly {
            for {
                indexTo := add(indexTo, 0x01)
                let len := sub(indexTo, indexFrom)

                let swapped
                let slot := add(sload(add(_self.slot, 0x01)), indexFrom)
            } len {
                swapped := 0x00
            } {
                len := sub(len, 0x01)

                for {
                    let i
                    let nextSlot
                    let currentSlot := slot
                    let currentValue := sload(slot)
                    let nextValue
                } lt(i, len) {
                    i := add(i, 0x01)
                    currentSlot := nextSlot
                } {
                    nextSlot := add(currentSlot, 0x01)
                    nextValue := sload(nextSlot)

                    switch gt(currentValue, nextValue)
                    case 0x01 {
                        sstore(currentSlot, nextValue)
                        sstore(nextSlot, currentValue)
                        swapped := 0x01
                    }
                    default {
                        currentValue := nextValue
                    }
                }

                if iszero(swapped) {
                    break
                }
            }
        }
    }

    function quickSort(
        CustomArray storage _self,
        uint256 indexFrom,
        uint256 indexTo
    ) private {
        assembly {
            for {
                mstore(0x20, sload(add(_self.slot, 0x01)))
                let stack := mload(0x40)
                mstore(stack, indexFrom)
                mstore(add(stack, 0x20), indexTo)
                stack := add(stack, 0x40)
                let stackLen := 0x1

                let low
                let high
                let pivot
            } stackLen {

            } {
                stack := sub(stack, 0x40)
                low := mload(stack)
                high := mload(add(stack, 0x20))
                stackLen := sub(stackLen, 0x01)

                pivot := partition(low, high)

                if pivot {
                    if gt(sub(pivot, 0x01), low) {
                        mstore(stack, low)
                        mstore(add(stack, 0x20), sub(pivot, 0x01))
                        stack := add(stack, 0x40)
                        stackLen := add(stackLen, 0x01)
                    }
                }

                if lt(add(pivot, 0x01), high) {
                    mstore(stack, add(pivot, 0x01))
                    mstore(add(stack, 0x20), high)
                    stack := add(stack, 0x40)
                    stackLen := add(stackLen, 0x01)
                }
            }

            function partition(low, high) -> index {
                let slot := mload(0x20)

                let pivot := sload(add(slot, high))
                let i := sub(low, 0x01)
                let slotI
                let value

                for {
                    let j := low
                    let slotJ
                } lt(j, high) {
                    j := add(j, 0x01)
                } {
                    slotJ := add(slot, j)
                    value := sload(slotJ)

                    if iszero(gt(value, pivot)) {
                        i := add(i, 0x01)
                        slotI := add(slot, i)
                        sstore(slotJ, sload(slotI))
                        sstore(slotI, value)
                    }
                }

                slotI := add(slot, add(i, 0x01))
                value := sload(slotI)
                sstore(slotI, sload(add(slot, high)))
                sstore(add(slot, high), value)

                index := add(i, 0x01)
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

error Overflow();
error Underflow();
error DivisionByZero();

function add(uint256 a, uint256 b) pure returns (uint256 result) {
    assembly {
        result := add(a, b)

        if gt(a, result) {
            mstore(0x00, 0x35278d12)
            revert(0x1c, 0x04)
        }
    }
}

function sub(uint256 a, uint256 b) pure returns (uint256 result) {
    assembly {
        result := sub(a, b)

        if lt(a, result) {
            mstore(0x00, 0xcaccb6d9)
            revert(0x1c, 0x04)
        }
    }
}

function mul(uint256 a, uint256 b) pure returns (uint256 result) {
    assembly {
        result := mul(a, b)

        if and(gt(b, 0x00), iszero(eq(a, div(result, b)))) {
            mstore(0x00, 0x35278d12)
            revert(0x1c, 0x04)
        }
    }
}

function div(uint256 a, uint256 b) pure returns (uint256 result) {
    assembly {
        if iszero(b) {
            mstore(0x00, 0x23d359a3)
            revert(0x1c, 0x04)
        }

        result := div(a, b)
    }
}

function mod(uint256 a, uint256 b) pure returns (uint256 result) {
    assembly {
        if iszero(b) {
            mstore(0x00, 0x23d359a3)
            revert(0x1c, 0x04)
        }

        result := mod(a, b)
    }
}

function pow(uint256 a, uint256 b) pure returns (uint256 result) {
    assembly {
        switch b
        case 0x00 {
            result := 0x01
        }
        case 0x01 {
            result := a
        }
        default {
            switch a
            case 0x00 {
                // do nothing, result already zero
            }
            case 0x01 {
                result := 0x01
            }
            case 0x02 {
                if gt(b, 0xff) {
                    mstore(0x00, 0x35278d12)
                    revert(0x1c, 0x04)
                }
                result := shl(b, 0x01)
            }
            default {
                switch or(
                    and(lt(a, 0x0b), lt(b, 0x4e)),
                    and(lt(a, 0x133), lt(b, 0x20))
                )
                case 0x01 {
                    result := exp(a, b)
                }
                default {
                    let maxUint256 := not(0x00)
                    let helper := 0x01

                    for {
                        let one := helper
                    } one {

                    } {
                        if gt(a, div(maxUint256, a)) {
                            mstore(0x00, 0x35278d12)
                            revert(0x1c, 0x04)
                        }

                        switch and(b, one)
                        case 0x00 {
                            b := shr(one, b)
                        }
                        case 0x01 {
                            helper := mul(a, helper)
                            b := shr(one, b)
                        }

                        a := mul(a, a)

                        if gt(b, one) {
                            continue
                        }

                        break
                    }

                    if gt(helper, div(maxUint256, a)) {
                        mstore(0x00, 0x35278d12)
                        revert(0x1c, 0x04)
                    }

                    result := mul(helper, a)
                }
            }
        }
    }
}

function xor(uint256 a, uint256 b) pure returns (uint256 result) {
    assembly {
        result := xor(a, b)
    }
}
