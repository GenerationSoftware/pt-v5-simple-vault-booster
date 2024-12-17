// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import { 
    SimpleVaultBooster,
    ILiquidationSource,
    IPrizePool,
    IERC20,
    TokenOutInvalid,
    OnlyLiquidationPair,
    InsufficientBalance,
    Ownable
} from "../../src/SimpleVaultBooster.sol";
import {
    SimpleVaultBoosterFactory
} from "../../src/SimpleVaultBoosterFactory.sol";

contract SimpleVaultBoosterTest is Test {

    SimpleVaultBooster booster;
    SimpleVaultBoosterFactory factory;
    address liquidationPair;
    address vault;
    IERC20 prizeToken;
    IPrizePool prizePool;
    uint fork;

    function setUp() public {
        fork = vm.createFork(vm.rpcUrl("base"));
        vm.selectFork(fork);

        prizeToken = IERC20(0x4200000000000000000000000000000000000006);
        vault = 0x6B5a5c55E9dD4bb502Ce25bBfbaA49b69cf7E4dd;
        prizePool = IPrizePool(0x45b2010d8A4f08b53c9fa7544C51dFd9733732cb);
        liquidationPair = address(this);
        factory = new SimpleVaultBoosterFactory();

        booster = factory.createSimpleVaultBooster(vault, prizePool, address(this));
        booster.setLiquidationPair(address(prizeToken), liquidationPair);
    }

    function test() public {
        deal(address(prizeToken), address(booster), 10e18);

        assertEq(booster.liquidatableBalanceOf(address(prizeToken)), 10e18);

        booster.transferTokensOut(address(this), address(this), address(prizeToken), 10e18);

        assertEq(prizeToken.balanceOf(address(this)), 10e18);
    }

}
