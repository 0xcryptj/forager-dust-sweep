# ForagerDustSweepRouter

Forager's Base dust-sweep router. It is an independent fork of the Base-verified DustSwapSweepRouter V3 (`0x06e6BAa61A5Da1E4469FCa5dEa3EB68324255E20`). It is not affiliated with or endorsed by DustSwap.

The contract hard-caps the fee at 300 bps (3%). The deployment uses 200 bps (2%) and Forager's Base fee collector.

## Deployed

| | |
| --- | --- |
| Chain | Base mainnet (8453) |
| Contract | `0xe353E79433E2BE7CB410072cF6472999E7B0Dcb0` |
| Blockscout | https://base.blockscout.com/address/0xe353E79433E2BE7CB410072cF6472999E7B0Dcb0 |
| Fee collector | `0x2db772BB8F0e01Ea259011C600eD6F685A29aD51` |

The local `forge` artifact for this source has the same length and the same Solidity metadata hash as the code at that address. The bytecode is not byte-identical: constructor immutables differ from a compile that used different constructor arguments. Auditors should diff `eth_getCode` against a build that uses the deployment's constructor arguments.

## Build

```bash
forge install foundry-rs/forge-std
forge build
forge test --match-contract ForagerDustSweepRouterTest
```

`script/Deploy.s.sol` reads `PRIVATE_KEY` from the environment. Do not commit a `.env`.

## License

MIT
