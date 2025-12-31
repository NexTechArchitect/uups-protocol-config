
<div align="center">

  <img src="https://readme-typing-svg.herokuapp.com?font=JetBrains+Mono&weight=700&size=30&pause=1000&color=00E5FF&center=true&vCenter=true&width=1000&height=100&lines=UUPS+Protocol+Config+System;Universal+Upgradeable+Proxy+Standard;Storage-Safe+Evolution+V1+%E2%86%92+V2+%E2%86%92+V3;Secured+by+OpenZeppelin+%26+Foundry" alt="Typing Effect" />

  <br />

  <a href="https://github.com/NexTechArchitect/uups-protocol-config">
    <img src="https://img.shields.io/badge/Solidity-0.8.20-363636?style=for-the-badge&logo=solidity&logoColor=white" />
    <img src="https://img.shields.io/badge/Pattern-UUPS_Proxy-be5212?style=for-the-badge&logo=architecture&logoColor=white" />
  </a>

  <br /><br />

  <h3>🧬 UUPS Protocol Configuration Architecture</h3>
  <p width="80%">
    <b>A production-grade, storage-safe upgradeability framework.</b><br/>
    Demonstrating atomic upgrades, historical state preservation, and gas-optimized logic replacement.
  </p>

</div>

<br />

<div align="center">
  <table>
    <tr>
      <td align="center" width="16%"><a href="#-executive-summary"><b>📖 Summary</b></a></td>
      <td align="center" width="16%"><a href="#-system-architecture"><b>🏗 Architecture</b></a></td>
      <td align="center" width="16%"><a href="#-storage-mechanics"><b>🧮 Storage Math</b></a></td>
      <td align="center" width="16%"><a href="#-upgrade-lifecycle"><b>🔄 Lifecycle</b></a></td>
      <td align="center" width="16%"><a href="#-security-invariants"><b>🛡 Security</b></a></td>
      <td align="center" width="16%"><a href="#-risk-mitigation"><b>⚠️ Risks</b></a></td>
    </tr>
  </table>
</div>

<hr />

## 📖 Executive Summary

The **UUPS Protocol Config System** solves the rigidity of immutable smart contracts while avoiding the bloat of Transparent Proxies. It implements the **Universal Upgradeable Proxy Standard (ERC-1822)**, placing upgrade logic within the implementation contract to minimize gas costs.

> **Core Mechanism:** **DelegateCall & Storage Slots**
> The Proxy holds all state (data), while the Implementation holds all logic (code). Upgrades are performed by changing the address the Proxy points to, without moving data.

---

## 🏗 System Architecture

The architecture relies on a **Proxy-Implementation** split. The Proxy is the permanent entry point, while the Implementation is ephemeral and replaceable.

### 📐 Upgrade Flow Diagram

```mermaid
graph TD
    User((User))
    Proxy[ERC1967 Proxy<br/>(Permanent Storage)]
    
    subgraph "Logic Layer (Implementations)"
        V1[ProtocolConfigV1<br/>(Base Logic)]
        V2[ProtocolConfigV2<br/>(Pausable Extension)]
        V3[ProtocolConfigV3<br/>(Versioned History)]
    end

    User -->|1. Calls Function| Proxy
    Proxy -.->|2. DelegateCall| V1
    
    %% Upgrade Event
    V1 -- Upgrade to V2 --> V2
    Proxy -.->|3. DelegateCall (Post-Upgrade)| V2
    
    %% Upgrade Event
    V2 -- Upgrade to V3 --> V3
    Proxy -.->|4. DelegateCall (Post-Upgrade)| V3

```

### 📂 Repository Structure

```text
uups-protocol-config/
├── src/
│   ├── ProtocolConfigV1.sol      // Genesis: Ownership & Fees
│   ├── ProtocolConfigV2.sol      // Extension: Emergency Pause
│   ├── ProtocolConfigV3.sol      // Evolution: Historical Structs
│   └── proxy/                    // ERC1967Proxy Implementation
├── script/
│   ├── DeploySystem.s.sol        // Atomic Deployment
│   └── UpgradeToV2.s.sol         // Safe Upgrade Script
└── test/
    ├── unit/                     // Logic Tests
    └── integration/              // Storage Layout Validation

```

---

## 🧮 Storage Mechanics

The safety of the system relies on the **ERC-1967 Storage Slot Standard**. We mathematically derive storage locations to prevent collisions between the Proxy admin logic and the Implementation variables.

### 1. Implementation Slot

The address of the current logic contract is stored at a specific slot to avoid overwriting state variables (like `feeBps`).

### 2. Admin Slot

The address authorized to perform upgrades is stored at:

### 3. Layout Alignment

We enforce **Append-Only** storage updates. New variables are added to the end of the storage layout.

| Version | Slot 0 | Slot 50 | Slot 51 | Slot 52 |
| --- | --- | --- | --- | --- |
| **V1** | `_initialized` | `feeBps` | `maxLimit` | *(Empty)* |
| **V2** | `_initialized` | `feeBps` | `maxLimit` | `paused` |
| **V3** | `_initialized` | `feeBps` | `maxLimit` | `paused` |

---

## 🔄 Upgrade Lifecycle

The protocol demonstrates a 3-stage evolution, proving that complex logic can be added over time without breaking existing data.

### 🧬 V1: Genesis

* **Logic:** Sets up `OwnableUpgradeable` and `UUPSUpgradeable`.
* **Action:** Initializes `feeBps` to 500 (5%).
* **Constraint:** Uses `__gap` to reserve 50 slots for future inheritance.

### 🛡 V2: Operational Safety

* **Logic:** Adds `PausableUpgradeable`.
* **Action:** Introduces `paused` boolean state.
* **Mechanism:** **Pure Upgrade** (No re-initialization needed).

### 🚀 V3: Data Evolution

* **Logic:** Adds a historical configuration struct array.
* **Action:** Migrates flat variables into a versioned struct.
* **Mechanism:** **Stateful Upgrade** (Uses `reinitializer(3)` to setup new data).

---

## 🛡 Security Invariants

This system is verified using **Foundry Invariant Tests**. The following properties hold true across all upgrade versions.

| ID | Invariant Property | Status |
| --- | --- | --- |
| **INV_01** | **Storage Integrity:** Existing variables (`feeBps`) are never overwritten/corrupted during upgrade. | ✅ **PASS** |
| **INV_02** | **Auth Control:** Only `owner` can call `upgradeToAndCall`. | ✅ **PASS** |
| **INV_03** | **Initialization:** Contract cannot be re-initialized (v1) after deployment. | ✅ **PASS** |
| **INV_04** | **Atomicity:** V3 upgrade and V3 configuration happen in the same transaction. | ✅ **PASS** |

---

## ⚠️ Risk Mitigation

| Risk Vector | Mitigation Strategy |
| --- | --- |
| **Storage Collision** | We use `StorageGap` (50 slots) and Foundry `storage-layout` checks before every upgrade. |
| **Uninitialized Proxy** | Deployment script strictly calls `initialize()` atomically inside the constructor. |
| **Function Clashing** | UUPS pattern removes the Proxy Selector Clashing risk present in Transparent Proxies. |
| **Bricked Proxy** | `_authorizeUpgrade` is strictly implemented in every version to prevent upgrade-locking. |

---

<br />

<div align="center">
<img src="https://raw.githubusercontent.com/rajput2107/rajput2107/master/Assets/Developer.gif" width="50" style="border-radius: 50%" />

<h3>Engineered by NexTechArchitect</h3>
<p><i>Protocol Design • DeFi Architecture • Security Engineering</i></p>

<a href="https://github.com/NexTechArchitect">
<img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white" />
</a>
&nbsp;&nbsp;
<a href="https://www.linkedin.com/in/amit-kumar-811a11277">
<img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white" />
</a>
&nbsp;&nbsp;
<a href="https://t.me/NexTechDev">
<img src="https://img.shields.io/badge/Telegram-26A5E4?style=for-the-badge&logo=telegram&logoColor=white" />
</a>
</div>

```

```
