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

## Ouput from tests

```console
[PASS] testCalldataByOffset() (gas: 14063)
Logs:
  Log the second parameter:
  0x0000000000000000000000000000000000000000000000000000000000000002

[PASS] testLogAddress() (gas: 13992)
Logs:
  Log an address:
  0x0000000000000000000000002e234dae75c793f67a35089c9d99245e1c58470b

[PASS] testLogCalldataWithSelector() (gas: 15446)
Logs:
  0xb4d3346700000000000000000000000000000000000000000000000000000000
  0x0000004000000000000000000000000000000000000000000000000000000000
  0x0000003800000000000000000000000000000000000000000000000000000000
  0x0000000861626364656667680000000000000000000000000000000000000000
  0x0000000000000000000000000000000000000000000000000000000000000000

[PASS] testLogCalldataWithoutSelector() (gas: 18276)
Logs:
  0x0000000000000000000000000000000000000000000000000000000000000060
  0x0000000000000000000000000000000000000000000000000000000000000038
  0x00000000000000000000000000000000000000000000000000000000000000a0
  0x0000000000000000000000000000000000000000000000000000000000000008
  0x6162636465666768000000000000000000000000000000000000000000000000
  0x0000000000000000000000000000000000000000000000000000000000000003
  0x0000000000000000000000000000000000000000000000000000000000000001
  0x0000000000000000000000000000000000000000000000000000000000000002
  0x0000000000000000000000000000000000000000000000000000000000000003

[PASS] testLogMemory() (gas: 15067)
Logs:
  output shoud show a sequence
  0x4142434445464700000000000000000000000000000000000000000000000000

[PASS] testLogNumber() (gas: 13244)
Logs:
  55

[PASS] testLogString() (gas: 13173)
Logs:
  A string can only be a literal

```