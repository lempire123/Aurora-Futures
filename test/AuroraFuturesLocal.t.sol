// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AuroraFutures} from "../src/AuroraFutures.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

import "forge-std/Test.sol";

contract ContractLocalTest is Test {
    AuroraFutures futures;
    address Foundation = address(1);
    address rand = address(2);
    ERC20 aurora = new ERC20("Aurora","AUR");

    function setUp() public {
        futures = new AuroraFutures(
            block.timestamp + 100,
            Foundation,
            "Aurora-Futures",
            "Aurora-Futures",
            address(aurora)
        );
        deal(address(aurora), Foundation, 1000);
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
        vm.startPrank(rand);
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