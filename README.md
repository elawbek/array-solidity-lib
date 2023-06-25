# Array library

Solidity library for working with arrays, imitating array methods in the JavaScript programming language

## Usage

```solidity
pragma solidity ^0.8.0;

import { Uint256Array } from "array-solidity-lib/Uint256Array.sol";

contract Contract {
    using Uint256Array for Uint256Array.CustomArray;

    Uint256Array.CustomArray private u256;

    constructor() {
        assembly {
            // Initializing an array slot
            mstore(0x00, u256.slot)
            sstore(add(u256.slot, 0x01), keccak256(0x00, 0x20))
        }
    }

    function getArray() external view returns(uint256[] memory array) {
        array = u256.slice();
    }

    function push(uint256 value) external {
        u256.push(value);
    }
}
```

## Methods

| Name             |  Description                                                                                                                  |
| ---------------- |  ---------------------------------------------------------------------------------------------------------------------------  |
| `length`         |  Returns the length of the array                                                                                              |
| `at`             |  Takes an integer value and returns the item at that `index`                                                                  |
| `slice`          |  Returns a copy of an array                                                                                                   |
| `push`           |  Adds the specified element to the end of an array                                                                            |
| `unshift`        |  Adds the specified element to the beginning of an array                                                                      |
| `concat`         |  Adds all values of the passed array to the end of the array                                                                  |
| `pop`            |  Removes the last element from an array and returns that element                                                              |
| `shift`          |  Removes the first element from an array and returns that element                                                             |
| `update`         |  Takes an integer value and update the item at that `index`                                                                   |
| `remove`         |  Takes an integer value and remove the item at that `index` replacing it with the last element of the array                   |
| `includes`       |  Determines whether an array includes a certain value                                                                         |
| `fillState`      |  Changes all elements in an array to a static value                                                                           |
| `indexOf`        |  Returns the first index at which a given element can be found in the array                                                   |
| `lastIndexOf`    |  Returns the last index at which a given element can be found in the array                                                    |
| `filter`         |  Creates a copy of a array filtered down to just the elements from that pass the test implemented by the provided function    |
| `find`           |  Returns the first element in the array that satisfies the provided testing function                                          |
| `findLast`       |  Iterates the array in reverse order and returns the value of the first element that satisfies the provided testing function  |
| `findIndex`      |  Returns the index of the first element in an array that satisfies the provided testing function                              |
| `findLastIndex`  |  Cterates the array in reverse order and returns the index of the first element that satisfies the provided testing function  |
| `map`            |  Creates a copy of an array start to end populated with the results of calling a provided function on every element           |
| `forEach`        |  Executes a provided function once for each array element                                                                     |
| `reverse`        |  Swaps the elements in the array mirrorwise                                                                                   |
| `some`           |  Tests whether at least one element in the array passes the test implemented by the provided function                         |
| `every`          |  Tests whether all elements in the array pass the test implemented by the provided function                                   |

List of functions for `filter`, `find`, `findLast`, `findIndex`, `findLastIndex`, `some`, `every`:

| Name    |  Description |
| ------- |  ----------- |
| `lt`    |  a < b       |
| `gt`    |  a > b       |
| `eq`    |  a == b      |
| `neq`   |  a != b      |
| `lte`   |  a <= b      |
| `gte`   |  a >= b      |

List of functions for `map` and `forEach`:

| Name    |  Description     |
| ------- |  --------------  |
| `add`   |  result = a + b  |
| `sub`   |  result = a - b  |
| `mul`   |  result = a * b  |
| `div`   |  result = a / b  |
| `mod`   |  result = a % b  |
| `pow`   |  result = a**b   |
| `xor`   |  result = a ^ b  |

### Usage

```solidity
pragma solidity ^0.8.0;

import { Uint256Array, lt, pow } from "array-solidity-lib/Uint256Array.sol";

contract Contract {
    using Uint256Array for Uint256Array.CustomArray;

    Uint256Array.CustomArray private u256;

    constructor() {
        assembly {
            // Initializing an array slot
            mstore(0x00, u256.slot)
            sstore(add(u256.slot, 0x01), keccak256(0x00, 0x20))
        }
    }

    function push(uint256 value) external {
        u256.push(value);
    }

    function filter() external view returns(uint256[] memory array) {
        array = u256.filter(lt, 10);
    }

    function map() external view returns(uint256[] memory array) {
        array = u256.map(pow, 5);
    }
}
```

## License

This project is licensed under MIT.