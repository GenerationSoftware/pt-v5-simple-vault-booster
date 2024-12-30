# PoolTogether V5 Simple Vault Booster

[![Code Coverage](https://github.com/generationsoftware/pt-v5-simple-vault-booster/actions/workflows/coverage.yml/badge.svg)](https://github.com/generationsoftware/pt-v5-simple-vault-booster/actions/workflows/coverage.yml)
[![built-with openzeppelin](https://img.shields.io/badge/built%20with-OpenZeppelin-3677FF)](https://docs.openzeppelin.com/)
![MIT license](https://img.shields.io/badge/license-MIT-blue)

The Simple Vault Booster makes it easy to liquidate any token to boost a Vault's contributions to a Prize Pool.

# Deployments

| Chain | Contract |
|---- | ---- |
| Base | [SimpleVaultBoosterFactory](https://basescan.org/address/0x38449a6b7bb76638452273925c9a2BA818bD130d)
| Optimism | [SimpleVaultBoosterFactory](https://optimistic.etherscan.io/address/0xeFDFB75DE853c3b1a37B521956037f44a35CD176)

# Usage

**Step 1**

Create a Simple Vault Booster using the Simple Vault Booster Factory for the vault and prize pool you wish.

```
simpleVaultBoosterFactory.createSimpleVaultBooster(vault, prizePool)
```

**Step 2**

Attach a liquidation pair to the newly created Simple Vault Booster for the token you wish to liquidate:

```
simpleVaultBooster.setLiquidationPair(weth, liquidationPair)
```

Some liquidation pair options:

- [Time Period Dutch Auction Liquidator](https://github.com/GenerationSoftware/pt-v5-tpda-liquidator)
- [Fixed Price Liquidator](https://github.com/generationSoftware/pt-v5-fixed-price-liquidator)

**Step 3**

3. Transfer the given token to the Simple Vault Booster. Liquidation bots will eventually pick it up!
