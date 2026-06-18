# Lemmings FSM Game 

A complete, behavioral Verilog implementation modeling the autonomous behavior of lemmings inside a grid-based puzzle game environment. This project uses complex Finite State Machines (FSMs) to simulate a "Lemming"—a character that blindly walks forward, requiring structural state logic to survive environmental hazards, navigate terrain, dig paths, and manage terminal velocity.

The code is structured as an incremental architectural progression, scaling from basic horizontal navigation to a multi-state control-path integrated with a hardware data-path counter.

---

## 🎮 Game Mechanics & Character States

The codebase simulates four distinct evolutionary tiers of the character's autonomous behavior tree:

### 🌟 Phase 1: Basic Horizontal Exploration (`walk_left` / `walk_right`)
* **Core Behavior:** The character spawns into the world walking left by default. 
* **Obstacle Handling:** Upon encountering a physical barrier on either flank (`bump_left` or `bump_right`), the internal state machine cleanly toggles its orientation vector to the opposite direction, forcing the character to pace back and forth between walls.

### 🪂 Phase 2: Gravity & Airborne Vectors (`aaah`)
* **Core Behavior:** Introduces environmental verticality. If the terrain beneath the character vanishes (`ground = 0`), horizontal walking states instantly freeze.
* **Airborne Mode:** The character switches into a falling state, screaming (`aaah = 1`) and completely ignoring wall collisions while in mid-air. Once it makes contact with solid ground again (`ground = 1`), it seamlessly recovers and resumes walking in the exact direction it was traveling before the fall.

### ⛏️ Phase 3: Terrain Modification (`digging`)
* **Core Behavior:** While traveling safely on flat ground, an active action command (`dig = 1`) can force the character to stop walking and begin tunneling vertically straight down (`digging = 1`).
* **State Precedence:** Priority logic handles structural interruptions. If the character digs completely through a platform and into open space, the `falling` state immediately overrides the `digging` state, forcing the character to plummet.

### ☠️ Phase 4: Velocity Tracking & Terminal Impact (`die`)
* **Core Behavior:** Integrates a synchronous data-path cycle counter into the state control logic to track continuous falling time.
* **Lethality Mechanic:** If the character falls uninterrupted for **more than 20 clock cycles**, it achieves terminal velocity. Upon hitting solid ground, instead of safely recovering, it enters a permanent `splat` state (`die = 1`). This is a terminal death loop—all actions cease, and all active control lines are driven to `0` until a system master clear is invoked.

---


## 🔧 Comprehensive I/O Signal Breakdown

| Port Name | Direction | Data Type | Active Domain | Description |
| :--- | :---: | :---: | :---: | :--- |
| `clk` | Input | `1 bit` | Edge Triggered| Master simulation system clock source. |
| `areset` | Input | `1 bit` | Asynchronous | Master Clear (Resets the character back to walking left). |
| `bump_left` | Input | `1 bit` | Synchronous | Signals a physical wall blocking the character's left side. |
| `bump_right`| Input | `1 bit` | Synchronous | Signals a physical wall blocking the character's right side. |
| `ground` | Input | `1 bit` | Synchronous | State of terrain stability (`1` = solid ground, `0` = thin air). |
| `dig` | Input | `1 bit` | Synchronous | User-triggered action command to begin digging. |
| `walk_left` | Output| `1 bit` | Moore Flag | Driven high when the character is actively traveling left. |
| `walk_right`| Output| `1 bit` | Moore Flag | Driven high when the character is actively traveling right. |
| `aaah` | Output| `1 bit` | Moore Flag | Driven high when the character is falling through space. |
| `digging` | Output| `1 bit` | Moore Flag | Driven high when the character is clearing terrain downward. |
| `die` | Output| `1 bit` | Moore Flag | Driven high permanently if the character sustains fatal impact. |

---

## 🔬 Implementation Methodology

All engine modules adhere to strict synthesizable RTL rules:
1. **Separated FSM Topology:** Leverages clean, modular blocks separating combinational next-state evaluations from sequential state-register flip-flops.
2. **Glitch-Free Output Assignment:** Leverages deterministic Moore architecture decode trees to assign output statuses directly based on current-state variables rather than input transitions.

---
