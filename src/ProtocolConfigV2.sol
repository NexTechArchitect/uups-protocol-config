// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/**
 * @title ProtocolConfigV2
 * @author NexTechArhitct
 * @notice V2 adds emergency pause functionality (UUPS enabled)
 */
contract ProtocolConfigV2 is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable
{
    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/

    error NotAdmin();
    error AlreadyInitialized();
    error AlreadyPaused();
    error NotPaused();

    /*//////////////////////////////////////////////////////////////
                               STORAGE (V1)
    //////////////////////////////////////////////////////////////*/

    address public admin;
    bool internal initialized;

    /*//////////////////////////////////////////////////////////////
                               STORAGE (V2)
    //////////////////////////////////////////////////////////////*/

    bool public paused;

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier onlyAdmin() {
        if (msg.sender != admin) revert NotAdmin();
        _;
    }

    modifier whenNotPaused() {
        if (paused) revert AlreadyPaused();
        _;
    }

    modifier whenPaused() {
        if (!paused) revert NotPaused();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                             INITIALIZER (V1)
    //////////////////////////////////////////////////////////////*/

    function initialize(address _admin) external initializer {
        admin = _admin;
        initialized = true;

        __Ownable_init(_admin);
    }

    /*//////////////////////////////////////////////////////////////
                        EMERGENCY CONTROL (V2)
    //////////////////////////////////////////////////////////////*/

    function pause() external onlyAdmin whenNotPaused {
        paused = true;
    }

    function unpause() external onlyAdmin whenPaused {
        paused = false;
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
