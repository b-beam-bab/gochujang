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
    struct HookState {
        int256 totalZct; // 제로쿠폰본드 양
        int256 totalEth; // 이더양
        int256 totalLp; // 발행된 lp 토큰양
        int256 scalarRoot;
        uint256 expiry;
        uint256 lnFeeRateRoot;
        uint256 reserveFeePercent; // base 100
        uint256 lastLnImpliedRate;
    }

    using PoolIdLibrary for PoolKey;

    mapping(PoolId id => HookState) internal _pools;

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

    function poolInitialize(PoolId poolId, int256 scalarRoot, int256 initialAnchor, uint80 lnFeeRateRoot) external {
        HookState storage hs = _pools[poolId];
    }

    function beforeInitialize(address, PoolKey calldata key, uint160 sqrtPriceX96) external override returns (bytes4) {
        // TODO IMPLEMENT
        return BaseHook.beforeInitialize.selector;
    }

    function beforeSwap(address, PoolKey calldata key, IPoolManager.SwapParams calldata swapParams, bytes calldata)
        external
        override
        returns (bytes4, BeforeSwapDelta, uint24)
    {
        PoolId id = key.toId();
        HookState memory hs = _pools[id];
        bool exactInput = swapParams.amountSpecified < 0;
        (Currency specified, Currency unspecified) =
            (swapParams.zeroForOne == exactInput) ? (key.currency0, key.currency1) : (key.currency1, key.currency0);
        int256 specifiedAmount = exactInput ? -swapParams.amountSpecified : swapParams.amountSpecified;
        int256 unspecifiedAmount;
        BeforeSwapDelta returnDelta;
        if (exactInput) {
            unspecifiedAmount = _swap(hs, specified, unspecified, uint256(specifiedAmount), block.timestamp);
            returnDelta = toBeforeSwapDelta(int128(specifiedAmount), int128(-unspecifiedAmount));
        } else {
            // TODO FIX IT
            unspecifiedAmount = _swap(hs, specified, unspecified, uint256(specifiedAmount), block.timestamp);
            returnDelta = toBeforeSwapDelta(int128(-specifiedAmount), int128(unspecifiedAmount));
        }
        return (BaseHook.beforeSwap.selector, returnDelta, 0);
    }
}
