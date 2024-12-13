// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import { 
    SimpleVaultBoosterFactory,
    SimpleVaultBooster,
    IPrizePool
} from "../src/SimpleVaultBoosterFactory.sol";

contract SimpleVaultBoosterTest is Test {

    address vault;
    IPrizePool prizePool;

    SimpleVaultBoosterFactory factory;

    function setUp() public {
        vault = makeAddr("vault");
        prizePool = IPrizePool(makeAddr("prizePool"));
        factory = new SimpleVaultBoosterFactory();
    }

    function testCreateSimpleVaultBooster() public {
        SimpleVaultBooster booster = factory.createSimpleVaultBooster(vault, prizePool, address(this));
        assertEq(booster.vault(), vault);
        assertEq(address(booster.prizePool()), address(prizePool));
    }

}
