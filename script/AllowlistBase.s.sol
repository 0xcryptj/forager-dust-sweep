// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {ForagerDustSweepRouter} from "../src/ForagerDustSweepRouter.sol";

/// @notice Base mainnet DEX + aggregator allowlist (targets + spenders).
/// Permit2 is spender-only (Universal Router / V4 pull path).
/// Broadcast: ROUTER=0x... forge script script/AllowlistBase.s.sol:AllowlistBase --rpc-url $BASE_RPC_URL --broadcast
contract AllowlistBase is Script {
    uint256 internal constant BASE_MAINNET = 8453;

    function run() external {
        require(block.chainid == BASE_MAINNET, "AllowlistBase: Base mainnet only");

        address routerAddr = vm.envAddress("ROUTER");
        uint256 pk = vm.envUint("PRIVATE_KEY");
        ForagerDustSweepRouter router = ForagerDustSweepRouter(payable(routerAddr));
        require(router.owner() == vm.addr(pk), "AllowlistBase: deployer is not owner");

        address permit2 = vm.envAddress("PERMIT2");
        address[] memory targets = _targets();
        address[] memory spenders = _spenders();

        vm.startBroadcast(pk);
        for (uint256 i = 0; i < targets.length; ++i) {
            if (!router.allowedTargets(targets[i])) {
                router.setAllowedTarget(targets[i], true);
            }
        }
        for (uint256 i = 0; i < spenders.length; ++i) {
            if (!router.allowedSpenders(spenders[i])) {
                router.setAllowedSpender(spenders[i], true);
            }
        }
        if (!router.allowedSpenders(permit2)) {
            router.setAllowedSpender(permit2, true);
        }
        vm.stopBroadcast();

        for (uint256 i = 0; i < targets.length; ++i) {
            console2.log("target", targets[i], router.allowedTargets(targets[i]));
        }
        for (uint256 i = 0; i < spenders.length; ++i) {
            console2.log("spender", spenders[i], router.allowedSpenders(spenders[i]));
        }
        console2.log("permit2 spender", permit2, router.allowedSpenders(permit2));
    }

    /// Universal Routers are targets only; they pull via Permit2 (spender).
    function _targets() internal pure returns (address[] memory list) {
        list = new address[](12);
        list[0] = 0x6fF5693b99212Da76ad316178A184AB56D299b43; // Uniswap Universal Router (V3+V4)
        list[1] = 0x2626664c2603336E57B271c5C0b26F421741e481; // Uniswap V3 SwapRouter02
        list[2] = 0x6Cb442acF35158D5eDa88fe602221b67B400Be3E; // Aerodrome Universal Router
        list[3] = 0xcF77a3Ba9A5CA399B7c97c74d54e5b1Beb874E43; // Aerodrome Classic (Solidly)
        list[4] = 0xBE6D8f0d05cC4be24d5167a3eF062215bE6D18a5; // Aerodrome Slipstream SwapRouter
        list[5] = 0x1b81D678ffb9C0263b24A97847620C99d213eB14; // PancakeSwap SmartRouter
        list[6] = 0xe6c9bb24ddB4aE5c6632dbE0DE14e3E474c6Cb04; // QuickSwap Algebra SwapRouter
        list[7] = 0x8c1A3cF8f83074169FE5D7aD50B978e1cD6b37c7; // AlienBase UniV2 Router
        list[8] = 0x195FBc5B8Fbd5Ac739C1BA57D4Ef6D5a704F34f7; // DackieSwap SmartRouter
        list[9] = 0x327Df1E6de05895d2ab08513aaDD9313Fe505d86; // BaseSwap Router
        list[10] = 0x0000000000001fF3684f28c67538d4D072C22734; // 0x AllowanceHolder
        list[11] = 0x1231DEB6f5749EF6cE6943a275A1D3E7486F4EaE; // LI.FI Diamond
    }

    function _spenders() internal pure returns (address[] memory list) {
        list = new address[](10);
        list[0] = 0x2626664c2603336E57B271c5C0b26F421741e481; // Uniswap V3 SwapRouter02
        list[1] = 0xcF77a3Ba9A5CA399B7c97c74d54e5b1Beb874E43; // Aerodrome Classic
        list[2] = 0xBE6D8f0d05cC4be24d5167a3eF062215bE6D18a5; // Aerodrome Slipstream
        list[3] = 0x1b81D678ffb9C0263b24A97847620C99d213eB14; // PancakeSwap SmartRouter
        list[4] = 0xe6c9bb24ddB4aE5c6632dbE0DE14e3E474c6Cb04; // QuickSwap Algebra
        list[5] = 0x8c1A3cF8f83074169FE5D7aD50B978e1cD6b37c7; // AlienBase UniV2
        list[6] = 0x195FBc5B8Fbd5Ac739C1BA57D4Ef6D5a704F34f7; // DackieSwap SmartRouter
        list[7] = 0x327Df1E6de05895d2ab08513aaDD9313Fe505d86; // BaseSwap Router
        list[8] = 0x0000000000001fF3684f28c67538d4D072C22734; // 0x AllowanceHolder
        list[9] = 0x1231DEB6f5749EF6cE6943a275A1D3E7486F4EaE; // LI.FI Diamond
    }
}
