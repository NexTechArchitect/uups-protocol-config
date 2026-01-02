// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/ProtocolConfigV1.sol";
import "../../src/ProtocolConfigV2.sol";
import "../../src/ProtocolConfigV3.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract ProtocolConfigUpgradeTest is Test {
    address admin = address(0xA11CE);

    ProtocolConfigV1 v1;
    ProtocolConfigV2 v2;
    ProtocolConfigV3 v3;

    ERC1967Proxy proxy;

    function setUp() external {
        vm.startPrank(admin);

        // Deploy V1 implementation
        v1 = new ProtocolConfigV1();

        // Encode initializer
        bytes memory initData = abi.encodeWithSelector(
            ProtocolConfigV1.initialize.selector,
            admin,
            100, 
            1_000 ether
        );

        // Deploy proxy pointing to V1
        proxy = new ERC1967Proxy(address(v1), initData);

        vm.stopPrank();
    }

    /*//////////////////////////////////////////////////////////////
                      TEST 1 — V1 STATE
    //////////////////////////////////////////////////////////////*/

    function test_V1InitializedCorrectly() external {
        ProtocolConfigV1 proxyV1 = ProtocolConfigV1(address(proxy));

        assertEq(proxyV1.admin(), admin);
        assertEq(proxyV1.feeBps(), 100);
        assertEq(proxyV1.maxLimit(), 1_000 ether);
    }

    /*//////////////////////////////////////////////////////////////
                TEST 2 — V1 → V2 UPGRADE SMART CONTRACT
    //////////////////////////////////////////////////////////////*/

    function test_UpgradeV1ToV2_PreservesState() external {
        vm.startPrank(admin);

        // Deploy V2
        v2 = new ProtocolConfigV2();

        // Upgrade via proxy
        ProtocolConfigV1(address(proxy)).upgradeToAndCall(address(v2), "");

        vm.stopPrank();

        ProtocolConfigV2 proxyV2 = ProtocolConfigV2(address(proxy));

        // Old state preserved
        assertEq(proxyV2.admin(), admin);

        // New V2 state
        assertEq(proxyV2.paused(), false);
    }

    /*//////////////////////////////////////////////////////////////
                TEST 3 — V2 → V3 SNAPSHOT LOGIC
    //////////////////////////////////////////////////////////////*/

    function test_UpgradeV2ToV3_AndSnapshotsWork() external {
        vm.startPrank(admin);

        // Upgrade to V2
        v2 = new ProtocolConfigV2();
        ProtocolConfigV1(address(proxy)).upgradeToAndCall(address(v2), "");

        // Upgrade to V3 WITH initializer
        v3 = new ProtocolConfigV3();

        bytes memory initV3 = abi.encodeWithSelector(
            ProtocolConfigV3.initializeV3.selector,
            100,
            1_000 ether
        );

        ProtocolConfigV2(address(proxy)).upgradeToAndCall(address(v3), initV3);

        ProtocolConfigV3 proxyV3 = ProtocolConfigV3(address(proxy));

        // Initial snapshot
        (uint256 fee, uint256 limit, uint256 activatedAt) = proxyV3
            .getActiveConfig();

        assertEq(fee, 100);
        assertEq(limit, 1_000 ether);
        assertGt(activatedAt, 0);

        // New snapshot
        proxyV3.createNewConfig(200, 2_000 ether);
        proxyV3.activateConfig(2);

        (uint256 newFee, uint256 newLimit, ) = proxyV3.getActiveConfig();

        assertEq(newFee, 200);
        assertEq(newLimit, 2_000 ether);

        vm.stopPrank();
    }
}
