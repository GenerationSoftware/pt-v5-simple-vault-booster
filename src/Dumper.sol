// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import { ILiquidationSource } from "pt-v5-liquidator-interfaces/ILiquidationSource.sol";

contract Dumper is ILiquidationSource {

  uint128 dumpAmount;
  uint64 start;
  uint64 end;

  uint64 immutable dumpDurationSeconds;
  IERC20 immutable token;

  address public owner;

  constructor(uint64 _dumpDurationSeconds) {
    dumpDurationSeconds = _dumpDurationSeconds;
  }

  /**
   * @notice Get the available amount of tokens that can be swapped.
   * @param tokenOut Address of the token to get available balance for
   * @return uint256 Available amount of `token`
   */
  function liquidatableBalanceOf(address tokenOut) public returns (uint256) {

    // 

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
  ) external returns (bytes memory);

  /**
   * @notice Verifies that tokens have been transferred in.
   * @param tokenIn Address of the token being sold
   * @param amountIn Amount of token being sold
   * @param transferTokensOutData Data returned by the corresponding transferTokensOut call
   */
  function verifyTokensIn(
    address tokenIn,
    uint256 amountIn,
    bytes calldata transferTokensOutData
  ) external;

  /**
   * @notice Get the address that will receive `tokenIn`.
   * @param tokenIn Address of the token to get the target address for
   * @return address Address of the target
   */
  function targetOf(address tokenIn) external returns (address);

  /**
   * @notice Checks if a liquidation pair can be used to liquidate the given tokenOut from this source.
   * @param tokenOut The address of the token to liquidate
   * @param liquidationPair The address of the liquidation pair that is being checked
   * @return bool True if the liquidation pair can be used, false otherwise
   */
  function isLiquidationPair(address tokenOut, address liquidationPair) external returns (bool);    

}
