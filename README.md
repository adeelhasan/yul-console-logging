# Log To Console in Yul

When writing a pure Yul contract, it can be helpful to write out to the console ala the hardhat console. For example:

```python

//from within yul code
logString("calldata size", 13)
logNumber(memPtr, calldatasize())

```
Which will print a number in the terminal, when running a test with -vvv (or -vvvv) in Foundry.

<image of what the output would look like>

Points to note:
Logging works via a static call to the console contract (which in turn emits events captured by the dev process) which is deployed on the test network. Memory is needed to be prepared for this call. 

There is thus a memPtr parameter for the calls, and depending on the context, the memPtr parameter could be 0x00 or it could be it far off so as to not disturb what is already there.

These are some of the main functions:

- logString

- logCalldata()

- requireWithMessage
```yul
requireWithMessage(someCondition(), "condition was false", 18)
```

- revertWithReason

# Usage

The functions in /yul/ConsoleLogging.yul are written so you can copy paste a whole function. A handful of the functions also need "roundToWord", and you may need to copy that as well.

# How it works

On the test network, a console contract deployed at a known address. A static call to that address taps into the various functions available. Events emitted from that contract are then received by and displayed on the terminal.

# Acknowledgements

This repo was inspired by Huff.console, by . Thanks also to Jeff Scholz for his help.
