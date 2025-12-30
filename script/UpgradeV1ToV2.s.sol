// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/ProtocolConfigV1.sol";
import "../src/ProtocolConfigV2.sol";

contract UpgradeV1ToV2 is Script {
    function run() external {
        vm.startBroadcast();

        address proxy = vm.envAddress("PROXY_ADDRESS");

        // 1️⃣ Deploy V2 implementation
        ProtocolConfigV2 newImplementation = new ProtocolConfigV2();

        // 2️⃣ OZ v5 upgrade method (THIS IS THE KEY)
        ProtocolConfigV1(proxy).upgradeToAndCall(
            address(newImplementation),
            ""
        );

        vm.stopBroadcast();
    }
}
