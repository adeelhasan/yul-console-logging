# Log To Console in Yul

When writing a pure Yul contract, it can be helpful to write out to the console ala the hardhat console. For example:

```solidity

//from within yul code
logString(memPtr, "log the calldata size", 21)
logNumber(memPtr, calldatasize())

```
Which will print a string and a number in the terminal (when running a test with -vvv (or -vvvv) in Foundry.)

## Usage

Copy and paste functions from ConsoleLogging.yul into your own contract. You will also need the utility functions towards the bottom of this file.

If you run the tests on this project, you will see sample output for supported formats.


## How it works
Logging works via a static call to the console contract which is deployed on the test network. Depending on what constitutes the output, the appropriate function on that contract needs to be called. This in turn emits events captured by the development process and then shown on the console/terminal.

The contract is here:
[https://github.com/NomicFoundation/hardhat/blob/main/packages/hardhat-core/console.sol](https://github.com/NomicFoundation/hardhat/blob/main/packages/hardhat-core/console.sol)

So eg, for you to output a string, the selector is 0x0bb563d6, corresponding to ```function logString(string memory p0)```.

If you need to log a string, int and bool you would call ```function log(string memory p0, uint256 p1, bool p2)``` following the same template.

## Point to note
Since the static call is prepared in memory, we have to be mindful of collisions. Thus most functions take in a memPtr which is used as the point to prepare data. The exception are those functions which print a message on a revert, when 0x00 can be used by default.

## Acknowledgements

This repo was inspired by [@AmadiMichael's ](https://github.com/AmadiMichael)[Huff-Console](https://github.com/AmadiMichael/Huff-Console).

Thanks also to [@jeffreyscholz](https://github.com/jeffreyscholz) for his help.
