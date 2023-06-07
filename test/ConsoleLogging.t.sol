// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/console.sol";
import "forge-std/Test.sol";
import "src/ConsoleLoggingWrapper.sol";
import "./lib/YulDeployer.sol";


contract ERC1155Test is Test {
    YulDeployer yulDeployer = new YulDeployer();

    IYulContract yulContract;
    ConsoleLoggingWrapper contractWrapper;

    uint256[] ids = [1, 2, 3];

    function setUp() public {
        yulContract = IYulContract(yulDeployer.deployContract("ConsoleLogging"));
        contractWrapper = new ConsoleLoggingWrapper(yulContract);
    }

    function testLogToConsole() public {
        contractWrapper.logCalldata("abcdefgh",56, ids);
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

}

