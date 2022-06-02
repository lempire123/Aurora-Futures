// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AuroraFutures} from "../src/AuroraFutures.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import "forge-std/Test.sol";

abstract contract HelperContract {
    IERC20 constant aurora = IERC20(0x8BEc47865aDe3B172A928df8f990Bc7f2A3b9f79);
    address constant Foundation = address(0xbDC8d033c1a581E31c81A47eD6220170297136D8);
    address constant randAddress = address(0xfB1820b9EA4D291f1Af22a99ab38926E18FD6C9D);
    AuroraFutures futures;
}

contract ContractTest is Test, HelperContract {
    function setUp() public {
        futures = new AuroraFutures(
            block.timestamp + 100,
            Foundation,
            "Aurora-Futures",
            "Aurora-Futures",
            address(aurora)
        );

    }

    // ============================
    //         SHOULD PASS
    // ============================
    
    function testDeposit() public {
        vm.startPrank(Foundation);
        aurora.approve(address(futures), 10);
        futures.depositUnderlyingTokens(10);
        assertEq(futures.balanceOf(Foundation), 10);
    }

    function testWithdraw() public {
        vm.startPrank(Foundation);
        aurora.approve(address(futures), 10);
        futures.depositUnderlyingTokens(10);
        vm.warp(block.timestamp + 1000); // Changes timestamp
        uint256 bal = aurora.balanceOf(Foundation);
        futures.redeemAll();
        assertEq(aurora.balanceOf(Foundation), bal + 10);
    }

    // ============================
    //         SHOULD FAIL
    // ============================

    function testCannotDepositIfNotFoundation() public {
        vm.startPrank(randAddress);
        aurora.approve(address(futures), 10);
        vm.expectRevert("Caller must be auroraFoundation");
        futures.depositUnderlyingTokens(100);
    }

    function testCannotWithdrawBeforeMaturity() public {
        vm.startPrank(Foundation);
        aurora.approve(address(futures), 10);
        futures.depositUnderlyingTokens(10);
        vm.expectRevert("Maturity date not reached");
        futures.redeemAll();
    }
}
