// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/**
 * @title ProtocolConfigV3
 * @author NexTechArhitct
 * @notice Versioned, snapshot-based protocol configuration (UUPS enabled)
 *
 * IMPORTANT:
 * - V1 initializer ran at deploy
 * - V3 initializer MUST be reinitializer(3)
 */
contract ProtocolConfigV3 is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable
{
    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/

    error NotAdmin();
    error FeeTooHigh();
    error InvalidLimit();
    error InvalidConfigId();

    /*//////////////////////////////////////////////////////////////
                               STORAGE (V1)
    //////////////////////////////////////////////////////////////*/

    address public admin;

    /*//////////////////////////////////////////////////////////////
                        STORAGE (V3 SNAPSHOTS)
    //////////////////////////////////////////////////////////////*/

    struct Config {
        uint256 feeBps;
        uint256 maxLimit;
        uint256 activatedAt;
    }

    mapping(uint256 => Config) internal configs;
    uint256 public configCount;
    uint256 public activeConfigId;

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    event ConfigCreated(uint256 indexed id, uint256 feeBps, uint256 maxLimit);
    event ConfigActivated(uint256 indexed id);

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier onlyAdmin() {
        if (msg.sender != admin) revert NotAdmin();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                        V3 INITIALIZER (IMPORTANT)
    //////////////////////////////////////////////////////////////*/

    function initializeV3(
        uint256 initialFeeBps,
        uint256 initialMaxLimit
    ) external reinitializer(3) {
        if (initialFeeBps > 10_000) revert FeeTooHigh();
        if (initialMaxLimit == 0) revert InvalidLimit();

        // Create first snapshot using existing V1 values
        configCount = 1;
        configs[1] = Config({
            feeBps: initialFeeBps,
            maxLimit: initialMaxLimit,
            activatedAt: block.timestamp
        });

        activeConfigId = 1;

        emit ConfigCreated(1, initialFeeBps, initialMaxLimit);
        emit ConfigActivated(1);
    }

    /*//////////////////////////////////////////////////////////////
                        SNAPSHOT MANAGEMENT
    //////////////////////////////////////////////////////////////*/

    function createNewConfig(
        uint256 newFeeBps,
        uint256 newMaxLimit
    ) external onlyAdmin {
        if (newFeeBps > 10_000) revert FeeTooHigh();
        if (newMaxLimit == 0) revert InvalidLimit();

        configCount++;

        configs[configCount] = Config({
            feeBps: newFeeBps,
            maxLimit: newMaxLimit,
            activatedAt: block.timestamp
        });

        emit ConfigCreated(configCount, newFeeBps, newMaxLimit);
    }

    function activateConfig(uint256 configId) external onlyAdmin {
        if (configId == 0 || configId > configCount) revert InvalidConfigId();

        activeConfigId = configId;
        emit ConfigActivated(configId);
    }

    /*//////////////////////////////////////////////////////////////
                           VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function getActiveConfig()
        external
        view
        returns (uint256 feeBps, uint256 maxLimit, uint256 activatedAt)
    {
        Config memory cfg = configs[activeConfigId];
        return (cfg.feeBps, cfg.maxLimit, cfg.activatedAt);
    }

    function getConfigById(
        uint256 configId
    )
        external
        view
        returns (uint256 feeBps, uint256 maxLimit, uint256 activatedAt)
    {
        if (configId == 0 || configId > configCount) revert InvalidConfigId();

        Config memory cfg = configs[configId];
        return (cfg.feeBps, cfg.maxLimit, cfg.activatedAt);
    }

    /*//////////////////////////////////////////////////////////////
                     UPGRADE AUTHORIZATION
    //////////////////////////////////////////////////////////////*/

    function _authorizeUpgrade(address) internal override onlyOwner {}

    /*//////////////////////////////////////////////////////////////
                           STORAGE GAP
    //////////////////////////////////////////////////////////////*/

    uint256[50] private __gap;
}
