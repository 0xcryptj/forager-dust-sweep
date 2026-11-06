// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {ForagerDustSweepRouter} from "../src/ForagerDustSweepRouter.sol";

/// @notice Broadcast: forge script script/Deploy.s.sol:Deploy --rpc-url $BASE_RPC_URL --broadcast --verify
contract Deploy is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address permit2 = vm.envAddress("PERMIT2");
        address weth = vm.envAddress("WETH");
        address feeCollector = vm.envAddress("FEE_COLLECTOR");
        uint16 feeBps = uint16(vm.envUint("FEE_BPS"));
        address owner = vm.envOr("OWNER", address(0));
        if (owner == address(0)) {
            owner = vm.addr(pk);
        }

        vm.startBroadcast(pk);
        ForagerDustSweepRouter router =
            new ForagerDustSweepRouter(permit2, weth, owner, feeCollector, feeBps);
        vm.stopBroadcast();

        console2.log("ForagerDustSweepRouter", address(router));
        console2.log("owner", router.owner());
        console2.log("feeCollector", router.feeCollector());
        console2.log("feeBps", uint256(router.feeBps()));
        console2.log("permit2", address(router.permit2()));
        console2.log("weth", address(router.weth()));
        console2.log("chainid", block.chainid);
    }
}
