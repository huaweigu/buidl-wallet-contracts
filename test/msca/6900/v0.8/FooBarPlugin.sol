/*
 * Copyright 2024 Circle Internet Group, Inc. All rights reserved.

 * SPDX-License-Identifier: GPL-3.0-or-later

 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
pragma solidity 0.8.24;

import {PLUGIN_VERSION_1, PLUGIN_AUTHOR} from "../../../../src/common/Constants.sol";
import {BasePlugin} from "../../../../src/msca/6900/v0.8/plugins/BasePlugin.sol";
import {
    PluginManifest,
    PluginMetadata,
    ManifestExecutionFunction
} from "../../../../src/msca/6900/v0.8/common/PluginManifest.sol";
import {NotImplementedFunction} from "../../../../src/msca/6900/shared/common/Errors.sol";
import {IValidation} from "../../../../src/msca/6900/v0.8/interfaces/IValidation.sol";
import {PackedUserOperation} from "@account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {SIG_VALIDATION_SUCCEEDED} from "../../../../src/common/Constants.sol";

contract FooBarPlugin is IValidation, BasePlugin {
    string public constant NAME = "Your Favourite Fruit Bar Plugin";

    enum EntityId {
        VALIDATION
    }

    // solhint-disable-next-line no-empty-blocks
    function onInstall(bytes calldata) external override {}

    // solhint-disable-next-line no-empty-blocks
    function onUninstall(bytes calldata) external override {}

    function foo() external pure returns (bytes32) {
        return keccak256("foo");
    }

    function bar() external pure returns (bytes32) {
        return keccak256("bar");
    }

    /// @inheritdoc IValidation
    function validateUserOp(uint32 entityId, PackedUserOperation calldata userOp, bytes32 userOpHash)
        external
        pure
        override
        returns (uint256 validationData)
    {
        (userOp, userOpHash);
        if (entityId == uint32(EntityId.VALIDATION)) {
            return SIG_VALIDATION_SUCCEEDED;
        }
        revert NotImplementedFunction(msg.sig, entityId);
    }

    /// @inheritdoc IValidation
    function validateRuntime(
        address account,
        uint32 entityId,
        address sender,
        uint256 value,
        bytes calldata data,
        bytes calldata authorization
    ) external pure override {
        (account, sender, value, data, authorization);
        if (entityId == uint8(EntityId.VALIDATION)) {
            return;
        }
        revert NotImplementedFunction(msg.sig, entityId);
    }

    /// @inheritdoc IValidation
    function validateSignature(address account, uint32 entityId, address, bytes32, bytes calldata)
        external
        pure
        returns (bytes4)
    {
        (account);
        revert NotImplementedFunction(msg.sig, entityId);
    }

    function pluginManifest() external pure override returns (PluginManifest memory) {
        PluginManifest memory manifest;
        manifest.executionFunctions = new ManifestExecutionFunction[](2);
        manifest.executionFunctions[0] = ManifestExecutionFunction({
            executionSelector: this.foo.selector,
            skipRuntimeValidation: true,
            allowGlobalValidation: false
        });
        manifest.executionFunctions[1] = ManifestExecutionFunction({
            executionSelector: this.bar.selector,
            skipRuntimeValidation: false,
            allowGlobalValidation: false
        });
        return manifest;
    }

    function pluginMetadata() external pure override returns (PluginMetadata memory) {
        PluginMetadata memory metadata;
        metadata.name = NAME;
        metadata.version = PLUGIN_VERSION_1;
        metadata.author = PLUGIN_AUTHOR;
        return metadata;
    }
}
