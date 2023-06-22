object "ConsoleLogging" {
    code {

        datacopy(0, dataoffset("Runtime"), datasize("Runtime"))
        return(0, datasize("Runtime"))
    }
    object "Runtime" {

        code {

            // Dispatcher
            switch shr(0xe0, calldataload(0))
                case 0xe225cb96 {
                    logCalldata(0x00, true) //without selector
                }
                case 0xb4d33467 {
                    logCalldata(0x00, false) //with selector
                }
                case 0xd0dc7b4b {
                    logString(0x00, "A string can only be a literal", 30)
                }
                case 0x9f2c436f {   //logNumber from the solidity test wrapper
                    logNumber(0x00, 55)
                }
                case 0x465d521a { //logAddress call from the solidity test wrapper
                    logAddress(0x00, caller())
                }
                case 0x1cbbeb66 {   //logCalldataByOffset, example is to log the second word in calldata
                    logCalldataByOffset(0x00, 0x24)
                }
                case 0xeffad529 {   //log memory
                    // copy some bytes from calldata, which is expected to be a single string parameter
                    // only log the data part of the string that was passed in
                    // note that we setup the log call away from the memory where the call data is copied
                    calldatacopy(0x00, 0x44, 0x20)
                    logMemory(0xa0, 0x00, 0x20)
                }
                default {
                    revertWithReason("unimplemented selector", 22)
                }


            /// @dev memPtr is not needed, since we are halting and collisions are moot
            /// @param reason has to be a string literal
            /// @param reasonLength length of the literal
            function revertWithReason(reason, reasonLength) {
                let ptr := 0x00 //since we are going to abort, can use memory at 0x00
                mstore(ptr, shl(0xe0,0x08c379a)) // Selector for method Error(string)
                mstore(add(ptr, 0x04), 0x20) // String offset
                mstore(add(ptr, 0x24), reasonLength) // Revert reason length
                mstore(add(ptr, 0x44), reason)
                revert(ptr, 0x64)
            }

            /// @notice emulates the solidity require statement
            /// @dev eg, requireWithMessage(iszero(callvalue()),"ether not accepted", 18)
            function requireWithMessage(condition, reason, reasonLength) {
                if iszero(condition) { 
                    revertWithReason(reason, reasonLength)
                }
            }

            /// @notice just logs out a string
            /// @dev restricted to a string literal
            function logString(memPtr, message, lengthOfMessage) {
                mstore(memPtr, shl(0xe0,0x0bb563d6))        //selector for function logString(string memory p0) 
                mstore(add(memPtr, 0x04), 0x20)             //offset
                mstore(add(memPtr, 0x24), lengthOfMessage)  //length
                mstore(add(memPtr, 0x44), message)          //data
                pop(staticcall(gas(), consoleContractAddress(), memPtr, 0x64, 0x00, 0x00))
            }

            /// @notice writes out one word from calldata at the given offset
            /// @param memPtr where the call to the logging contract should be prepared
            function logCalldataByOffset(memPtr, offset) {
                mstore(memPtr, shl(0xe0, 0xe17bf956))   //selector for function logBytes(bytes memory p0)
                mstore(add(memPtr, 0x04), 0x20)
                mstore(add(memPtr, 0x24), 0x20)
                calldatacopy(add(memPtr, 0x44), offset, 0x20)
                pop(staticcall(gas(), consoleContractAddress(), memPtr, 0x64, 0x00, 0x00))
            }

            /// @notice writes out all of call data. skipping the selector aligns the output
            /// for good readability
            /// @param memPtr where the call is prepared
            /// @param skipSelector whether or not to print the method selector
            function logCalldata(memPtr, skipSelector) {
                //the "request header" remains the same, we keep
                //sending 32 bytes to the console contract
                mstore(memPtr, shl(0xe0, 0xe17bf956))   //selector for function logBytes(bytes memory p0)
                mstore(add(memPtr, 0x04), 0x20)
                mstore(add(memPtr, 0x24), 0x20)

                let dataLength := calldatasize()
                let calldataOffset := 0x00
                if skipSelector {
                    dataLength := sub(dataLength, 4)
                }
                let dataLengthRoundedToWord := roundToWord(dataLength)
                
                for { let i := 0 } lt(i, dataLengthRoundedToWord) { i:= add(i, 1) } {
                    calldataOffset := mul(i, 0x20)
                    if skipSelector {
                        calldataOffset := add(calldataOffset,0x04)
                    }    
                    calldatacopy(add(memPtr, 0x44), calldataOffset, 0x20)
                    pop(staticcall(gas(), consoleContractAddress(), memPtr, 0x64, 0x00, 0x00))
                }
            }

            function logAddress(memPtr, addressValue) {
                mstore(memPtr, shl(0xe0, 0xe17bf956))   //selector for function logBytes(bytes memory p0)
                mstore(add(memPtr, 0x04), 0x20)
                mstore(add(memPtr, 0x24), 0x20)
                mstore(add(memPtr, 0x44), addressValue)
                pop(staticcall(gas(), consoleContractAddress(), memPtr, 0x64, 0x00, 0x00))
            }

            /// @notice writes out a desired snapshot of memory
            /// @dev whole word (ie. 32 bytes) is written out, so if the length is not an even number
            /// the difference is padded with 0s
            function logMemory(memPtr, startingPointInMemory, length) {
                mstore(memPtr, shl(0xe0, 0xe17bf956))   //selector for function logBytes(bytes memory p0)
                mstore(add(memPtr, 0x04), 0x20)
                mstore(add(memPtr, 0x24), length)
                let dataLengthRoundedToWord := roundToWord(length)
                let memOffset := 0x00
                for { let i := 0 } lt(i, dataLengthRoundedToWord) { i:= add(i, 1) } {
                    memOffset := mul(i, 0x20)
                    mstore(add(memPtr, 0x44), mload(add(startingPointInMemory,memOffset)))
                    pop(staticcall(gas(), consoleContractAddress(), memPtr, 0x64, 0x00, 0x00))
                }                
            }
            
            /// @notice simply prints the number out
            /// @param memPtr
            /// @param _number this is any 32 byte value
            function logNumber(memPtr, _number) {
                mstore(memPtr, shl(0xe0,0x9905b744))    //select for function logUint(uint256 p0)
                mstore(add(memPtr, 0x04), _number)
                pop(staticcall(gas(), consoleContractAddress(), memPtr, 0x24, 0x00, 0x00))
            }

            /* ---------- utility functions ---------- */

            function require(condition) {
                if iszero(condition) { revert(0, 0) }
            }

            function roundToWord(length) -> numberOfWords {
                numberOfWords := div(length, 0x20)
                if gt(mod(length,0x20),0) {
                    numberOfWords := add(numberOfWords, 1)
                }
            }

            function consoleContractAddress() -> a {
                a := 0x000000000000000000636F6e736F6c652e6c6f67
            }

        }
    }
  }

