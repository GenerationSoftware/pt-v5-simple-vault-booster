// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import { IPrizePool } from "./external/IPrizePool.sol";
import { IERC20 } from "openzeppelin/token/ERC20/IERC20.sol";
import { SafeERC20 } from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import { Ownable } from "openzeppelin/access/Ownable.sol";
import { ILiquidationSource } from "pt-v5-liquidator-interfaces/ILiquidationSource.sol";
import { ILiquidationPair } from "pt-v5-liquidator-interfaces/ILiquidationPair.sol";

error OnlyLiquidationPair(ILiquidationPair liquidationPair);
error InsufficientBalance();
error TokenOutInvalid();

/**
 * @title SimpleVaultBooster
 * @notice Boosts a vaults chances to win by liquidating tokens. This contract is a ILiquidationSource and ILiquidationPairs can be added to liquidate any ERC20 held by this contract.
 */ 
contract SimpleVaultBooster is ILiquidationSource, Ownable {
  using SafeERC20 for IERC20;

  mapping(address token => ILiquidationPair liquidationPair) public liquidationPairs;

  address public immutable vault;
  IPrizePool public immutable prizePool;

  /**
   * @param _vault Address of the vault to boost
   * @param _prizePool Address of the prize pool to contribute to
   * @dev The msg.sender becomes the owner
   */
  constructor(address _vault, IPrizePool _prizePool, address _owner) Ownable(_owner) {
    vault = _vault;
    prizePool = _prizePool;
  }

  /**
   * @notice Set the liquidation pair for a token. Can only be called by the owner
   * @param _tokenOut Address of the token that is being liquidated
   * @param _liquidationPair Address of the liquidation pair that will liquidate the token
   */
  function setLiquidationPair(address _tokenOut, ILiquidationPair _liquidationPair) external onlyOwner {
    if (address(_liquidationPair) == address(0)) {
      liquidationPairs[_tokenOut] = ILiquidationPair(address(0));
    } else if (_liquidationPair.tokenOut() != _tokenOut) {
      revert TokenOutInvalid();
    } else {
      liquidationPairs[_tokenOut] = _liquidationPair;
    }
  }

  /**
   * @notice Get the available amount of tokens that can be swapped.
   * @param tokenOut Address of the token to get available balance for
   * @return uint256 Available amount of `token`
   */
  function liquidatableBalanceOf(address tokenOut) public view returns (uint256) {
    return IERC20(tokenOut).balanceOf(address(this));
  }

  /**
   * @notice Transfers tokens to the receiver
   * @param sender Address that triggered the liquidation
   * @param receiver Address of the account that will receive `tokenOut`
   * @param tokenOut Address of the token being bought
   * @param amountOut Amount of token being bought
   */
  function transferTokensOut(
    address sender,
    address receiver,
    address tokenOut,
    uint256 amountOut
  ) external onlyLiquidationPair(tokenOut) returns (bytes memory) {
    if(amountOut > liquidatableBalanceOf(tokenOut)) {
      revert InsufficientBalance();
    }
    IERC20(tokenOut).safeTransfer(receiver, amountOut);
  }

  /**
   * @notice Contributes the liquidated tokens to the prize pool. It assumes the tokens have already been transferred to the prize pool.
   * @param tokenIn Address of the token that was sent (should be the prize token)
   * @param amountIn Amount of tokens being contributed
   * @param transferTokensOutData Data returned by the corresponding transferTokensOut call
   */
  function verifyTokensIn(
    address tokenIn,
    uint256 amountIn,
    bytes calldata transferTokensOutData
  ) external {
    prizePool.contributePrizeTokens(vault, amountIn);
  }

  /**
   * @notice Get the address that will receive `tokenIn`.
   * @param tokenIn Address of the token to get the target address for
   * @return address Address of the target
   */
  function targetOf(address tokenIn) external returns (address) {
    return address(prizePool);
  }

  /**
   * @notice Checks if a liquidation pair can be used to liquidate the given tokenOut from this source.
   * @param _tokenOut The address of the token to liquidate
   * @param _liquidationPair The address of the liquidation pair that is being checked
   * @return bool True if the liquidation pair can be used, false otherwise
   */
  function isLiquidationPair(address _tokenOut, address _liquidationPair) public returns (bool) {
    return address(liquidationPairs[_tokenOut]) == _liquidationPair;
  }

  modifier onlyLiquidationPair(address _tokenOut) {
    if(!isLiquidationPair(_tokenOut, msg.sender)) {
      revert OnlyLiquidationPair(liquidationPairs[_tokenOut]);
    }
    _;
  }

}
