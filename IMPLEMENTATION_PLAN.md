## Plan: Anime Draft Showdown Task Breakdown

Build the Roblox prototype in dependency-ordered milestones, starting with a playable two-player draft slice and extending it to party tables, abilities, persistence, UI, admin tooling, and monetization hooks. Use strict Luau, server authority, Rojo/Wally conventions, Blink via Wally, and code-generated placeholder world assets.

**Steps**

### Phase 0: Project foundation
1. Add and lock a Blink Wally dependency using a compatible package/version, expose its package entrypoint under `Packages`, and document the generation/update command for typed definitions. Confirm the selected Blink API before writing networking modules.
2. Establish the project-owned module layout under the existing Rojo tree:
   - `src/ReplicatedStorage/Shared/Types.luau`
   - `src/ReplicatedStorage/Shared/Constants.luau`
   - `src/ReplicatedStorage/Shared/CharacterCatalog.luau`
   - `src/ReplicatedStorage/Shared/AbilityCatalog.luau`
   - `src/ReplicatedStorage/Shared/Network/` for Blink definitions and generated/access modules
   - `src/ReplicatedStorage/Client/` for Roact components and client state
   - `src/ServerScriptService/Server/` for profile, table, match, ability, command, and bootstrap modules
   - `src/StarterPlayerScripts/ClientMain.client.luau`
   - `src/ServerScriptService/ServerMain.server.luau`
3. Define the shared strict data contracts before implementation: table kind/configuration, seat state, table lifecycle, player match state, character records, bid payloads, ability casts, stack entries, round state, end-of-match results, and public/private state projections. Keep persistent data JSON-safe and keep Instances out of saved/session data.
4. Add a lightweight test strategy and test fixtures for pure modules. Use ProfileStore.Mock for persistence tests and deterministic character/ability catalogs for gameplay tests.

### Phase 1: Playable vertical slice, server-first
5. Implement placeholder Tavern/table construction and discovery. Generate or configure Duels and Party table models with tagged chairs, table IDs, table kind, pedestal, and prompts. Keep the world adapter separate from gameplay so Studio assets can replace placeholders later.
6. Implement `TableManager` and `TableQueue` server modules. Track player-to-table membership, chair occupancy, duplicate-seat prevention, leave/stand handling, minimum counts (Duels 2, Party 3), Party maximum 6, countdown cancellation, capacity-shortened countdown at 6/6, and seat locking when launch begins.
7. Implement `TableSession` as the isolated authoritative match state machine. Start with a configurable short draft fixture for tests, then support the requested 15-round default. Include match cash initialized to 50, round transitions, participant roster, current character, current bid/high bidder, timer deadline, and final result state.
8. Implement authoritative bid validation and resolution. Validate table/session membership, phase, bidder identity, sufficient available cash, valid increment (1/2/5), strictly higher bid, and timer validity. Reset the five-second deadline after valid bids, resolve the highest bidder at timeout, deduct only on award, append the character, and advance or finish the match. Never trust client-supplied cash, winner, timer, character, or score.
9. Implement initial Blink contracts and handlers for `TableQueue`, `Bid`, and `SyncState`. Replicate only the state a recipient may see; provide a per-player projection for private information. Add disconnect/cleanup behavior and reject malformed or stale requests.
10. Build a minimal Roact vertical-slice HUD: current character, power, bid, cash, timer, table status, and a simple result screen. It should consume synchronized state rather than calculate authoritative results. Verify two Studio test players can sit, bid, resolve several rounds, and receive a result.

### Phase 2: Full draft and state projection
11. Expand the character catalog to 15-20 deterministic entries with fixed base power and series metadata. Add catalog validation for duplicate IDs, invalid powers, and empty pools.
12. Add complete public/private synchronization rules: masked Shadow Bid fields, private cash/bid visibility where required, next-character visibility only for authorized players, and stable snapshots suitable for reconnects. Define what spectators or nonparticipants see.
13. Add match cancellation and failure paths: player disconnect, table emptied, server shutdown, invalid catalog, no valid bidder, and session teardown. Release seats and clear session references in every path.
14. Add focused tests for countdown thresholds, countdown abort/shortening, bid increments and rejection, timer reset, cash deductions, award ownership, round count, final power sums, and disconnect cleanup.

### Phase 3: Ability and LIFO reaction system
15. Implement an `AbilityService` and server-side ability catalog for Safe Guard, Shadow Bid, Chunibyo Eye, Dispel, and Steal. Define targeting, availability, per-round usage, required ownership/equipment, and valid phases centrally.
16. Implement the five-second hidden incantation window and LIFO reaction stack. Broadcast only generic aura/placeholder events during the window, accept valid responses, resolve from newest to oldest, allow Dispel to remove the prior queued cast, and make resolution idempotent when players leave or the round expires.
17. Add effect modules and explicit match-state flags: Safe Guard bench protection, Shadow Bid masking, Chunibyo Eye private next-round preview, Dispel cancellation, and Steal award transfer with Safe Guard protection. Ensure every effect is checked server-side at resolution and cannot leak private state through Blink payloads.
18. Add `CastAbility` Blink messages and related sync events, then extend the Roact ability tray with equipped slots, per-round charge state, hidden incantation animation, stack feedback, target selection where applicable, and rejection/error states.
19. Add unit tests for one-cast-per-round, stack order, Dispel behavior, hidden cast visibility, Safe Guard protection, Steal transfer, invalid targets, and round/session cleanup.

### Phase 4: Persistence and progression
20. Create a project-owned `ProfileService`/`PlayerDataService` adapter around the existing ProfileStore module rather than modifying the vendored implementation. Use a template containing `Coins`, `Wins`, `OwnedAbilities`, and `EquippedAbilities` capped at three; reconcile, associate the UserId, connect `OnSessionEnd`, and end sessions on PlayerRemoving and shutdown.
21. Separate persistent progression from match cash. Award match coins and wins only after a completed authoritative match, avoid duplicate awards on retries/reconnects, and provide safe defaults for failed or unavailable profile sessions.
22. Add inventory/equipment validation and server APIs for equipping abilities. Keep purchases and unlocks server-authoritative and prevent arbitrary client ability IDs.
23. Add ProfileStore.Mock tests for new profiles, reconciliation, release on leave/shutdown, duplicate completion protection, coin/win awards, and invalid equipment data.

### Phase 5: Cmdr and operations
24. Bootstrap Cmdr on the server and register guarded commands: `starttable <tableId>`, `giveability <player> <abilityId>`, plus useful inspection/reset commands only if needed for testing. Use explicit administrator authorization and validate table/player/ability arguments through Cmdr types.
25. Connect commands to `TableManager`, `TableSession`, and `PlayerDataService` through service interfaces, not direct mutation of internal tables. Return actionable command responses and ensure commands cannot bypass core server validation in ways normal clients cannot use.
26. Add a Studio operations checklist for forcing a table start, granting an ability, inspecting state, and cleaning up a stuck placeholder table.

### Phase 6: UI and world integration
27. Replace the minimal HUD with composed Roact surfaces: table queue/seating status, bidding pedestal/card, timer bar, ability tray, bench/roster, private masked values, and end-of-match podium showing ranked totals and recruited rosters.
28. Add responsive layout and clear state transitions for joining/leaving, countdown, bidding, incantation, resolution, round advance, match end, and error/reconnect. Keep UI components presentational and state subscriptions centralized in the client controller.
29. Improve generated placeholder tables with readable table IDs, chair prompts, pedestal display, countdown signage, and basic visual feedback. Keep all model references/configuration isolated so imported art can replace them later.
30. Add a manual multiplayer checklist covering Duels, Party 3-6 players, capacity launch, threshold cancellation, simultaneous bids/casts, disconnects, private previews, and final ranking.

### Phase 7: Monetization hooks and hardening
31. Define product/service interfaces for scroll or ability crates, Robux purchase receipts, reroll tokens, cosmetics, and VIP table modifiers without coupling them to core auction logic. Do not implement paid randomness or receipt handling until the progression model and Roblox product IDs are specified.
32. Add modifier table configuration for High Roller and Legendary Pool as server-validated table rules, with VIP entitlement checks isolated from match state.
33. Add telemetry/logging hooks for rejected bids, ability casts, match outcomes, profile failures, and command use without logging sensitive/private state unnecessarily.
34. Run strict Luau/type validation, Rojo build, focused tests, and a Studio smoke test. Review all client-to-server entry points for authority, replay/stale request handling, privacy leaks, and cleanup.

**Relevant files**
- `wally.toml` and `wally.lock` — add/lock Blink; preserve existing Roact, Cmdr, and ProfileStore dependencies.
- `default.project.json` — extend the Rojo tree only if new source/package paths require explicit mappings.
- `src/ServerScriptService/ProfileStore.luau` — treat as vendored infrastructure; reuse its typed API and Mock support, do not mix game-specific profile logic into it.
- `src/ReplicatedStorage/` — shared contracts/catalogs, Blink definitions, client-facing state types, and Roact modules.
- `src/ServerScriptService/` — server bootstrap, table queue/session state machines, validation, abilities, progression adapter, and Cmdr commands.
- `src/StarterPlayerScripts/` — client bootstrap, Blink listeners, client state store, and Roact mount point.
- `README.md` — document Wally/Blink setup, Rojo build/serve flow, Studio API access for ProfileStore, and the manual test checklist.

**Verification**
1. After Phase 0, run Wally install/update and Rojo build; verify Blink resolves and all new strict modules parse/type-check.
2. After Phase 1, run pure state-machine tests and a two-player Studio test: seat exactly two players, count down, submit valid/invalid bids, let the timer resolve, and display the result.
3. After Phase 2, test Duels and Party thresholds, 6-player shortened launch, timer cancellation, 15-round completion, private/public projections, disconnect cleanup, and score calculation.
4. After Phase 3, run ability unit tests and a multiplayer test with simultaneous hidden casts, LIFO resolution, Dispel, Safe Guard, Shadow Bid masking, Chunibyo Eye privacy, and Steal protection.
5. After Phase 4, use ProfileStore.Mock to verify reconciliation, session release, progression awards, and duplicate-award prevention.
6. After Phase 5, use Cmdr in Studio to force-start a table and grant an ability, confirming authorization and normal validation paths remain intact.
7. Before release, run strict Luau diagnostics, Rojo build, focused automated tests, and a Studio smoke test across Duels, Party, reconnect/disconnect, shutdown, and private-state visibility.

**Decisions**
- Scope is a playable vertical slice first, then the complete requested prototype in phases.
- Blink is added through Wally; the exact package/API version must be confirmed before implementing definitions.
- Code-generated placeholder tables and presentation assets are the initial world implementation; imported art is out of scope for the first slice.
- The first playable slice should use a short deterministic test pool/configuration while production defaults remain 15 rounds and 15-20 catalog entries.
- Match cash is transient; Coins, Wins, owned abilities, and equipped abilities are persistent.
- Server modules own all validation, timers, effects, scores, awards, and private-state filtering. Roact only renders synchronized client state.
- Monetization is limited to interfaces/configuration until product IDs, entitlement rules, and receipt requirements are supplied.

**Further Considerations**
1. Confirm the exact Blink package/repository/version and its code-generation workflow before Phase 0 implementation; the current project has no Blink dependency or local definitions.
2. Decide whether anime character names/power data are original placeholders or licensed/approved content before populating the production catalog; use generic test records in the first slice.
3. Keep the 5-second timer based on a server deadline/monotonic clock and send remaining-time snapshots, rather than trusting client countdowns.
