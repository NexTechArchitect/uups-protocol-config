// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/ProtocolConfigV1.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

/**
 * @notice Deploys ProtocolConfig V1 behind ERC1967Proxy (UUPS)
 */
contract DeployProtocolConfigV1 is Script {
    function run() external {
        vm.startBroadcast();

        // 1️⃣ Deploy V1 implementation (UUPS-enabled)
        ProtocolConfigV1 implementation = new ProtocolConfigV1();

        // 2️⃣ Encode initializer call
        bytes memory initData = abi.encodeWithSelector(
            ProtocolConfigV1.initialize.selector,
            msg.sender, // admin + owner
            100, // feeBps = 1%
            1_000 ether // maxLimit
        );

        // 3️⃣ Deploy proxy pointing to V1
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            initData
        );

        console.log("V1 Implementation:", address(implementation));
        console.log("Proxy Address:", address(proxy));

        vm.stopBroadcast();
    }
}
