// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/**
 * @title ProtocolConfigV1
 * @author NexTechArhitct
 * @notice Base protocol configuration (UUPS-enabled)
 *
 * V1 responsibilities:
 * - Set admin
 * - Store basic config values
 * - Enable future upgrades (UUPS)
 */
contract ProtocolConfigV1 is
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

    /*//////////////////////////////////////////////////////////////
                               STORAGE (V1)
    //////////////////////////////////////////////////////////////*/

    address public admin;
    uint256 public feeBps;
    uint256 public maxLimit;

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier onlyAdmin() {
        if (msg.sender != admin) revert NotAdmin();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                             INITIALIZER
    //////////////////////////////////////////////////////////////*/

    function initialize(
        address _admin,
        uint256 _feeBps,
        uint256 _maxLimit
    ) external initializer {
        if (_feeBps > 10_000) revert FeeTooHigh();
        if (_maxLimit == 0) revert InvalidLimit();

        admin = _admin;
        feeBps = _feeBps;
        maxLimit = _maxLimit;

        // Owner controls upgrades
        __Ownable_init(_admin);
    }

    /*//////////////////////////////////////////////////////////////
                        ADMIN CONFIG (V1)
    //////////////////////////////////////////////////////////////*/

    function updateFee(uint256 newFeeBps) external onlyAdmin {
        if (newFeeBps > 10_000) revert FeeTooHigh();
        feeBps = newFeeBps;
    }

    function updateMaxLimit(uint256 newLimit) external onlyAdmin {
        if (newLimit == 0) revert InvalidLimit();
        maxLimit = newLimit;
    }

    function transferAdmin(address newAdmin) external onlyAdmin {
        admin = newAdmin;
    }

    /*//////////////////////////////////////////////////////////////
                     UPGRADE AUTHORIZATION (UUPS)
    //////////////////////////////////////////////////////////////*/

    function _authorizeUpgrade(address) internal override onlyOwner {}

    /*//////////////////////////////////////////////////////////////
                           STORAGE GAP
    //////////////////////////////////////////////////////////////*/

    uint256[50] private __gap;
}
