// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import { 
    SimpleVaultBooster,
    ILiquidationSource,
    ILiquidationPair,
    IPrizePool,
    IERC20,
    TokenOutInvalid,
    OnlyLiquidationPair,
    InsufficientBalance,
    Ownable
} from "../src/SimpleVaultBooster.sol";

contract SimpleVaultBoosterTest is Test {

    SimpleVaultBooster booster;
    ILiquidationPair liquidationPair;
    address vault;
    IERC20 prizeToken;
    IPrizePool prizePool;

    function setUp() public {
        prizeToken = IERC20(makeAddr("prizeToken"));
        vault = makeAddr("vault");
        prizePool = IPrizePool(makeAddr("prizePool"));
        vm.mockCall(address(prizePool), abi.encodeWithSelector(prizePool.prizeToken.selector), abi.encode(prizeToken));
        liquidationPair = ILiquidationPair(makeAddr("liquidationPair"));
        vm.mockCall(address(liquidationPair), abi.encodeWithSelector(liquidationPair.tokenOut.selector), abi.encode(prizeToken));

        booster = new SimpleVaultBooster(vault, prizePool, address(this));
        booster.setLiquidationPair(address(prizeToken), liquidationPair);
    }

    function testConstructor() public {
        assertEq(booster.vault(), vault);
        assertEq(address(booster.prizePool()), address(prizePool));
    }

    function testSetLiquidationPair_onlyOwner() public {
        address notOwner = makeAddr("notOwner");
        vm.prank(notOwner);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, notOwner));
        booster.setLiquidationPair(address(prizeToken), ILiquidationPair(address(0)));
    }

    function testSetLiquidationPair_reset() public {
        booster.setLiquidationPair(address(prizeToken), ILiquidationPair(address(0)));
        assertEq(address(booster.liquidationPairs(address(prizeToken))), address(0));
    }

    function testSetLiquidationPair_TokenOutInvalid() public {
        ILiquidationPair invalidLiquidationPair = ILiquidationPair(makeAddr("invalidLiquidationPair"));
        vm.mockCall(address(invalidLiquidationPair), abi.encodeWithSelector(invalidLiquidationPair.tokenOut.selector), abi.encode(makeAddr("invalidToken")));
        vm.expectRevert(abi.encodeWithSelector(TokenOutInvalid.selector));
        booster.setLiquidationPair(address(prizeToken), invalidLiquidationPair);
    }

    function testLiquidatableBalanceOf() public {
        uint256 balance = 100;
        vm.mockCall(address(prizeToken), abi.encodeWithSelector(prizeToken.balanceOf.selector, address(booster)), abi.encode(balance));
        assertEq(booster.liquidatableBalanceOf(address(prizeToken)), balance);
    }

    function testTransferTokensOut_OnlyLiquidationPair() public {
        vm.expectRevert(abi.encodeWithSelector(OnlyLiquidationPair.selector, address(liquidationPair)));
        booster.transferTokensOut(address(this), address(this), address(prizeToken), 50);
    }

    function testTransferTokensOut() public {
        uint256 balance = 100;
        vm.mockCall(address(prizeToken), abi.encodeWithSelector(prizeToken.balanceOf.selector, address(booster)), abi.encode(balance));
        vm.mockCall(address(prizeToken), abi.encodeWithSelector(prizeToken.transfer.selector, address(this), 50), abi.encode(true));
        vm.prank(address(liquidationPair));
        booster.transferTokensOut(address(this), address(this), address(prizeToken), 50);
    }

    function testTransferTokensOut_InsufficientBalance() public {
        uint256 balance = 40;
        vm.mockCall(address(prizeToken), abi.encodeWithSelector(prizeToken.balanceOf.selector, address(booster)), abi.encode(balance));
        vm.prank(address(liquidationPair));
        vm.expectRevert(abi.encodeWithSelector(InsufficientBalance.selector));
        booster.transferTokensOut(address(this), address(this), address(prizeToken), 50);
    }

    function testVerifyTokensIn() public {
        vm.mockCall(address(prizePool), abi.encodeWithSelector(prizePool.contributePrizeTokens.selector, vault, 50), abi.encode(50));
        booster.verifyTokensIn(address(prizeToken), 50, "");
    }

    function testTargetOf() public {
        assertEq(booster.targetOf(address(prizeToken)), address(prizePool));
    }

    function testTargetOf_invalid() public {
        assertEq(booster.targetOf(makeAddr("invalidToken")), address(0));
    }

    function testIsLiquidationPair() public {
        assertEq(booster.isLiquidationPair(address(prizeToken), address(liquidationPair)), true);
    }

    function testIsLiquidationPair_not() public {
        assertEq(booster.isLiquidationPair(address(prizeToken), makeAddr("invalidLiquidationPair")), false);
    }
}
