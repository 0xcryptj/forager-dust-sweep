// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {ForagerDustSweepRouter} from "../src/ForagerDustSweepRouter.sol";

contract ForagerDustSweepRouterTest is Test {
    address internal constant PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;
    address internal constant WETH = 0x4200000000000000000000000000000000000006;
    address internal collector = makeAddr("collector");
    address internal owner = makeAddr("owner");

    function test_constructor_sets_fee_and_owner() public {
        ForagerDustSweepRouter router =
            new ForagerDustSweepRouter(PERMIT2, WETH, owner, collector, 200);
        assertEq(router.owner(), owner);
        assertEq(router.feeCollector(), collector);
        assertEq(router.feeBps(), 200);
        assertEq(address(router.permit2()), PERMIT2);
        assertEq(address(router.weth()), WETH);
    }

    function test_fee_cap_300() public {
        vm.expectRevert(ForagerDustSweepRouter.FeeTooHigh.selector);
        new ForagerDustSweepRouter(PERMIT2, WETH, owner, collector, 301);
    }

    function test_owner_can_setFeeCollector() public {
        ForagerDustSweepRouter router =
            new ForagerDustSweepRouter(PERMIT2, WETH, owner, collector, 200);
        address next = makeAddr("nextCollector");
        vm.prank(owner);
        router.setFeeCollector(next);
        assertEq(router.feeCollector(), next);
    }
}
