// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.26;

contract Counter {
    uint256 private counter;

    function add(uint256 i) public {
        counter += 1;
    }

    function get() public view returns(uint) {
        return counter;
    }

}

contract CounterV2 {
     uint256 private counter;

    function add(uint256 i) public {
        counter += i;
    }

    function get() public view returns(uint) {
        return counter;
    }
}

contract CounterProxy {
    uint256 private counter;
    address private impl;

    function upgradeImpl(address impl_) public {
        impl = impl_;
    }

    function add(uint256 i) public {
        bytes memory callData = abi.encodeWithSignature("add(uint256)", i);
        (bool ok,) = address(impl).delegatecall(callData);
        if (!ok) revert("Delegate call failed");
    }

    function get() public returns (uint) {
        bytes memory callData = abi.encodeWithSignature("get()");
        (bool ok, bytes memory retVal) = address(impl).delegatecall(callData);
        if(!ok) revert("Delegate call failed");
        return abi.decode(retVal, (uint256));
    }

}