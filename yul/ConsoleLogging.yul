//  https://github.com/NomicFoundation/hardhat/blob/main/packages/hardhat-core/console.sol
//  Huff console.log
//  Intent


object "ConsoleLogging" {
    code {

        datacopy(0, dataoffset("Runtime"), datasize("Runtime"))
        return(0, datasize("Runtime"))
    }
    object "Runtime" {

        code {
            // ether is not accepted
            require(iszero(callvalue()))

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
                case 0x9f2c436f {
                    logNumber(0x00, 55)
                }
                case 0x465d521a { //logAddress
                    logAddress(0x00, caller())
                }
                case 0x1cbbeb66 {   //logCalldataByOffset, example is to log the second word in calldata
                    logCalldataByOffset(0x00, 0x24)
                    //logCalldata(0x00, false) //with selector
                }
                case 0xeffad529 {   //log memory
                    // copy some bytes from calldata, which is expected to be a single string parameter
                    // only log the data part of the string that was passed in
                    // note that we setup the memory to be logged away from where the log call is prepped
                    calldatacopy(0xa0, 0x44, 0x20)
                    logMemory(0x00, 0xa0, 0x20)
                }
                default {
                    revertWithReason("unimplemented selector", 22)
                }


            //reason is a string literal
            function revertWithReason(reason, reasonLength) {
                let ptr := 0x00 //since we are going to abort, can use memory at 0x00
                mstore(ptr, shl(0xe0,0x08c379a)) // Selector for method Error(string)
                mstore(add(ptr, 0x04), 0x20) // String offset
                mstore(add(ptr, 0x24), reasonLength) // Revert reason length
                mstore(add(ptr, 0x44), reason)
                revert(ptr, 0x64)
            }

            //reason is a string literal
            function requireWithMessage(condition, reason, reasonLength) {
                if iszero(condition) { 
                    revertWithReason(reason, reasonLength)
                }
            }

            //restricted to a string literal
            function logString(memPtr, message, lengthOfMessage) {
                mstore(memPtr, shl(0xe0,0x0bb563d6))        //selector
                mstore(add(memPtr, 0x04), 0x20)             //offset
                mstore(add(memPtr, 0x24), lengthOfMessage)  //length
                mstore(add(memPtr, 0x44), message)          //data
                pop(staticcall(gas(), consoleContractAddress(), memPtr, 0x64, 0x00, 0x00))
            }

            function logCalldataByOffset(memPtr, offset) {
                mstore(memPtr, shl(0xe0, 0xe17bf956))
                mstore(add(memPtr, 0x04), 0x20)
                mstore(add(memPtr, 0x24), 0x20)
                calldatacopy(add(memPtr, 0x44), offset, 0x20)
                //let dataLengthRoundedToWord := roundToWord(length)
                
                pop(staticcall(gas(), consoleContractAddress(), memPtr, 0x64, 0x00, 0x00))
            }

            function logCalldata(memPtr, skipSelector) {
                //the "request header" remains the same, we keep
                //sending 32 bytes to the console contract
                mstore(memPtr, shl(0xe0, 0xe17bf956))
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

            function logAddress2(memPtr, addressValue) {
                mstore(memPtr, shl(0xe0, 0xe17bf956))
                mstore(add(memPtr, 0x04), 0x20)
                mstore(add(memPtr, 0x24), 0x20)
                mstore(add(memPtr, 0x44), addressValue)
                pop(staticcall(gas(), consoleContractAddress(), memPtr, 0x64, 0x00, 0x00))
            }

            function logAddress(memPtr, addressValue) {
                mstore(memPtr, shl(0xe0, 0xe17bf956))
                mstore(add(memPtr, 0x04), 0x20)
                mstore(add(memPtr, 0x24), 0x20)
                mstore(add(memPtr, 0x44), addressValue)
                pop(staticcall(gas(), consoleContractAddress(), memPtr, 0x64, 0x00, 0x00))
            }

            function logMemory(memPtr, startingPointInMemory, length) {
                mstore(memPtr, shl(0xe0, 0xe17bf956))
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
            
            function logNumber(memPtr, _number) {
                mstore(memPtr, shl(0xe0,0x9905b744))
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

