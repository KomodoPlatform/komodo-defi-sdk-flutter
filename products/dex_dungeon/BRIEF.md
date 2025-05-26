# DexDungeon – Game & Technical Brief (Komodo DeFi SDK)

## 1. Executive Summary

**DexDungeon: Komodo Edition** is a fast‑paced, procedurally generated roguelite in which every floor is guarded by a DeFi puzzle. Players spend, swap, and stake real on‑chain tokens through the **Komodo DeFi SDK** to buy power‑ups, open exits, and craft items that enhance their journey. The project's dual mission is to be _fun first_ while openly teaching players (and other studios) how to leverage Komodo's atomic‑swap technology inside a commercial‑grade game.

---

## 2. Vision & Goals

| Goal                           | Success Criteria                                                                          |
| ------------------------------ | ----------------------------------------------------------------------------------------- |
| **Fun, replayable core loop**  | ≥ 30‑minute average session length; Steam "Very Positive" user reviews.                   |
| **Showcase real Komodo swaps** | ≥ 75 % of active players complete at least one on‑chain swap in their first play‑session. |
| **Educational transparency**   | In‑game 'DeFi Console' shows raw HTLC JSON; post‑mortems include tx hashes.               |
| **Open‑source module samples** | Public GitHub repo with example Flutter/Flame + Komodo SDK bindings, MIT licensed.        |
| **Commercial sustainability**  | Cosmetic‑only NFT revenue covers > 120 % of monthly burn within 12 months.                |

---

## 3. Target Audience

- **Primary:** Roguelite & ARPG fans on PC who already dabble in crypto (Hades, Dead Cells, Diablo crowd).
- **Secondary:** DeFi enthusiasts/educators seeking tangible demos of cross‑chain swaps.
- **Tertiary:** Web3 studios evaluating Komodo SDK for their own titles.

---

## 4. Platforms & Distribution

| Phase              | Platforms                                                                                       |
| ------------------ | ----------------------------------------------------------------------------------------------- |
| **Alpha (closed)** | Windows PC via itch.io keys; Komodo Testnet only.                                               |
| **Beta (open)**    | Steam (PC, SteamDeck); WebGL build on [https://play.dexdungeon.io](https://play.dexdungeon.io). |
| **Launch**         | Steam, Epic Games Store, self‑hosted WebGL; Android (optional, stretch goal).                   |

---

## 5. Unique Selling Points

1. **DEX Portals** – every floor exit is a real-time atomic‑swap that teleports the player (and their assets) to a different dungeon area.
2. **On‑chain Vending Shrines** – swap in‑run loot‑tokens for stat‑boost items that enhance player abilities.
3. **Blockchain‑Seeded Procedural Generation** – dungeon seeds use transaction data ensuring verifiable, replayable runs.
4. **DeFi Console Overlay** – advanced users can watch raw RPC calls & track swap status mid‑combat.
5. **Verifiable Achievements** – fastest clears receive proof-of-completion tokens for community recognition.

---

## 6. Core Gameplay Loop

```mermaid
graph TD
    A[Spawn in Hub] -->|Enter Portal| B[Dungeon Floor]
    B --> C[Combat Rooms (3–6)]
    C --> D[Vending Shrine]
    D -->|Atomic Swap| C
    C --> E[Boss Room]
    E --> |DEX Exit Portal| B
    B -->|Last Floor| F[Treasure Vault / NFT Mint]
    F --> G[Return to Hub & Progression Menus]
```

- **Primary Currency (`FRAG`)** drops from enemies; it is an ERC‑20‑style token on _Komodo Chain_.
- **Atomic Swap Sequence** within shrines converts `FRAG → BOOST` (a temporary power‑up contract) or `FRAG → KMD` (for out‑of‑run upgrades).

---

## 7. Meta Progression & Economy

| Layer                     | Mechanic                                                       | On‑Chain?                         |
| ------------------------- | -------------------------------------------------------------- | --------------------------------- |
| **Gear Crafting**         | Merge collected tokens to forge permanent gear (rarity tiers). | ✅ – Custom token transactions    |
| **Estate Upgrades**       | Spend KMD to unlock new vendors, practice rooms.               | ✅ – Contract-managed treasury    |
| **Seasonal Battle‑Tomes** | Limited‑time cosmetic sets with free & premium tracks.         | ❌ – Off‑chain, keyed to account  |
| **Leaderboards**          | Fastest clear times per season & per area.                     | ✅ – Transaction-verified records |

**Tokenomics Quick View**

| Token          | Supply                  | Sink                          | Source                    |
| -------------- | ----------------------- | ----------------------------- | ------------------------- |
| `FRAG`         | Unlimited, inflationary | Swaps, crafting fees          | Enemy drops, recycle gear |
| `POWER`        | Max 3 × per run         | Expire at run end             | Shrine swap               |
| `KMD`          | Existing Komodo supply  | Estate upgrades, vanity items | External wallets, swaps   |
| Cosmetic Items | Scarce per season       | Recyclable for resources      | Battle pass, vault loot   |

---

## 8. DeFi & Komodo SDK Integration

### 8.1 Modules Used

| SDK Component            | Usage in Game                                                      |
| ------------------------ | ------------------------------------------------------------------ |
| **Atomic Swaps**         | Core `FRAG↔KMD` swaps; foundation for in-game economy.             |
| **Asset Management**     | Track player tokens, balances, and exchange rates.                 |
| **Transaction Handling** | Process all in-game economic actions with blockchain verification. |
| **Wallet Integration**   | Secure player assets with built-in wallet functionality.           |

### 8.2 Smart‑Contract/API Reference

```json
POST /mm2/rpc
{
  "userpass": "userpass_value",
  "method": "buy",
  "base": "FRAG",
  "rel": "KMD",
  "price": "0.0123",
  "volume": "250"
}
```

_All swap‑related endpoints map directly to Komodo AtomicDEX API. Use the built-in KomodoDefiSdk in Flutter (Dart) to sign & broadcast._

### 8.3 Transaction Flow Example – Shrine Purchase

1. **Player selects** `+20% Crit` power-up.
2. Client builds `buy` order for `FRAG → POWER` token exchange.
3. Komodo SDK processes the swap via AtomicDEX protocol.
4. Player defeats next wave ⇒ order completes ⇒ power-up is activated.
5. Game detects transaction success → Flame event system grants buff.

---

## 9. Technical Architecture

```
+-----------------------------+       +----------------------+
|      Flutter Client (Dart)      |       |   P2P Network Layer  |
|  - Gameplay & Rendering     | TCP   | - AtomicDEX protocol  |
|  - Komodo SDK Integration   |<----->| - Transaction Relay   |
+-------------+---------------+       +----------+-----------+
              | HTTPS (TLS)                         |
              v                                     v
+-------------+---------------+       +----------------------+
| Match / Social Service (TS) |<----->|  PostgreSQL (Cloud)  |
|  - REST + WebSocket         |       | - Users / Runs       |
+-------------+---------------+       +----------------------+
              |
              v
+-------------+---------------+
|  Analytics + BI (Metabase)  |
+-----------------------------+
```

- **Client → Chain** calls are direct; **no custodial backend** touches user funds.
- **Server‑authoritative** combat solved with deterministic lockstep + transaction verification.

### 9.1 Tech Stack

| Layer      | Tech                                                                                 |
| ---------- | ------------------------------------------------------------------------------------ |
| Engine     | Flutter 3.22 (stable), Flame 1.10, Forge2D; custom deterministic rollback networking |
| Blockchain | Komodo DeFi SDK v0.12 (May 2025) citeturn0search0                                 |
| Backend    | Node.js 20 (NestJS), Redis 7, PostgreSQL 15                                          |
| DevOps     | GitHub Actions CI; Docker; AWS EKS + Komodor (K8s observability)                     |
| QA         | Playwright (WebGL), flutter_test & flame_test, Foundry (smart‑contract tests)        |

---

## 10. Procedural Content Generation

- **Seed:** `sha256(transactionId‖playerUUID)` → guarantees verifiable public seed.
- **Room Graph:** Weighted grammar rules (treasure\:combat\:puzzle ratio 1:3:1).
- **Area Themes** change based on progression (e.g. _Crystal Caverns_, _Magma Depths_).
- **Difficulty Curve:** `HP = base × (1 + floorIndex^1.2)`.

---

## 11. Art & Audio Direction

| Element              | Spec                                                              |
| -------------------- | ----------------------------------------------------------------- |
| **Visual Style**     | Stylised low‑poly with emissive neon runes; 60 FPS target.        |
| **Colour Palette**   | Jade #00C08B, Gold #F6C453, Onyx #161616, Accent Magenta #FF3399. |
| **Character Design** | Reptile‑themed rogues; semi‑cartoon proportions; 15k tris.        |
| **UI/UX**            | Dark, translucent panels; compact DeFi console slide‑out.         |
| **Audio**            | Synthwave + tribal percussion; FMOD for adaptive layering.        |

---

## 12. Game Modes & Networking

| Mode                 | Player Count | Networking Model                                                  |
| -------------------- | ------------ | ----------------------------------------------------------------- |
| **Solo Roguelite**   | 1            | Offline / P2P optional for swaps                                  |
| **Co‑op Dungeons**   | 2–4          | Deterministic lockstep via Relay Server; host migration supported |
| **Community Events** | 1‑∞          | Seasonal challenges; boss HP scales with participation metrics.   |

---

## 13. Monetisation & Marketplace

- **Cosmetic NFTs** – skins, emotes, VFX trails. All mint tx fee paid by player.
- **Battle‑Tome Pass** – optional premium track (fiat via Stripe or `KMD`).
- **No Pay‑to‑Win:** Gameplay buffs reset each run; permanent gear is purely cosmetic or minor QoL.

---

## 14. Roadmap & Milestones (Tentative)

| Phase                  | Months | Key Deliverables                                          |
| ---------------------- | ------ | --------------------------------------------------------- |
| **Pre‑Production**     | 2      | Complete GDD, tech spikes, art bible                      |
| **Vertical Slice**     | 3      | One biome, shrine swap, boss, TX explorer overlay         |
| **Alpha**              | 4      | Procedural gen v1, Testnet swaps, basic multiplayer       |
| **Beta**               | 3      | All core content, main‑net, cosmetic NFT store, full QA   |
| **Launch**             |  –     | Steam & WebGL release; marketing push; Komodo blog series |
| **Post‑Launch Year 1** | 12+    | Season 1–3, mobile port, DAO governance rollout           |

---

## 15. Team & Roles

| Role                   | FTE | Responsibilities                     |
| ---------------------- | --- | ------------------------------------ |
| Creative Director      | 1   | Vision, narrative, gameplay cohesion |
| Producer               | 1   | Agile boards, milestones, budgeting  |
| Lead Gameplay Engineer | 1   | Combat, procedural gen               |
| Blockchain Engineer    | 1   | SDK integration, smart contracts     |
| Backend Engineer       | 1   | Matchmaking, analytics, REST         |
| Gameplay Programmers   | 2   | Abilities, AI, tools                 |
| Tech Artist            | 1   | Shaders, VFX, pipeline               |
| 3D Artists             | 2   | Characters, environments             |
| UI/UX Designer         | 1   | HUD, menus, typography               |
| Audio Designer         | 0.5 | Music & SFX (contract)               |
| QA Lead                | 1   | Test plans, automation               |
| Community Manager      | 0.5 | Socials, Discord, feedback loops     |

---

## 16. Toolchain & Workflow

- **Version Control:** GitHub mono‑repo, trunk‑based. Feature flags via JSON configuration files.
- **Issue Tracking:** Jira Cloud; conventional commits for changelogs.
- **CI/CD:** GitHub Actions → Buildkite → S3 + CloudFront for WebGL; SteamPipe for PC.
- **Testing:** CI unit tests >90 % coverage for core libraries; nightly end‑to‑end smoke on staging chain.
- **Monitoring:** Sentry (client), Datadog (backend), Komodor for K8s health.

---

## 17. Risk & Mitigation

| Risk                      | Impact                              | Likelihood | Mitigation                                                         |
| ------------------------- | ----------------------------------- | ---------- | ------------------------------------------------------------------ |
| High transaction fees     | Breaks swap affordability           | Medium     | Transaction batching; notify players; dynamic fee-free events      |
| Asset verification issues | Economy imbalance                   | Low        | Server-side transaction verification + periodic audits             |
| Regulatory changes        | Monetisation halted in some regions | Medium     | Region-based cosmetic sales; legal counsel                         |
| SDK breaking changes      | Dev timeline slip                   | Low        | Pin to stable version; CI integration tests; active Komodo support |

---

## 18. KPIs & Analytics

- **Gameplay:** Avg floor reached, run length, boss kill %.
- **Economy:** Swap volume (`FRAG↔KMD`), NFT mint counts, liquidity depth.
- **Monetisation:** ARPPU, conversion rate Battle‑Tome.
- **Community:** Discord MAU, bug report close‑time, DAO vote turnout.

---

## 19. Accessibility & Localization

| Feature             | Supported                                 |
| ------------------- | ----------------------------------------- |
| Remappable Controls | ✅                                        |
| Colour‑blind Modes  | ✅ (Protanopia, Deuteranopia, Tritanopia) |
| Subtitles & TTS     | ✅                                        |
| Languages at Launch | EN, ES‑LA, PT‑BR, RU, CN‑S, JP            |

---

## 20. Legal & Compliance

- **EULA & Privacy Policy** drafted with blockchain disclosures.
- **KYC/AML:** Only for off‑chain fiat purchases; crypto‑only users remain pseudonymous.
- **GDPR:** Opt‑in analytics; data stored in EU region (Amsterdam).

---

## 21. External References

- Komodo Roadmap 2024–2025 citeturn0search0
- Komodo DeFi Framework GitHub citeturn0search8
- Komodo Wallet v0.8 release notes citeturn0search1

---

### End of Brief

> _Prepared 24 May 2025 – Document v1.0_
