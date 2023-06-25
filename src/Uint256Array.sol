// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the custom uint256 array type.
 * The library was created by building on existing array methods in `javascript`.
 */
library Uint256Array {
    error IndexDoesNotExist();
    error ArrayIsEmpty();
    error WrongArguments();

    /**
     * @dev CustomArray type, which contains the len and slot of the first element.
     */
    struct CustomArray {
        uint256 len;
        uint256 slot;
    }

    /**
     * @dev Returns the length of the array.
     */
    function length(
        CustomArray storage _self
    ) internal view returns (uint256 len) {
        /// @solidity memory-safe-assembly
        assembly {
            len := sload(_self.slot)
        }
    }

    /**
     * @dev Takes an integer value and returns the item at that `index`.
     * Allowing for positive and negative integers. Negative integers
     * count back from the last item in the array.
     *
     * Requirements:
     * - the `index` value must be in the range [-len; len-1].
     */
    function at(
        CustomArray storage _self,
        int256 index
    ) internal view returns (uint256 result) {
        /// @solidity memory-safe-assembly
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

    /**
     * @dev Returns a copy of an array start to end.
     * The original array will not be modified.
     *
     * Returns an empty array if it has no elements.
     */
    function slice(
        CustomArray storage _self
    ) internal view returns (uint256[] memory arr) {
        uint256 indexTo;

        /// @solidity memory-safe-assembly
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }
        arr = slice(_self, 0, indexTo);
    }

    /**
     * @dev Returns a copy of an array in range [`indexFrom`, len-1].
     * The original array will not be modified.
     *
     * Requirements:
     * - `indexFrom` must be less than or equal to len-1.
     *
     * Returns an empty array if it has no elements.
     */
    function slice(
        CustomArray storage _self,
        uint256 indexFrom
    ) internal view returns (uint256[] memory arr) {
        uint256 indexTo;

        /// @solidity memory-safe-assembly
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }
        arr = slice(_self, indexFrom, indexTo);
    }

    /**
     * @dev Returns a copy of an array in range [`indexFrom`, `indexTo`].
     * The original array will not be modified.
     *
     * Requirements:
     * - `indexTo` must be less than the length of the array.
     * - `indexFrom` must be less than or equal to `indexTo`.
     *
     * Returns an empty array if it has no elements.
     * NOTE: If the array is empty, the passed values `indexFrom` and `indexTo`
     * are not validated with respect to the array length and can be any
     * (this is not an error).
     */
    function slice(
        CustomArray storage _self,
        uint256 indexFrom,
        uint256 indexTo
    ) internal view returns (uint256[] memory arr) {
        /// @solidity memory-safe-assembly
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

                mstore(0x40, offset)
            }
        }
    }

    /**
     * @dev Adds the specified element to the end of an array.
     *
     * [1, 2, 3] -> push(4) -> [1, 2, 3, 4]
     */
    function push(CustomArray storage _self, uint256 value) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let len := sload(_self.slot)

            sstore(add(sload(add(_self.slot, 0x01)), len), value)
            sstore(_self.slot, add(len, 0x01))
        }
    }

    /**
     * @dev Adds two specified elements to the end of the array.
     *
     * [1, 2, 3] -> push(4, 5) -> [1, 2, 3, 4, 5]
     */
    function push(
        CustomArray storage _self,
        uint256 value1,
        uint256 value2
    ) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let len := sload(_self.slot)
            let slot := add(sload(add(_self.slot, 0x01)), len)

            sstore(slot, value1)
            sstore(add(slot, 0x01), value2)

            sstore(_self.slot, add(len, 0x02))
        }
    }

    /**
     * @dev Adds three specified elements to the end of the array.
     *
     * [1, 2, 3] -> push(4, 5, 6) -> [1, 2, 3, 4, 5, 6]
     */
    function push(
        CustomArray storage _self,
        uint256 value1,
        uint256 value2,
        uint256 value3
    ) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let len := sload(_self.slot)
            let slot := add(sload(add(_self.slot, 0x01)), len)

            sstore(slot, value1)
            sstore(add(slot, 0x01), value2)
            sstore(add(slot, 0x02), value3)

            sstore(_self.slot, add(len, 0x03))
        }
    }

    /**
     * @dev Adds the specified element to the beginning of an array.
     *
     * [1, 2, 3] -> unshift(4) -> [4, 1, 2, 3]
     */
    function unshift(CustomArray storage _self, uint256 value) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let slot := sub(sload(add(_self.slot, 0x01)), 0x01)

            sstore(slot, value)
            sstore(add(_self.slot, 0x01), slot)

            sstore(_self.slot, add(sload(_self.slot), 0x01))
        }
    }

    /**
     * @dev Adds two specified elements to the beginning of an array.
     *
     * [1, 2, 3] -> unshift(4, 5) -> [4, 5, 1, 2, 3]
     */
    function unshift(
        CustomArray storage _self,
        uint256 value1,
        uint256 value2
    ) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let slot := sub(sload(add(_self.slot, 0x01)), 0x02)

            sstore(add(slot, 0x01), value2)
            sstore(slot, value1)
            sstore(add(_self.slot, 0x01), slot)

            sstore(_self.slot, add(sload(_self.slot), 0x02))
        }
    }

    /**
     * @dev Adds three specified elements to the beginning of an array.
     *
     * [1, 2, 3] -> unshift(4, 5, 6) -> [4, 5, 6, 1, 2, 3]
     */
    function unshift(
        CustomArray storage _self,
        uint256 value1,
        uint256 value2,
        uint256 value3
    ) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let slot := sub(sload(add(_self.slot, 0x01)), 0x03)

            sstore(add(slot, 0x02), value3)
            sstore(add(slot, 0x01), value2)
            sstore(slot, value1)
            sstore(add(_self.slot, 0x01), slot)

            sstore(_self.slot, add(sload(_self.slot), 0x03))
        }
    }

    /**
     * @dev Adds all values of the passed array to the end of the array.
     *
     * [1, 2, 3] -> concat([4, 5, 6]) -> [1, 2, 3, 4, 5, 6]
     */
    function concat(
        CustomArray storage _self,
        uint256[] memory values
    ) internal {
        /// @solidity memory-safe-assembly
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

    /**
     * @dev Removes the last element from an array and returns that element.
     * This method changes the length of the array.
     *
     * Returns an error if the array has no elements.
     */
    function pop(CustomArray storage _self) internal returns (uint256 elem) {
        /// @solidity memory-safe-assembly
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

    /**
     * @dev Removes the first element from an array and returns that element.
     * This method changes the length of the array.
     *
     * Returns an error if the array has no elements.
     */
    function shift(CustomArray storage _self) internal returns (uint256 elem) {
        /// @solidity memory-safe-assembly
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

    /**
     * @dev Takes an integer value and update the item at that `index`.
     * Allowing for positive and negative integers. Negative integers
     * count back from the last item in the array.
     *
     * Requirements:
     * - the `index` value must be in the range [-len; len-1].
     *
     * Returns an error if the array has no elements.
     *
     * [1, 2, 3, 4] -> update(2, 5) -> [1, 2, 5, 4]
     */
    function update(
        CustomArray storage _self,
        int256 index,
        uint256 value
    ) internal {
        /// @solidity memory-safe-assembly
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

    /**
     * @dev Takes an integer value and remove the item at that `index` replacing
     * it with the last element of the array. Allowing for positive and
     * negative integers. Negative integers count back from the last
     * item in the array.
     *
     * Requirements:
     * - the `index` value must be in the range [-len; len-1].
     *
     * Returns an error if the array has no elements.
     *
     * [1, 2, 3, 4, 5] -> remove(1) -> [1, 5, 3, 4]
     */
    function remove(CustomArray storage _self, int256 index) internal {
        /// @solidity memory-safe-assembly
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

            len := sub(len, 0x01)
            sstore(add(slot, index), sload(add(slot, len)))

            slot := add(slot, len)
            sstore(slot, 0x00)
            sstore(_self.slot, len)
        }
    }

    /**
     * @dev Determines whether an array includes a certain value.
     * Returning `true` or `false` as appropriate.
     *
     * Returns `false` if the array has no elements.
     */
    function includes(
        CustomArray storage _self,
        uint256 value
    ) internal view returns (bool result) {
        uint256 indexTo;

        /// @solidity memory-safe-assembly
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }
        result = includes(_self, value, 0, indexTo);
    }

    /**
     * @dev Determines whether an array in range [`indexFrom`, len-1] includes a certain value.
     * Returning `true` or `false` as appropriate.
     *
     * Requirements:
     * - `indexFrom` must be less than or equal to len-1.
     *
     * If no values satisfy the testing function or array have no elements, `false` is returned.
     */
    function includes(
        CustomArray storage _self,
        uint256 value,
        uint256 indexFrom
    ) internal view returns (bool result) {
        uint256 indexTo;

        /// @solidity memory-safe-assembly
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }
        result = includes(_self, value, indexFrom, indexTo);
    }

    /**
     * @dev Determines whether an array in range [`indexFrom`, `indexTo`] includes a certain value.
     * Returning `true` or `false` as appropriate.
     *
     * Requirements:
     * - `indexTo` must be less than the length of the array.
     * - `indexFrom` must be less than or equal to `indexTo`.
     *
     * If no values satisfy the testing function or array have no elements, `false` is returned.
     * NOTE: If the array is empty, the passed values `indexFrom` and `indexTo`
     * are not validated with respect to the array length and can be any
     * (this is not an error).
     */
    function includes(
        CustomArray storage _self,
        uint256 value,
        uint256 indexFrom,
        uint256 indexTo
    ) internal view returns (bool result) {
        /// @solidity memory-safe-assembly
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
    }

    /**
     * @dev Changes all elements in an array to a static value.
     *
     * Returns an error if the array has no elements.
     */
    function fillState(CustomArray storage _self, uint256 value) internal {
        uint256 indexTo;

        /// @solidity memory-safe-assembly
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }
        fillState(_self, value, 0, indexTo);
    }

    /**
     * @dev Changes all elements in an array in range [`indexFrom`, len-1] to a static value.
     *
     * Requirements:
     * - `indexFrom` must be less than or equal to len-1.
     *
     * Returns an error if the array has no elements.
     */
    function fillState(
        CustomArray storage _self,
        uint256 value,
        uint256 indexFrom
    ) internal {
        uint256 indexTo;

        /// @solidity memory-safe-assembly
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }
        fillState(_self, value, indexFrom, indexTo);
    }

    /**
     * @dev Changes all elements in an array in range [`indexFrom`, `indexTo`] to a static value.
     *
     * Requirements:
     * - `indexTo` must be less than the length of the array.
     * - `indexFrom` must be less than or equal to `indexTo`.
     *
     * Returns an error if the array has no elements.
     */
    function fillState(
        CustomArray storage _self,
        uint256 value,
        uint256 indexFrom,
        uint256 indexTo
    ) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let len := sload(_self.slot)

            if iszero(len) {
                // ArrayIsEmpty()
                mstore(0x00, 0x5585048a)
                revert(0x1c, 0x04)
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

    /**
     * @dev Returns the first index at which a given element can be found in the array,
     * or -1 if it is not present.
     *
     * Returns -1 if the array has no elements.
     */
    function indexOf(
        CustomArray storage _self,
        uint256 value
    ) internal view returns (int256 index) {
        uint256 indexTo;

        /// @solidity memory-safe-assembly
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        index = indexOf(_self, value, 0, indexTo);
    }

    /**
     * @dev Returns the first index at which a given element can be found in the array
     * in range [`indexFrom`, len-1], or -1 if it is not present.
     *
     * Requirements:
     * - `indexFrom` must be less than or equal to len-1.
     *
     * Returns -1 if the array has no elements.
     */
    function indexOf(
        CustomArray storage _self,
        uint256 value,
        uint256 indexFrom
    ) internal view returns (int256 index) {
        uint256 indexTo;

        /// @solidity memory-safe-assembly
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        index = indexOf(_self, value, indexFrom, indexTo);
    }

    /**
     * @dev Returns the first index at which a given element can be found in the array
     * in range [`indexFrom`, `indexTo`], or -1 if it is not present.
     *
     * Requirements:
     * - `indexTo` must be less than the length of the array.
     * - `indexFrom` must be less than or equal to `indexTo`.
     *
     * Returns -1 if the array has no elements.
     * NOTE: If the array is empty, the passed values `indexFrom` and `indexTo`
     * are not validated with respect to the array length and can be any
     * (this is not an error).
     */
    function indexOf(
        CustomArray storage _self,
        uint256 value,
        uint256 indexFrom,
        uint256 indexTo
    ) internal view returns (int256 index) {
        /// @solidity memory-safe-assembly
        assembly {
            if gt(indexFrom, indexTo) {
                // WrongArguments()
                mstore(0x00, 0x666b2f97)
                revert(0x1c, 0x04)
            }

            let len := sload(_self.slot)
            index := not(0x00)

            if len {
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
                        index := indexFrom
                        break
                    }
                }
            }
        }
    }

    /**
     * @dev Returns the last index at which a given element can be found in the array,
     * or -1 if it is not present.
     *
     * Returns -1 if the array has no elements.
     */
    function lastIndexOf(
        CustomArray storage _self,
        uint256 value
    ) internal view returns (int256 index) {
        uint256 indexTo;

        /// @solidity memory-safe-assembly
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        index = lastIndexOf(_self, value, 0, indexTo);
    }

    /**
     * @dev Returns the last index at which a given element can be found in the array
     * in range [`indexFrom`, len-1], or -1 if it is not present.
     *
     * Requirements:
     * - `indexFrom` must be less than or equal to len-1.
     *
     * Returns -1 if the array has no elements.
     */
    function lastIndexOf(
        CustomArray storage _self,
        uint256 value,
        uint256 indexFrom
    ) internal view returns (int256 index) {
        uint256 indexTo;

        /// @solidity memory-safe-assembly
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        index = lastIndexOf(_self, value, indexFrom, indexTo);
    }

    /**
     * @dev Returns the last index at which a given element can be found in the array
     * in range [`indexFrom`, `indexTo`], or -1 if it is not present.
     *
     * Requirements:
     * - `indexTo` must be less than the length of the array.
     * - `indexFrom` must be less than or equal to `indexTo`.
     *
     * Returns -1 if the array has no elements.
     * NOTE: If the array is empty, the passed values `indexFrom` and `indexTo`
     * are not validated with respect to the array length and can be any
     * (this is not an error).
     */
    function lastIndexOf(
        CustomArray storage _self,
        uint256 value,
        uint256 indexFrom,
        uint256 indexTo
    ) internal view returns (int256 index) {
        /// @solidity memory-safe-assembly
        assembly {
            if gt(indexFrom, indexTo) {
                // WrongArguments()
                mstore(0x00, 0x666b2f97)
                revert(0x1c, 0x04)
            }

            let len := sload(_self.slot)
            index := not(0x00)

            if len {
                if iszero(lt(indexTo, len)) {
                    // IndexDoesNotExist()
                    mstore(0x00, 0x2238ba58)
                    revert(0x1c, 0x04)
                }

                for {
                    let cashedIndexTo := indexTo
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
    }

    /**
     * @dev Creates a copy of a array filtered down to just the elements from that pass the test
     * implemented by the provided function.
     *
     * Functions are defined in the library:
     * lt, lte, gt, gte, eq, neq
     *
     * If no values satisfy the testing function or array have no elements, an empty array is returned.
     */
    function filter(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue
    ) internal view returns (uint256[] memory filteredArray) {
        uint256 indexTo;

        /// @solidity memory-safe-assembly
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        filteredArray = filter(_self, callback, comparativeValue, 0, indexTo);
    }

    /**
     * @dev Creates a copy of a array in range [`indexFrom`, len-1] filtered down to just
     * the elements from that pass the test implemented by the provided function.
     *
     * Functions are defined in the library:
     * lt, lte, gt, gte, eq, neq
     *
     * Requirements:
     * - `indexFrom` must be less than or equal to len-1.
     *
     * If no values satisfy the testing function or array have no elements,
     * an empty array is returned.
     */
    function filter(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue,
        uint256 indexFrom
    ) internal view returns (uint256[] memory filteredArray) {
        uint256 indexTo;

        /// @solidity memory-safe-assembly
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

    /**
     * @dev Creates a copy of a array in range [`indexFrom`, `indexTo`] filtered down to just
     * the elements from that pass the test implemented by the provided function.
     *
     * Functions are defined in the library:
     * lt, lte, gt, gte, eq, neq
     *
     * Requirements:
     * - `indexTo` must be less than the length of the array.
     * - `indexFrom` must be less than or equal to `indexTo`.
     *
     * If no values satisfy the testing function or array have no elements,
     * an empty array is returned.
     * NOTE: If the array is empty, the passed values `indexFrom` and `indexTo`
     * are not validated with respect to the array length and can be any
     * (this is not an error).
     */
    function filter(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue,
        uint256 indexFrom,
        uint256 indexTo
    ) internal view returns (uint256[] memory filteredArray) {
        uint256 len;
        bytes32 slot;

        /// @solidity memory-safe-assembly
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
                /// @solidity memory-safe-assembly
                assembly {
                    value := sload(slot)
                    indexFrom := add(indexFrom, 0x01)
                    slot := add(slot, 0x01)
                }

                if (callback(value, comparativeValue)) {
                    filteredArray[counter] = value;

                    /// @solidity memory-safe-assembly
                    assembly {
                        counter := add(counter, 0x01)
                    }
                }
            }

            /// @solidity memory-safe-assembly
            assembly {
                mstore(filteredArray, counter)
            }
        }
    }

    /**
     * @dev Returns the first element in the array that satisfies the provided testing function.
     *
     * Functions are defined in the library:
     * lt, lte, gt, gte, eq, neq
     *
     * If no values satisfy the testing function or array have no elements,
     * an empty array is returned.
     */
    function find(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue
    ) internal view returns (uint256[] memory findedValue) {
        uint256 indexTo;

        /// @solidity memory-safe-assembly
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        findedValue = find(_self, callback, comparativeValue, 0, indexTo);
    }

    /**
     * @dev Returns the first element in the array in range [`indexFrom`, len-1] that satisfies
     * the provided testing function.
     *
     * Functions are defined in the library:
     * lt, lte, gt, gte, eq, neq
     *
     * Requirements:
     * - `indexFrom` must be less than or equal to len-1.
     *
     * Returns an empty array if it has no elements.
     */
    function find(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue,
        uint256 indexFrom
    ) internal view returns (uint256[] memory findedValue) {
        uint256 indexTo;

        /// @solidity memory-safe-assembly
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

    /**
     * @dev Returns the first element in the array in range [`indexFrom`, `indexTo`] that satisfies
     * the provided testing function.
     *
     * Functions are defined in the library:
     * lt, lte, gt, gte, eq, neq
     *
     * Requirements:
     * - `indexTo` must be less than the length of the array.
     * - `indexFrom` must be less than or equal to `indexTo`.
     *
     * Returns an empty array if it has no elements.
     * NOTE: If the array is empty, the passed values `indexFrom` and `indexTo`
     * are not validated with respect to the array length and can be any
     * (this is not an error).
     */
    function find(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue,
        uint256 indexFrom,
        uint256 indexTo
    ) internal view returns (uint256[] memory findedValue) {
        uint256 len;
        bytes32 slot;

        /// @solidity memory-safe-assembly
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
                /// @solidity memory-safe-assembly
                assembly {
                    value := sload(slot)
                    indexFrom := add(indexFrom, 0x01)
                    slot := add(slot, 0x01)
                }

                if (callback(value, comparativeValue)) {
                    assembly {
                        mstore(add(findedValue, 0x20), value)
                        success := 0x01
                    }
                    break;
                }
            }

            /// @solidity memory-safe-assembly
            assembly {
                if iszero(success) {
                    mstore(findedValue, 0x00)
                }
            }
        }
    }

    /**
     * @dev Iterates the array in reverse order and returns the value of the first element
     * that satisfies the provided testing function.
     *
     * Functions are defined in the library:
     * lt, lte, gt, gte, eq, neq
     *
     *  Requirements:
     * - `indexFrom` must be less than or equal to len-1.
     *
     * If no value satisfy the testing function or array have no elements,
     * an empty array is returned.
     */
    function findLast(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue
    ) internal view returns (uint256[] memory findedValue) {
        uint256 indexTo;

        /// @solidity memory-safe-assembly
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        findedValue = findLast(_self, callback, comparativeValue, 0, indexTo);
    }

    /**
     * @dev Iterates the array in range [`indexFrom`, len-1] in reverse order and returns
     * the value of the first element that satisfies the provided testing function.
     *
     * Functions are defined in the library:
     * lt, lte, gt, gte, eq, neq
     *
     * Requirements:
     * - `indexFrom` must be less than or equal to len-1.
     *
     * If no value satisfy the testing function or array have no elements,
     * an empty array is returned.
     */
    function findLast(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue,
        uint256 indexFrom
    ) internal view returns (uint256[] memory findedValue) {
        uint256 indexTo;

        /// @solidity memory-safe-assembly
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

    /**
     * @dev Iterates the array in range [`indexFrom`, `indexTo`] in reverse order and returns
     * the value of the first element that satisfies the provided testing function.
     *
     * Functions are defined in the library:
     * lt, lte, gt, gte, eq, neq
     *
     * Requirements:
     * - `indexTo` must be less than the length of the array.
     * - `indexFrom` must be less than or equal to `indexTo`.
     *
     * If no value satisfy the testing function or array have no elements,
     * an empty array is returned.
     * NOTE: If the array is empty, the passed values `indexFrom` and `indexTo`
     * are not validated with respect to the array length and can be any
     * (this is not an error).
     */
    function findLast(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue,
        uint256 indexFrom,
        uint256 indexTo
    ) internal view returns (uint256[] memory findedValue) {
        uint256 len;
        bytes32 slot;

        /// @solidity memory-safe-assembly
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
                /// @solidity memory-safe-assembly
                assembly {
                    value := sload(slot)
                    indexFrom := add(indexFrom, 0x1)
                    slot := sub(slot, 0x01)
                }

                if (callback(value, comparativeValue)) {
                    assembly {
                        mstore(add(findedValue, 0x20), value)
                        success := 0x01
                    }
                    break;
                }
            }

            /// @solidity memory-safe-assembly
            assembly {
                if iszero(success) {
                    mstore(findedValue, 0x00)
                }
            }
        }
    }

    /**
     * @dev Returns the index of the first element in an array
     * that satisfies the provided testing function.
     *
     * If no values satisfy the testing function or array have no elements,
     * -1 is returned.
     */
    function findIndex(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue
    ) internal view returns (int256 index) {
        uint256 indexTo;

        /// @solidity memory-safe-assembly
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        index = findIndex(_self, callback, comparativeValue, 0, indexTo);
    }

    /**
     * @dev Returns the index of the first element in an array in range [`indexFrom`, len-1]
     * that satisfies the provided testing function.
     *
     * Requirements:
     * - `indexFrom` must be less than or equal to len-1.
     *
     * If no values satisfy the testing function or array have no elements,
     * -1 is returned.
     */
    function findIndex(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue,
        uint256 indexFrom
    ) internal view returns (int256 index) {
        uint256 indexTo;

        /// @solidity memory-safe-assembly
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

    /**
     * @dev Returns the index of the first element in an array in range [`indexFrom`, `indexTo`]
     * that satisfies the provided testing function.
     *
     * Requirements:
     * - `indexTo` must be less than the length of the array.
     * - `indexFrom` must be less than or equal to `indexTo`.
     *
     * If no values satisfy the testing function or array have no elements,
     * -1 is returned.
     * NOTE: If the array is empty, the passed values `indexFrom` and `indexTo`
     * are not validated with respect to the array length and can be any
     * (this is not an error).
     */
    function findIndex(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue,
        uint256 indexFrom,
        uint256 indexTo
    ) internal view returns (int256 index) {
        uint256 len;
        bytes32 slot;

        /// @solidity memory-safe-assembly
        assembly {
            if gt(indexFrom, indexTo) {
                // WrongArguments()
                mstore(0x00, 0x666b2f97)
                revert(0x1c, 0x04)
            }

            len := sload(_self.slot)
            index := not(0x00)

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
            uint256 value;
            for (; indexFrom < indexTo; ) {
                /// @solidity memory-safe-assembly
                assembly {
                    value := sload(slot)
                }

                if (callback(value, comparativeValue)) {
                    /// @solidity memory-safe-assembly
                    assembly {
                        index := indexFrom
                    }
                    break;
                }

                /// @solidity memory-safe-assembly
                assembly {
                    indexFrom := add(indexFrom, 0x01)
                    slot := add(slot, 0x01)
                }
            }
        }
    }

    /**
     * @dev Iterates the array in reverse order and returns the index of the first element
     * that satisfies the provided testing function.
     *
     * Functions are defined in the library:
     * lt, lte, gt, gte, eq, neq
     *
     * If no values satisfy the testing function or array have no elements,
     * -1 is returned.
     */
    function findLastIndex(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue
    ) internal view returns (int256 index) {
        uint256 indexTo;

        /// @solidity memory-safe-assembly
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        index = findLastIndex(_self, callback, comparativeValue, 0, indexTo);
    }

    /**
     * @dev Iterates the array in range [`indexFrom`, len-1] in reverse order and returns
     * the index of the first element that satisfies the provided testing function.
     *
     * Functions are defined in the library:
     * lt, lte, gt, gte, eq, neq
     *
     * Requirements:
     * - `indexFrom` must be less than or equal to len-1.
     *
     * If no values satisfy the testing function or array have no elements,
     * -1 is returned.
     */
    function findLastIndex(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue,
        uint256 indexFrom
    ) internal view returns (int256 index) {
        uint256 indexTo;

        /// @solidity memory-safe-assembly
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

    /**
     * @dev Iterates the array in range [`indexFrom`, `indexTo`] in reverse order and returns
     * the index of the first element that satisfies the provided testing function.
     *
     * Functions are defined in the library:
     * lt, lte, gt, gte, eq, neq
     *
     * Requirements:
     * - `indexTo` must be less than the length of the array.
     * - `indexFrom` must be less than or equal to `indexTo`.
     *
     * If no values satisfy the testing function or array have no elements,
     * -1 is returned.
     * NOTE: If the array is empty, the passed values `indexFrom` and `indexTo`
     * are not validated with respect to the array length and can be any
     * (this is not an error).
     */
    function findLastIndex(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue,
        uint256 indexFrom,
        uint256 indexTo
    ) internal view returns (int256 index) {
        uint256 len;
        bytes32 slot;
        uint256 indexToCashed;

        /// @solidity memory-safe-assembly
        assembly {
            if gt(indexFrom, indexTo) {
                // WrongArguments()
                mstore(0x00, 0x666b2f97)
                revert(0x1c, 0x04)
            }

            len := sload(_self.slot)
            index := not(0x00)

            if len {
                if iszero(lt(indexTo, len)) {
                    // IndexDoesNotExist()
                    mstore(0x00, 0x2238ba58)
                    revert(0x1c, 0x04)
                }

                slot := add(sload(add(_self.slot, 0x01)), indexTo)
                indexToCashed := add(indexTo, 0x01)
            }
        }

        if (len > 0) {
            uint256 value;
            for (; indexFrom < indexToCashed; ) {
                /// @solidity memory-safe-assembly
                assembly {
                    value := sload(slot)
                }

                if (callback(value, comparativeValue)) {
                    /// @solidity memory-safe-assembly
                    assembly {
                        index := indexTo
                    }
                    break;
                }

                /// @solidity memory-safe-assembly
                assembly {
                    indexFrom := add(indexFrom, 0x01)
                    indexTo := sub(indexTo, 0x01)
                    slot := sub(slot, 0x01)
                }
            }
        }
    }

    /**
     * @dev Creates a copy of an array start to end populated with the results
     * of calling a provided function on every element.
     *
     * Functions are defined in the library:
     * add, sub, mul, div, mod, pow, xor
     *
     * If no values satisfy the testing function or array have no elements,
     * an empty array is returned.
     */
    function map(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (uint256) callback,
        uint256 calculationValue
    ) internal view returns (uint256[] memory newArray) {
        uint256 indexTo;

        /// @solidity memory-safe-assembly
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        newArray = map(_self, callback, calculationValue, 0, indexTo);
    }

    /**
     * @dev Creates a copy of an array in range [`indexFrom`, len-1] populated
     * with the results of calling a provided function on every element.
     *
     * Functions are defined in the library:
     * add, sub, mul, div, mod, pow, xor
     *
     * Requirements:
     * - `indexFrom` must be less than or equal to len-1.
     *
     * If no values satisfy the testing function or array have no elements,
     * an empty array is returned.
     */
    function map(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (uint256) callback,
        uint256 calculationValue,
        uint256 indexFrom
    ) internal view returns (uint256[] memory newArray) {
        uint256 indexTo;

        /// @solidity memory-safe-assembly
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        newArray = map(_self, callback, calculationValue, indexFrom, indexTo);
    }

    /**
     * @dev Creates a copy of an array in range [`indexFrom`, `indexTo`] populated
     * with the results of calling a provided function on every element.
     *
     * Functions are defined in the library:
     * add, sub, mul, div, mod, pow, xor
     *
     * Requirements:
     * - `indexTo` must be less than the length of the array.
     * - `indexFrom` must be less than or equal to `indexTo`.
     *
     * If no values satisfy the testing function or array have no elements,
     * an empty array is returned.
     * NOTE: If the array is empty, the passed values `indexFrom` and `indexTo`
     * are not validated with respect to the array length and can be any
     * (this is not an error).
     */
    function map(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (uint256) callback,
        uint256 calculationValue,
        uint256 indexFrom,
        uint256 indexTo
    ) internal view returns (uint256[] memory newArray) {
        uint256 len;
        bytes32 slot;

        /// @solidity memory-safe-assembly
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

                newArray := mload(0x40)
                mstore(newArray, sub(indexTo, indexFrom))
            }
        }

        if (len > 0) {
            bytes32 offset;

            /// @solidity memory-safe-assembly
            assembly {
                offset := add(newArray, 0x20)
            }

            uint256 value;
            for (; indexFrom < indexTo; ) {
                /// @solidity memory-safe-assembly
                assembly {
                    value := sload(slot)
                }
                value = callback(value, calculationValue);

                /// @solidity memory-safe-assembly
                assembly {
                    mstore(offset, value)
                    offset := add(offset, 0x20)
                    indexFrom := add(indexFrom, 0x01)
                    slot := add(slot, 0x01)
                }
            }

            /// @solidity memory-safe-assembly
            assembly {
                mstore(0x40, offset)
            }
        }
    }

    /**
     * @dev Executes a provided function once for each array element.
     * The function modifies the array.
     *
     * Functions are defined in the library:
     * add, sub, mul, div, mod, pow, xor
     *
     * If no values satisfy the testing function or array have no elements,
     * does nothing.
     */
    function forEach(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (uint256) callback,
        uint256 calculationValue
    ) internal {
        uint256 indexTo;

        /// @solidity memory-safe-assembly
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        forEach(_self, callback, calculationValue, 0, indexTo);
    }

    /**
     * @dev Executes a provided function once for each array element
     * in range [`indexFrom`, len-1]. The function modifies the array.
     *
     * Functions are defined in the library:
     * add, sub, mul, div, mod, pow, xor
     *
     * Requirements:
     * - `indexFrom` must be less than or equal to len-1.
     *
     * If no values satisfy the testing function or array have no elements,
     * does nothing.
     */
    function forEach(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (uint256) callback,
        uint256 calculationValue,
        uint256 indexFrom
    ) internal {
        uint256 indexTo;

        /// @solidity memory-safe-assembly
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        forEach(_self, callback, calculationValue, indexFrom, indexTo);
    }

    /**
     * @dev Executes a provided function once for each array element
     * in range [`indexFrom`, `indexTo`]. The function modifies the array.
     *
     * Functions are defined in the library:
     * add, sub, mul, div, mod, pow, xor
     *
     * Requirements:
     * - `indexTo` must be less than the length of the array.
     * - `indexFrom` must be less than or equal to `indexTo`.
     *
     * If no values satisfy the testing function or array have no elements,
     * does nothing.
     * NOTE: If the array is empty, the passed values `indexFrom` and `indexTo`
     * are not validated with respect to the array length and can be any
     * (this is not an error).
     */
    function forEach(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (uint256) callback,
        uint256 calculationValue,
        uint256 indexFrom,
        uint256 indexTo
    ) internal {
        uint256 len;
        bytes32 slot;

        /// @solidity memory-safe-assembly
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
            uint256 value;
            for (; indexFrom < indexTo; ) {
                /// @solidity memory-safe-assembly
                assembly {
                    value := sload(slot)
                }
                value = callback(value, calculationValue);

                /// @solidity memory-safe-assembly
                assembly {
                    sstore(slot, value)
                    indexFrom := add(indexFrom, 0x01)
                    slot := add(slot, 0x01)
                }
            }
        }
    }

    /**
     * @dev Swaps the elements in the array mirrorwise.
     * The function modifies the array.
     *
     * If array have no elements, does nothing.
     */
    function reverse(CustomArray storage _self) internal {
        uint256 indexTo;

        /// @solidity memory-safe-assembly
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        reverse(_self, 0, indexTo);
    }

    /**
     * @dev Swaps the elements in the array in range [`indexFrom`, len-1] mirrorwise.
     * The function modifies the array.
     *
     * Requirements:
     * -`indexFrom` must be less than or equal to len-1.
     *
     * If array have no elements, does nothing.
     */
    function reverse(CustomArray storage _self, uint256 indexFrom) internal {
        uint256 indexTo;

        /// @solidity memory-safe-assembly
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        reverse(_self, indexFrom, indexTo);
    }

    /**
     * @dev Swaps the elements in the array in range [`indexFrom`, `indexTo`] mirrorwise.
     * The function modifies the array.
     *
     * Requirements:
     * - `indexTo` must be less than the length of the array.
     * - `indexFrom` must be less than or equal to `indexTo`.
     *
     * If array have no elements, does nothing.
     * NOTE: If the array is empty, the passed values `indexFrom` and `indexTo`
     * are not validated with respect to the array length and can be any
     * (this is not an error).
     */
    function reverse(
        CustomArray storage _self,
        uint256 indexFrom,
        uint256 indexTo
    ) internal {
        /// @solidity memory-safe-assembly
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
    }

    /**
     * @dev Tests whether at least one element in the array passes the test
     * implemented by the provided function. It doesn't modify the array.
     *
     * Functions are defined in the library:
     * lt, lte, gt, gte, eq, neq
     *
     * Returns `false` if the array has no elements.
     */
    function some(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue
    ) internal view returns (bool exists) {
        uint256 indexTo;

        /// @solidity memory-safe-assembly
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        exists = some(_self, callback, comparativeValue, 0, indexTo);
    }

    /**
     * @dev Tests whether at least one element in the array in range [`indexFrom`, len-1]
     * passes the test implemented by the provided function. It doesn't modify the array.
     *
     * Functions are defined in the library:
     * lt, lte, gt, gte, eq, neq
     *
     * Requirements:
     * -`indexFrom` must be less than or equal to len-1.
     *
     * Returns `false` if the array has no elements.
     */
    function some(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue,
        uint256 indexFrom
    ) internal view returns (bool exists) {
        uint256 indexTo;

        /// @solidity memory-safe-assembly
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        exists = some(_self, callback, comparativeValue, indexFrom, indexTo);
    }

    /**
     * @dev Tests whether at least one element in the array in range [`indexFrom`, `indexTo`]
     * passes the test implemented by the provided function. It doesn't modify the array.
     *
     * Functions are defined in the library:
     * lt, lte, gt, gte, eq, neq
     *
     * Requirements:
     * - `indexTo` must be less than the length of the array.
     * - `indexFrom` must be less than or equal to `indexTo`.
     *
     * Returns `false` if the array has no elements.
     * NOTE: If the array is empty, the passed values `indexFrom` and `indexTo`
     * are not validated with respect to the array length and can be any
     * (this is not an error).
     */
    function some(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue,
        uint256 indexFrom,
        uint256 indexTo
    ) internal view returns (bool exists) {
        uint256 len;
        bytes32 slot;

        /// @solidity memory-safe-assembly
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
            uint256 value;
            for (; indexFrom < indexTo; ) {
                /// @solidity memory-safe-assembly
                assembly {
                    value := sload(slot)
                }

                if (callback(value, comparativeValue)) {
                    /// @solidity memory-safe-assembly
                    assembly {
                        exists := 0x01
                    }
                    break;
                }

                /// @solidity memory-safe-assembly
                assembly {
                    indexFrom := add(indexFrom, 0x01)
                    slot := add(slot, 0x01)
                }
            }
        }
    }

    /**
     * @dev Tests whether all elements in the array pass the test implemented
     * by the provided function. It doesn't modify the array.
     *
     * Functions are defined in the library:
     * lt, lte, gt, gte, eq, neq
     *
     * Returns `false` if the array has no elements.
     */
    function every(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue
    ) internal view returns (bool exists) {
        uint256 indexTo;

        /// @solidity memory-safe-assembly
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        exists = every(_self, callback, comparativeValue, 0, indexTo);
    }

    /**
     * @dev Tests whether all elements in the array in range [`indexFrom`, len-1] pass
     * the test implemented by the provided function. It doesn't modify the array.
     *
     * Functions are defined in the library:
     * lt, lte, gt, gte, eq, neq
     *
     * Requirements:
     * -`indexFrom` must be less than or equal to len-1.
     *
     * Returns `false` if the array has no elements.
     */
    function every(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue,
        uint256 indexFrom
    ) internal view returns (bool exists) {
        uint256 indexTo;

        /// @solidity memory-safe-assembly
        assembly {
            indexTo := sub(sload(_self.slot), 0x01)
        }

        exists = every(_self, callback, comparativeValue, indexFrom, indexTo);
    }

    /**
     * @dev Tests whether all elements in the array in range [`indexFrom`, `indexTo`] pass
     * the test implemented by the provided function. It doesn't modify the array.
     *
     * Functions are defined in the library:
     * lt, lte, gt, gte, eq, neq
     *
     * Requirements:
     * - `indexTo` must be less than the length of the array.
     * - `indexFrom` must be less than or equal to `indexTo`.
     *
     * Returns `false` if the array has no elements.
     * NOTE: If the array is empty, the passed values `indexFrom` and `indexTo`
     * are not validated with respect to the array length and can be any
     * (this is not an error).
     */
    function every(
        CustomArray storage _self,
        function(uint256, uint256) pure returns (bool) callback,
        uint256 comparativeValue,
        uint256 indexFrom,
        uint256 indexTo
    ) internal view returns (bool exists) {
        uint256 len;
        bytes32 slot;

        /// @solidity memory-safe-assembly
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
                exists := 0x01
            }
        }

        if (len > 0) {
            uint256 value;
            for (; indexFrom < indexTo; ) {
                /// @solidity memory-safe-assembly
                assembly {
                    value := sload(slot)
                }

                if (!callback(value, comparativeValue)) {
                    /// @solidity memory-safe-assembly
                    assembly {
                        exists := 0x00
                    }
                    break;
                }

                /// @solidity memory-safe-assembly
                assembly {
                    indexFrom := add(indexFrom, 0x01)
                    slot := add(slot, 0x01)
                }
            }
        }
    }
}

// -----------------------------------------------------
// callbacks
// -----------------------------------------------------

/**
 * @dev a < b
 */
function lt(uint256 a, uint256 b) pure returns (bool result) {
    /// @solidity memory-safe-assembly
    assembly {
        result := lt(a, b)
    }
}

/**
 * @dev a > b
 */
function gt(uint256 a, uint256 b) pure returns (bool result) {
    /// @solidity memory-safe-assembly
    assembly {
        result := gt(a, b)
    }
}

/**
 * @dev a == b
 */
function eq(uint256 a, uint256 b) pure returns (bool result) {
    /// @solidity memory-safe-assembly
    assembly {
        result := eq(a, b)
    }
}

/**
 * @dev a != b
 */
function neq(uint256 a, uint256 b) pure returns (bool result) {
    /// @solidity memory-safe-assembly
    assembly {
        result := iszero(eq(a, b))
    }
}

/**
 * @dev a <= b
 */
function lte(uint256 a, uint256 b) pure returns (bool result) {
    /// @solidity memory-safe-assembly
    assembly {
        result := iszero(gt(a, b))
    }
}

/**
 * @dev a >= b
 */
function gte(uint256 a, uint256 b) pure returns (bool result) {
    /// @solidity memory-safe-assembly
    assembly {
        result := iszero(lt(a, b))
    }
}

error Overflow();
error Underflow();
error DivisionByZero();

/**
 * @dev result = a + b
 */
function add(uint256 a, uint256 b) pure returns (uint256 result) {
    /// @solidity memory-safe-assembly
    assembly {
        result := add(a, b)

        if gt(a, result) {
            mstore(0x00, 0x35278d12)
            revert(0x1c, 0x04)
        }
    }
}

/**
 * @dev result = a - b
 */
function sub(uint256 a, uint256 b) pure returns (uint256 result) {
    /// @solidity memory-safe-assembly
    assembly {
        result := sub(a, b)

        if lt(a, result) {
            mstore(0x00, 0xcaccb6d9)
            revert(0x1c, 0x04)
        }
    }
}

/**
 * @dev result = a * b
 */
function mul(uint256 a, uint256 b) pure returns (uint256 result) {
    /// @solidity memory-safe-assembly
    assembly {
        result := mul(a, b)

        if and(gt(b, 0x00), iszero(eq(a, div(result, b)))) {
            mstore(0x00, 0x35278d12)
            revert(0x1c, 0x04)
        }
    }
}

/**
 * @dev result = a / b
 */
function div(uint256 a, uint256 b) pure returns (uint256 result) {
    /// @solidity memory-safe-assembly
    assembly {
        if iszero(b) {
            mstore(0x00, 0x23d359a3)
            revert(0x1c, 0x04)
        }

        result := div(a, b)
    }
}

/**
 * @dev result = a % b
 */
function mod(uint256 a, uint256 b) pure returns (uint256 result) {
    /// @solidity memory-safe-assembly
    assembly {
        if iszero(b) {
            mstore(0x00, 0x23d359a3)
            revert(0x1c, 0x04)
        }

        result := mod(a, b)
    }
}

/**
 * @dev result = a**b
 */
function pow(uint256 a, uint256 b) pure returns (uint256 result) {
    /// @solidity memory-safe-assembly
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

/**
 * @dev result = a ^ b
 */
function xor(uint256 a, uint256 b) pure returns (uint256 result) {
    /// @solidity memory-safe-assembly
    assembly {
        result := xor(a, b)
    }
}
