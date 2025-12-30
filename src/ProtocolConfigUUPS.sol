// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/**
 * @title ProtocolConfigUUPS
 * @author NexTechArhitct
 * @notice UUPS upgrade engine for ProtocolConfig (V1 → V2 → V3)
 */
contract ProtocolConfigUUPS is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable
{
    /*//////////////////////////////////////////////////////////////
                           INITIALIZER
    //////////////////////////////////////////////////////////////*/

    function initializeUUPS(address initialOwner) external initializer {
        __Ownable_init(initialOwner);
    }

    /*//////////////////////////////////////////////////////////////
                     UPGRADE AUTHORIZATION
    //////////////////////////////////////////////////////////////*/

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    /*//////////////////////////////////////////////////////////////
                        STORAGE GAP
    //////////////////////////////////////////////////////////////*/

    uint256[50] private __gap;
}
