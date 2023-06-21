# Log To Console in Yul

When writing a pure Yul contract, it can be helpful to write out to the console ala the hardhat console. For example:

```solidity

//from within yul code
logString(memPtr, "log the calldata size", 21)
logNumber(memPtr, calldatasize())

```
Which will print a string and a number in the terminal (when running a test with -vvv (or -vvvv) in Foundry.)

## Points to note:
Logging works via a static call to the console contract (which in turn emits events captured by the dev process) which is deployed on the test network. Memory is needed to be prepared for this call. 

There is thus a memPtr parameter for the calls, and depending on the context, the memPtr parameter could be 0x00 or it could be it far off to avoid collisions.

These are some of the main functions:

- logString(stringLiteral, lengthOfString)

- logCalldata

- requireWithMessage
```yul
requireWithMessage(someCondition(), "condition was false", 18)
```

- revertWithReason


# Acknowledgements

This repo was inspired by [Huff-Console](https://github.com/AmadiMichael/Huff-Console), by [Michael Amadi](https://github.com/AmadiMichael).

Thanks also to [Jeffrey Scholz](https://github.com/jeffreyscholz) for his help.
