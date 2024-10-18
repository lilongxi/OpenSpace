
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;
import "forge-std/Test.sol";
import "forge-std/mocks/MockERC20.sol";
import { OwnerUpOnly } from "src/chapter-007/OwnerUpOnly/index.sol";

contract TestContract is Test {

    function testRoll() public {
        console.log("New Block Number1:", block.number);
        uint newBlockNumber = 100;
        vm.roll(newBlockNumber);
        console.log("New Block Number2:", block.number);
        assertEq(block.number, newBlockNumber);
    }

    function testPRank() public {
        console.log("Current contract address:", address(this));
        OwnerUpOnly n1 = new OwnerUpOnly();
        assertEq(address(this), n1.owner());

        address newSender = 0x7fc93b5620662f523AE2387aE38A444baaE68f88;
        vm.prank(newSender);
        OwnerUpOnly n2 = new OwnerUpOnly();
        assertEq(address(newSender), n2.owner());
    }
    
    function testStartPRank() public {
        address addr = 0x7fc93b5620662f523AE2387aE38A444baaE68f88;

        // 保证整个运行区域上下文一致
        vm.startPrank(addr);

        OwnerUpOnly n1 = new OwnerUpOnly();

        for (uint i = 0; i < 10; i++) {
            n1.increment();
        }

        vm.stopPrank();
        assertEq(n1.counter(), 10);

    }

    // 改变区块时间戳
    function testWrap() public {
        uint newTimeStamp = 1650000000;
        vm.warp(newTimeStamp);

        console.log(block.timestamp);
        assertEq(block.timestamp, newTimeStamp);
        skip(1 seconds);
        console.log(block.timestamp);

    }

    // 重置 ETH 余额
    function testDeal() public {
        address addr = address(0x7fc93b5620662f523AE2387aE38A444baaE68f88);
        uint amount = 100 ether;
        deal(addr, amount);
        console.log(addr.balance);
        deal(addr, amount);
        console.log(addr.balance);
        assertEq(addr.balance, amount);
    }

    // 铸币后设置 到指定账户
    function testMint() public {
        MockERC20 erc20 = new MockERC20();
        erc20.initialize("Test Token", "TST", 18);

        address alice = makeAddr("alice");
        address bob = makeAddr("bob");

        deal(address(erc20), alice, 10000);
        deal(address(erc20), bob, 3000);

        console.log(erc20.balanceOf(alice), erc20.balanceOf(bob));

        assertEq(erc20.balanceOf(alice), 10000);
        assertEq(erc20.balanceOf(bob), 3000);

    }

    function testRevertError() public {
        address addr = address(0x7fc93b5620662f523AE2387aE38A444baaE68f88);
        OwnerUpOnly n1 = new OwnerUpOnly();
        vm.prank(addr);
        // vm.expectRevert(OwnerUpOnly.Unauthorized.selector);
        // vm.expectRevert(abi.encodeWithSignature('Unauthorized()'));
        vm.expectRevert(abi.encodeWithSelector(OwnerUpOnly.Unauthorized.selector));
        n1.incrementV2();
    }

    event Deposit(address indexed user, uint amount);

    // function testERC20EmitBatchTransfer() public {
    //     for (uint i = 0; i < 10; i++) {
    //         /**
    //          * topic0 address(this) always check
    //          * 检查 topic1
    //          * 检查 topic2
    //          * 不检查 topic3
    //          * 检查剩余所有参数
    //          */
    //         vm.expectEmit(true, true, false, true);
    //         emit Deposit(address(0x7fc93b5620662f523AE2387aE38A444baaE68f88), i); 
    //     }
    // }
}