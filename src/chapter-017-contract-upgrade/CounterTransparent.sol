// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

// logicAddress 为代理合约将要指向的实现合约
contract Counter {
    uint256 public count;

    function increment() public {
        count += 1;
    }

    function decrement() public {
        require(count > 0, "Counter: count is zero");
        count -= 1;
    }
}

contract OwnableProxyAdmin is Ownable, ProxyAdmin {
   constructor(address initialOwner) ProxyAdmin(initialOwner) {
   }
}

contract MyTransparentUpgradeableProxy is TransparentUpgradeableProxy {
    constructor(address _logic, address _admin, bytes memory _data) TransparentUpgradeableProxy(
        _logic,
        _admin,
        _data
    ) {

    }
}