# Fishpocalypse — Authoritative Development Plan

_Last updated: 2026-05-18_

## What This Game Is

Fishpocalypse is a 2.5D wave-survival game built in Godot 4.5.
Visual style: PSX/pixel-retro aesthetic — 3D island environment with 2D billboard pixel sprites.
Loop: fish and prepare by day; survive escalating demonic fish waves by night.
No end goal — survive as many nights as possible.

This is the midterm capstone for **ARTS 1 · Critical Perspectives in the Arts (UP Cebu)**.
The artistic statement is built into every system, not applied at the end.

---

## Confirmed Design Decisions

| Topic | Decision |
|---|---|
| Camera | Fixed-angle (~3/4 DOOM tilt), pans/lerp-follows player — larger explorable island |
| Scope | Endless survival, fixed island, buff drop every 10th night. No bosses, no zones, no ending |
| Combat | Ranged fish-weapon shooting: fire costs CP + recharge + post-shot delay; dodge costs SP |
| Health | No passive regen; restored only by using HealingItems |
| Art integration | **Both deeply integrated** — visual day/night contrast (Module 2) + fisherfolk-labor + Philippine-mythology framing (Module 1) |
| Assets | Placeholders first (systems work end-to-end), final art swapped in during Phase 8 |
| Timeline | Full beta scope, phases ordered by dependency |

**Out of scope** (from original proposal): first-person view, bosses, multiple zones/endings, full gore/dismemberment system.
**Retained from proposal**: overkill explosion + drop effect (serves the art contrast), Philippine mythology enemy naming/skinning, fisherfolk narrative framing.

---

## Art Integration — Course Module Mapping

### Module 1: Art as an Experience (fisherfolk labor/struggle)
- Intro screen: artist-statement context card framing the game as an experience of fisherfolk precarity
- Day = labor: fishing, preparing weapons, managing inventory
- Night = threat/precarity: wave survival
- Death/game-over screen: recap of nights survived, framed as a statement on precarious livelihood

### Module 2: Image and Context (visual contrast)
- Day palette: warm, soft lighting, muted/cutesy color grading, lo-fi ambient morning audio
- Night palette: red sea shader, harsh high-contrast shadows, screen grain, heavy retro horror audio
- The transition between palettes is the central artistic image — visible every cycle

### Philippine Mythology (both modules)
- The three enemy archetypes are named and skinned after Philippine mythological creatures
- Names/skins chosen in Phase 8 and documented in this file for the arts grade
- Connects the abstract "demonic fish" concept to a specific cultural context

> Enemy name placeholders (fill in Phase 8):
> - Normal Fish → `[TBD — lesser Philippine sea myth creature]`
> - Tanky Fish → `[TBD — Philippine myth creature associated with bodies of water]`
> - Shooting Fish → `[TBD — Philippine myth creature with projectile/curse lore]`

---

## Architecture

### Autoload Singletons (`autoloads/`)

| Singleton | Responsibility |
|---|---|
| `GameState` | Day/night state machine (DAY/NIGHT/TRANSITION), day counter, wave tracking. Emits: `day_started`, `night_started`, `wave_cleared`, `buff_day_reached` |
| `AudioManager` | Day/night music crossfade, pooled SFX playback |

Systems communicate via signals — never via hard node paths between unrelated nodes.

### Data as Resources (`resources/`)

All tunables live in `.tres` files backed by custom `Resource` subclasses. Designer edits in the Godot editor, not in code.

| Class | Key `@export` fields |
|---|---|
| `FishWeaponData` | rarity, unlock_day, damage_per_second, projectiles_per_shot, recharge_cost, post_shot_delay, projectile_scene, sprite_frames, sfx |
| `HealingItemData` | item_class (I–IV), heal_amount, sprite |
| `FishingPoleData` | pole_type, catch_rate_modifier, rare_fish_bonus |
| `BuffData` | stat_modifiers (dict), is_permanent |
| `EnemyData` | enemy_type, hp, damage, speed, attack_type, rarity_weight, sprite_frames, sfx |
| `RarityConfig` | tiers: `[common, uncommon, rare, epic, legendary, "???"]`, stat_multipliers |

### Scenes (`scenes/`, `ui/`)

| Scene | Node type | Notes |
|---|---|---|
| `Main.tscn` | Node3D | Root: World + Player + UI + autoload refs |
| `Island.tscn` | Node3D | Static 3D environment (placeholder geometry → final art Phase 8) |
| `CameraRig.tscn` | Node3D | Locked ~3/4 angle, lerp-follows player XZ position |
| `Player.tscn` | CharacterBody3D | Billboard Sprite3D + InventorySystem + CombatSystem + BuffSystem components |
| `Enemy.tscn` | CharacterBody3D | Billboard Sprite3D, state machine, NavigationAgent3D |
| `NormalFish.tscn` | inherits Enemy | EnemyData resource assigned |
| `TankyFish.tscn` | inherits Enemy | EnemyData resource assigned |
| `ShootingFish.tscn` | inherits Enemy | EnemyData resource assigned |
| `Projectile.tscn` | Area3D | Used by player ranged attacks and ShootingFish |
| `ItemPickup.tscn` | RigidBody3D | Random velocity+gravity scatter on spawn |
| `FishingMinigame.tscn` | Control | Stardew-style bar-catch UI |
| `HUD.tscn` | CanvasLayer | HP/CP/SP bars, equipped weapon, inventory slots, day counter, wave progress |
| `InventoryUI.tscn` | CanvasLayer | Open/close, equip/swap |
| `IntroScreen.tscn` | CanvasLayer | Artist-statement context card |
| `GameOverScreen.tscn` | CanvasLayer | Nights survived recap |

### PSX/Retro Render Pipeline

- Low-resolution `SubViewport` integer-scaled to window (e.g. 320×180 or 427×240)
- All sprites: `texture_filter = Nearest`, `billboard = BILLBOARD_ENABLED`
- Phase 8 polish additions: PSX vertex-jitter shader (environment mesh), dithering post-process

---

## Phase Breakdown

See `PHASES.md` for live status, checklists, bugs, and warnings.

### Phase 0 — Foundation
Project settings, folder structure, input map, autoload skeletons, `Main` + placeholder `Island` + `CameraRig`.

### Phase 1 — Day/Night Core Loop
`GameState` state machine, day counter, wave-cleared → day transition, buff-day trigger, environment-swap stub (art hooks wired here).

### Phase 2 — Player Foundation
`Player` movement + aim, HP/CP/SP stats + regen rules, reusable `Health` component, camera follows player.

### Phase 3 — Ranged Combat
`FishWeaponData` + `RarityConfig`; `CombatSystem` (fire/recharge/dodge/hot-swap); `Projectile`; test dummy.

### Phase 4 — Enemy Pool & Spawn
`EnemyData`; `Enemy` base + state machine; Normal/Tanky/Shooting variants; `SpawnEnemySystem` (rarity-weighted, population scales); overkill explode + drop; enemy damage to player.

### Phase 5 — Item & Inventory
Resource classes; `SpawnItemSystem` (scatter); `InventorySystem` (slots + store arrays); use healing item; `BuffSystem`; buff spawns on buff-days.

### Phase 6 — Fishing System
Stardew-style bar-catch minigame, DAY-only, produces items into inventory, unlock-by-day fish gating.

### Phase 7 — UI / HUD
All HUD elements, inventory UI, screen effects (hurt/low-HP), intro-context + game-over screens.

### Phase 8 — Art & Audio Integration
PSX pipeline polish, day/night palettes (red sea shader, lighting, audio), Philippine-mythology enemy skins + names, fisherfolk narrative framing, overkill VFX, all SFX/music, replace placeholders.

### Phase 9 — Balance, Optimization & Ship
Tune stats/economy, enemy pooling (target 100+), bug pass, export Windows `.exe`, playtest.

---

## Verification Checkpoints

| Checkpoint | Criteria |
|---|---|
| After each phase | Manual playtest of that phase's scene confirms checklist in `PHASES.md` |
| After Phase 7 (integration) | Full loop: intro → day fish → night survive → combat CP/SP correct → next day → buff on night 10 → death → game-over recap |
| After Phase 8 (art) | Day→night visual/audio contrast legible to someone unfamiliar with the game; course concepts readable |
| After Phase 9 (ship) | Stable at 100+ enemies; exported `.exe` launches and plays end-to-end |
