pragma solidity 0.8.15;

interface IYulContract {

    function logToConsoleTests(string memory message, uint256 number, address account) external;
    function logMemory(string memory message) external;
    function logCalldata(string memory message, uint256 number, uint256[] memory ids) external;
    function logCalldataWithSelector(string memory message, uint256 number) external;
    function logString() external;
    function logNumber() external;
    function logAddress() external;
    function logCalldataByOffset(uint256 param1, uint256 param2) external;
}

contract ConsoleLoggingWrapper {
    IYulContract public target;

    constructor(IYulContract _target) {
        target = _target;        
    }

    function logString() external {
        target.logString();
    }

    function logNumber() external {
        target.logNumber();
    }

    function logToConsoleTests(string memory message, uint256 number, address account) external {
        target.logToConsoleTests(message, number, account);
    }
    function logMemory(string memory message) external {
        target.logMemory(message);
    }

    function logCalldata(string memory message, uint256 number, uint256[] memory ids) external {
        target.logCalldata(message, number, ids);
    }

    function logCalldataWithSelector(string memory message, uint256 number) external {
        target.logCalldataWithSelector(message, number);
    }

    function logAddress() external {
        target.logAddress();
    }

    function logCalldataByOffset(uint256 param1, uint256 param2) external {
        target.logCalldataByOffset(param1, param2);
    }


}

