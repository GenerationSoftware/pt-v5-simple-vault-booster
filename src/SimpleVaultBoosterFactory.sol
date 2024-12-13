// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import { 
    SimpleVaultBooster,
    IPrizePool
} from "./SimpleVaultBooster.sol";

contract SimpleVaultBoosterFactory {
    function createSimpleVaultBooster(address _vault, IPrizePool _prizePool, address _owner) external returns (SimpleVaultBooster) {
        return new SimpleVaultBooster(_vault, _prizePool, _owner);
    }
}
