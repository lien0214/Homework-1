// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StudentV1 {
    uint256 private registerCallCount = 0;
    function register() external returns (uint256) {
        registerCallCount++;
        return (registerCallCount % 2 == 0) ? 123 : 1001;
    }
}

interface IClassroomV2 {
    function isEnrolled() external view returns (bool);
}

contract StudentV2 {
    function register() external view returns (uint256) {
        IClassroomV2 class = IClassroomV2(msg.sender);
        return class.isEnrolled() ? 123 : 1001;
    }
}

/* Problem 3 Interface & Contract */
contract StudentV3 {
    function register() external view returns (uint256) {
        return gasleft() <= 6635 ? 123 : gasleft();
    }
}

