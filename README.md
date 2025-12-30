<div align="center">
    <img src="https://img.shields.io/badge/Solidity-0.8.20-363636?style=for-the-badge&logo=solidity&logoColor=white" />
    <img src="https://img.shields.io/badge/Foundry-Framework-be5212?style=for-the-badge&logo=rust&logoColor=white" />
    <img src="https://img.shields.io/badge/OpenZeppelin-Upgradeable_v5-4e5ee4?style=for-the-badge&logo=openzeppelin&logoColor=white" />
    <img src="https://img.shields.io/badge/License-MIT-2ea44f?style=for-the-badge" />
</div>

<br />

<div align="center">
  <img src="https://readme-typing-svg.herokuapp.com?font=Fira+Code&weight=600&size=30&duration=4000&pause=1000&color=39A7FF&center=true&vCenter=true&width=1000&lines=UUPS+Protocol+Configuration+System;Secure+Upgradeable+Smart+Contract+Architecture;Storage-Safe+Evolution+V1+%E2%86%92+V2+%E2%86%92+V3" alt="Typing Effect" />
</div>

<br />

<div align="center">
  <a href="#-system-architecture"><b>📐 System Architecture</b></a>
  &nbsp;&nbsp;|&nbsp;&nbsp;
  <a href="#-upgrade-lifecycle"><b>🔄 Upgrade Lifecycle</b></a>
  &nbsp;&nbsp;|&nbsp;&nbsp;
  <a href="#-storage-layout-strategy"><b>💾 Storage Layout</b></a>
  &nbsp;&nbsp;|&nbsp;&nbsp;
  <a href="#-security-model"><b>🔒 Security Model</b></a>
</div>

<hr />

## 📖 Abstract

This repository implements a **production-grade, upgradeable protocol configuration system** utilizing the **UUPS (Universal Upgradeable Proxy Standard)**.

It serves as a reference implementation for **storage-safe protocol evolution**, demonstrating a complete lifecycle across multiple implementation versions (**V1 → V2 → V3**). It explicitly handles initialization chaining, re-initialization, access control, and historical state preservation without compromising the proxy's storage integrity.

The system is rigorously tested using **Foundry**, ensuring that every upgrade maintains the protocol's invariants and storage layout compatibility.

---

## 📐 System Architecture

The architecture separates state (Proxy) from logic (Implementation), ensuring low-cost operations while maintaining the flexibility to patch bugs or add features.



### **Architectural Invariants**
* **Proxy Address Persistence:** The entry point (`ERC1967Proxy`) remains constant; only the logic address changes.
* **Logic-Embedded Upgradeability:** Unlike Transparent Proxies, the upgrade logic resides in the implementation (`_authorizeUpgrade`), reducing gas costs.
* **Append-Only Storage:** New state variables are strictly appended to the end of the storage layout to prevent collision.

---

## 🔄 Upgrade Lifecycle

The repository simulates a real-world protocol evolution timeline:

### **Phase 1: ProtocolConfigV1 (Genesis)**
> *The Foundation*
* **Role:** Establishes the initial storage layout and ownership model.
* **Key Logic:** Sets up `OwnableUpgradeable` and `UUPSUpgradeable`.
* **Storage:** `admin`, `feeBps`, `maxLimit`.

### **Phase 2: ProtocolConfigV2 (Operational Safety)**
> *The Extension*
* **Upgrade Type:** **Pure Extension** (No initialization required).
* **New Feature:** Adds a **Circuit Breaker** (Pause/Unpause) for emergency response.
* **Safety:** Demonstrates how to add functionality without wiping existing V1 data.

### **Phase 3: ProtocolConfigV3 (Advanced Versioning)**
> *The Evolution*
* **Upgrade Type:** **Stateful Upgrade** (Requires `reinitializer`).
* **New Feature:** Implements a historical configuration tracking system.
* **Logic:** Allows rolling back to previous fee structures using an `activeConfigId` pointer.

---

## 💾 Storage Layout Strategy

We strictly adhere to the **Append-Only Storage Pattern** to prevent data corruption.

| Slot Index | Variable Name | Version | Type |
| :--- | :--- | :---: | :--- |
| **0** | `_initialized` / `_initializing` | **V1** | `uint8` (OZ Internal) |
| **1 - 49** | *(GAP)* | **V1** | `uint256[]` |
| **50** | `feeBps` | **V1** | `uint256` |
| **51** | `maxLimit` | **V1** | `uint256` |
| **52** | `paused` | **V2** | `bool` |
| **53** | `activeConfigId` | **V3** | `uint256` |
| **54** | `configCount` | **V3** | `uint256` |
| **55** | `configs` | **V3** | `mapping` |

---

## 🔒 Security Model

### OpenZeppelin v5 Compliance
This system is built on the latest security patterns:
* **No `upgradeTo`:** We strictly use `upgradeToAndCall` to ensure atomic upgrades and initialization.
* **Namespace Storage:** Utilizes modern storage patterns to prevent collision between parent and child contracts.
* **Access Control:** All critical functions (including upgrades) are gated via `onlyOwner`.

### Critical Safety Checks
1.  **Initializer Versioning:** Prevents re-execution attacks using `reinitializer(N)`.
2.  **Gap Contracts:** Reserved storage slots (`__gap`) are maintained to allow future library upgrades.
3.  **Atomic Execution:** V3 upgrades are executed with a payload to ensure the new state is configured in the same transaction as the code switch.

---

<div align="center">

<h3>👨‍💻 Author</h3>

<p><b>NexTechArchitect</b></p>
<p><i>Smart Contract Engineer & Full-Stack Web3 Developer</i></p>

<a href="https://github.com/NexTechArchitect">
  <img src="https://img.shields.io/badge/GitHub-NexTechArchitect-181717?style=for-the-badge&logo=github&logoColor=white" />
</a>
&nbsp;&nbsp;
<a href="https://www.linkedin.com/in/amit-kumar-811a11277">
  <img src="https://img.shields.io/badge/LinkedIn-Amit_Kumar-0077B5?style=for-the-badge&logo=linkedin&logoColor=white" />
</a>
&nbsp;&nbsp;
<a href="https://t.me/NexTechDev">
  <img src="https://img.shields.io/badge/Telegram-Chat_Now-26A5E4?style=for-the-badge&logo=telegram&logoColor=white" />
</a>

<br /><br />
<i>Built for longevity. Engineered for safety.</i>

</div>
