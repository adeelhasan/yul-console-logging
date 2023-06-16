// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/console.sol";
import "forge-std/Test.sol";
import "src/ConsoleLoggingWrapper.sol";
import "./lib/YulDeployer.sol";


contract ConsoleLoggingTest is Test {
    YulDeployer yulDeployer = new YulDeployer();

    IYulContract yulContract;
    ConsoleLoggingWrapper contractWrapper;

    function setUp() public {
        yulContract = IYulContract(yulDeployer.deployContract("ConsoleLogging"));
        contractWrapper = new ConsoleLoggingWrapper(yulContract);
    }

    function testLogString() public {
        contractWrapper.logString();
    }

    function testLogNumber() public {
        contractWrapper.logNumber();
    }

    function testLogMemory() public {
        console.log("output shoud show a sequence");
        contractWrapper.logMemory("ABCDEFG");
    }

    function testLogAddress() public {
        console.log("Log an address:");
        //contractWrapper.logAddress(address(yulDeployer));
        contractWrapper.logAddress();
    }

    function testCalldataByOffset() public {
        console.log("Log the second parameter:");
        //contractWrapper.logAddress(address(yulDeployer));
        contractWrapper.logCalldataByOffset(1,2);
    }


    function testLogCalldataWithoutSelector() public {
        uint256[] memory ids = new uint256[](3);
        ids[0] = 1;
        ids[1] = 2;
        ids[2] = 3;
        contractWrapper.logCalldata("abcdefgh",56, ids);
    }

    function testLogCalldataWithSelector() public {
        contractWrapper.logCalldataWithSelector("abcdefgh",56);
    }

}

