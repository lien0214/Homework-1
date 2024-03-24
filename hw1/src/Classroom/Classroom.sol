// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StudentV1 {
    uint256 private registerCallCount = 0;
    function register() external returns (uint256) {
        registerCallCount++;
        if (registerCallCount % 2 == 1) {
            return 1001;
        } else {
            return 123;
        }
    }
}

interface IClassroomV2 {
    function isEnrolled() external view returns (bool);
}

contract StudentV2 {
    function register() external view returns (uint256) {
        IClassroomV2 class = IClassroomV2(msg.sender);
        if (class.isEnrolled()) {
            return 123;
        }
        else {
            return 1001;
        }
    }
}

/* Problem 3 Interface & Contract */
contract StudentV3 {
    function register() external view returns (uint256) {
        uint256 balance = gasleft();
        if (balance > 6635) {
            return balance;
        }
        else
            return 123;
    }
}

