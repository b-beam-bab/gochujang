// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {BaseHook} from "v4-periphery/src/base/hooks/BaseHook.sol";
import {Currency} from "v4-core/src/types/Currency.sol";

import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "v4-core/src/types/PoolId.sol";
import {BalanceDelta} from "v4-core/src/types/BalanceDelta.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary, toBeforeSwapDelta} from "v4-core/src/types/BeforeSwapDelta.sol";

contract GoChuJang is BaseHook {
    using PoolIdLibrary for PoolKey;

    // NOTE: ---------------------------------------------------------
    // state variables should typically be unique to a pool
    // a single hook contract should be able to service multiple pools
    // ---------------------------------------------------------------

    constructor(IPoolManager _poolManager) BaseHook(_poolManager) {}

    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: true, // true
            afterInitialize: false,
            beforeAddLiquidity: false,
            afterAddLiquidity: false,
            beforeRemoveLiquidity: false,
            afterRemoveLiquidity: false,
            beforeSwap: true, // true
            afterSwap: false,
            beforeDonate: false,
            afterDonate: false,
            beforeSwapReturnDelta: false,
            afterSwapReturnDelta: false,
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });
    }

    function poolInitialize(
        PoolId poolId,
        int256 scalarRoot,
        int256 initialAnchor,
        uint80 lnFeeRateRoot
    ) external {
        
    }

    function beforeInitialize(address, PoolKey calldata key, uint160 sqrtPriceX96) 
        external
        override
        returns (bytes4)
    {
        // TODO IMPLEMENT
        return BaseHook.beforeInitialize.selector;
    }

    function beforeSwap(address, PoolKey calldata key, IPoolManager.SwapParams calldata swapParams, bytes calldata)
        external
        override
        returns (bytes4, BeforeSwapDelta, uint24)
    {
        bool exactInput = swapParams.amountSpecified < 0;
        (Currency specified, Currency unspecified) = (swapParams.zeroForOne == exactInput) ? (key.currency0, key.currency1) : (key.currency1, key.currency0);
        int256 specifiedAmount = exactInput ? -swapParams.amountSpecified : swapParams.amountSpecified;
        int256 unspecifiedAmount;
        BeforeSwapDelta returnDelta;
        if (exactInput) {
            unspecifiedAmount = _swap();
            returnDelta = toBeforeSwapDelta(int128(specifiedAmount), int128(-unspecifiedAmount));
        } else {
            unspecifiedAmount = _swap();
            returnDelta = toBeforeSwapDelta(int128(-specifiedAmount), int128(unspecifiedAmount));
        }
        return (BaseHook.beforeSwap.selector, returnDelta, 0);
    }

    function _swap() internal pure returns (int256) {
        return 0;
    }
}