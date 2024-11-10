// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import { Counter, OwnableProxyAdmin } from "src/chapter-017-contract-upgrade/CounterTransparent.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

contract CounterProxyTest is Test {
    OwnableProxyAdmin proxyAdmin;
    ITransparentUpgradeableProxy proxy;
    // ITransparentUpgradeableProxy iproxy;

    Counter counterLogic;
    Counter newCounterLogic;
    Counter counterProxy; // 用于通过代理合约与逻辑合约交互

    address admin;
    address nonAdmin;
    function setUp() public {

        admin = address(this);
        nonAdmin = address(0x123);

        proxyAdmin = new OwnableProxyAdmin(admin);
        proxyAdmin.transferOwnership(admin);
        counterLogic = new Counter();

        proxy = ITransparentUpgradeableProxy(address(new TransparentUpgradeableProxy(
            address(counterLogic),
            address(proxyAdmin),
            ""
        )));


        // 使用 Counter ABI 将代理地址实例化为 counterProxy
        counterProxy = Counter(address(proxy));
    }

    function testInitialCount() public view {
        uint256 initialCount = counterProxy.count();
        console.log(initialCount);
        assertEq(initialCount, 0, "Initial count should be 0");
    }

    function testIncrement() public {
        // 测试通过代理调用 increment
        counterProxy.increment();
        uint256 updatedCount = counterProxy.count();
        assertEq(updatedCount, 1, "Count should be incremented by 1");
    }

    function testDecrement() public {
        // 先 increment 再 decrement，检查计数是否正确
        counterProxy.increment(); // +1 = 1
        counterProxy.decrement(); // -1 = 0
        uint256 updatedCount = counterProxy.count(); // 0
        assertEq(updatedCount, 0, "Count should be decremented back to 0");
    }

    function testUpgradeAndCallWithEmptyData() public {
        // 部署新 Counter 逻辑合约
        newCounterLogic = new Counter();
        // 使用 ProxyAdmin 的 upgradeAndCall 方法进行升级，但不传递初始化数据
        proxyAdmin.upgradeAndCall{value: 0}(proxy, address(newCounterLogic), "");
        // 升级后确保功能正常
        counterProxy.increment();
        uint256 countAfterUpgrade = counterProxy.count();
        assertEq(countAfterUpgrade, 1, "New Counter logic should work after upgrade");
    }


}