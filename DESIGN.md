# AgentMark — Design

*Binance Wallet × BNB Chain — Agent ID Hackathon (submission window 2026-11-18 08:00 UTC → 2026-12-09 08:00 UTC)*

## Project name candidates

None of the candidates use "Binance" or "BNB" (hackathon red line: no brand impersonation).

| # | Name | Why |
|---|------|-----|
| 1 | **AgentMark** ⭐ (recommended) | Short, ownable, says exactly what it is: the *mark* of a verified agent. Works as product name, badge name ("AgentMark Badge", symbol `AMARK`), and domain. |
| 2 | Agent Signet | A signet is a personal seal of identity — elegant, but "signet" is less immediately understood by non-native speakers. |
| 3 | Agent Passport | Very intuitive ("your on-chain passport for Agent ID holders"), but longer and a well-worn metaphor in web3. |

**Recommendation: AgentMark.** This document and the code use AgentMark throughout; renaming later is a string change only.

## What it is

AgentMark is a free, soulbound badge + daily check-in dApp for Agent ID holders on BNB Chain.

- **Badge** — an ERC-721 token that is **non-transferable** (soulbound), **free** to mint, **one per address**, and can only be minted by an address that **currently holds an Agent ID**. Contract: `contracts/AgentMarkBadge.sol`.
- **Daily check-in** — badge holders check in once per UTC day. The contract tracks total check-ins and consecutive-day streaks per address and emits a `CheckedIn` event for every check-in.
- **Web page** — a single static page (`web/index.html`) that connects through the visitor's own injected wallet provider, shows their live Agent ID / badge / check-in status, and offers the mint and check-in buttons. No accounts, no server, no sessions.

## How Agent ID is integrated (the core flow)

Agent ID is not decoration — it is the access-control layer for every user action:

1. The contract stores the official Agent ID contract address (`0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F`, SPACE ID Agent ID) as an **immutable** set at deployment.
2. `mintBadge()` is wrapped in an `onlyAgentIdHolder` modifier: it performs a **live** `balanceOf(msg.sender) > 0` call against the Agent ID contract at mint time (exactly the holding check the announcement specifies). No Agent ID → revert (`NotAgentIdHolder`).
3. `checkIn()` runs the **same live check on every call** — the gate is re-evaluated per transaction, not cached at mint time. (Unit test `test_GateReadsLiveAgentIdBalance` proves the gate follows live balance changes.)
4. The web page reads Agent ID status live (`balanceOf` on the Agent ID contract + the badge's `isAgentIdHolder`) and enables/disables actions accordingly.

Because Agent IDs are themselves non-transferable, a soulbound badge gated by a live Agent ID check gives a durable, sybil-resistant "this wallet is a registered agent" mark that any other dApp could also read (`hasBadge`, `tokenIdOf`, `isAgentIdHolder` are public views).

## Mechanics

| Action | Gate | Cost to user | Limit | On-chain effect |
|---|---|---|---|---|
| `mintBadge()` | Agent ID `balanceOf > 0` (live) | gas only (≈102k gas measured locally) | 1 per address, ever | Soulbound ERC-721 minted; `BadgeMinted` + `Transfer(0x0 → holder)` events |
| `checkIn()` | Agent ID `balanceOf > 0` (live) + badge owned | gas only (≈121k gas first time, less after) | 1 per UTC day | total/streak counters updated; `CheckedIn(holder, day, streak, total)` event |

Contract properties:

- **No owner, no admin, no pause, no freeze, no withdraw, no upgrade, no mint-on-behalf.** There is no privileged role at all (see REDLINES.md). The only way a badge exists is a holder minting it for themselves.
- Soulbound enforced by reverting every transfer/approval path (`transferFrom`, both `safeTransferFrom` overloads, `approve`, `setApprovalForAll`) with a `Soulbound` error.
- Day boundary is the UTC day (`block.timestamp / 1 days`); streak increments on consecutive days and resets after a gap.

## Mapping to the Innovation Award judging criteria

| Criterion (weight) | How AgentMark addresses it |
|---|---|
| **Agent ID Application Depth (30%)** | Agent ID *is* the product's permission layer: both state-changing functions re-verify live Agent ID ownership on-chain against the official contract on every call. Remove Agent ID and the product cannot function at all. The badge also exposes public views so *other* projects can build on the same gate. |
| **Practicality & Feasibility (25%)** | Agent-gated access is the exact pattern the ecosystem already uses (Agent-ID-gated mints/claims are live across BNB Chain today). AgentMark packages it as a reusable, verifiable identity mark + engagement primitive any agent community can adopt. Everything runs on cheap BSC gas (≈$0.003 per interaction at current prices), so real usage is economically trivial. |
| **Product Completion (25%)** | Fully working end-to-end at submission: deployed + BscScan-verified open-source contract, live static dApp (connect, status, mint, check-in), 15 passing unit tests covering every gate and edge case, documented red-line compliance. No mock or "coming soon" core features. |
| **Innovation (20%)** | Turns a static identity NFT into an *activity credential*: the badge is minted once, but the daily check-in builds a public, event-based proof-of-active-agent record (streaks/totals readable by anyone). This "identity + liveness" combination is a new primitive for agent ecosystems — e.g., future drops, allowlists, or rate limits can require "Agent ID + active in the last 7 days" instead of identity alone. |

## Mapping to the Growth Award metrics

The Growth track ranks by (a) number of interacting Agent ID addresses, (b) transaction volume / count — using only the submitted contract addresses and only Agent ID holder addresses.

- **Unique Agent ID addresses:** every badge mint is exactly one new interacting Agent ID address, by construction (the gate guarantees it). Target metric = `totalMinted()`.
- **Transaction count:** daily check-ins create a recurring, legitimate reason for holders to transact with the contract every day for the whole 3-week window (up to 21 check-ins per holder). Streaks make day-1 minters come back.
- **No wash mechanics:** interactions are gated to real Agent ID holders, cost the user real (if tiny) gas, are rate-limited by the contract itself (1 mint ever, 1 check-in/day), and are never incentivized with return promises. Growth comes only from genuine promotion to the Agent ID holder community.

## The ≥30 Agent ID holders plan (Innovation eligibility floor)

Eligibility needs ≥30 distinct Agent ID addresses interacting during the window. Plan, in order:

1. **Day 0 — our own interaction:** deploy, then mint + check in from officialcorpltd.ai (a genuine Agent ID holder) to smoke-test mainnet end-to-end. (1 address)
2. **Launch post on X** from @OfficialCorpLtd (1,543 followers, an account whose audience is precisely the Binance agent-wallet crowd that has been minting Agent-ID-gated drops all month — PXIO, Humanova, Contextgraph, etc.). Post includes the dApp link, "free, gas only, 1 minute" framing — no return promises.
3. **Cross-promote in the same communities** that run Agent-ID-gated projects (their holders are Agent ID holders by definition). The badge is positioned as complementary ("mark your agent"), not competitive.
4. **Daily streak content:** short daily X reminder posts during the window ("Day N — check in to keep your streak") double as repeated discovery surfaces for new minters.
5. **Referral-free, sybil-free by design:** we operate only officialcorpltd.ai; we will not create or use other wallets to inflate counts (also a hackathon disqualification risk). If organic reach stalls below 30, escalate promotion (community reposts, quote-posts by friendly agent accounts) rather than manufacturing interactions.

Realistic read: the Agent-ID-gated mint scene routinely draws hundreds of unique holders per project (Contextgraph's Graph 2 alone had 146 unique participants), so 30 organic holders in 3 weeks is a conservative target for a free mint with an existing, on-topic audience.

## Roadmap inside the window

| When | Milestone |
|---|---|
| 2026-11-18/19 | Phase 1 build (this repo): contract, tests, web, docs ✅ |
| Next (needs J's go + top-up) | Deploy to BSC mainnet, verify on BscScan, publish repo, point web page at the live contract, own mint/check-in smoke test |
| Launch day | X launch post + community cross-promotion |
| Daily to 2026-12-09 | Check-in streak reminders; monitor `totalMinted()` against the 30-holder floor |
| Before 2026-12-09 08:00 UTC | Submit project materials (SUBMISSION.md) |
| Optional stretch | Metadata/artwork for the badge (IPFS), a public "recent check-ins" feed on the web page reading `CheckedIn` events |

## Deliberate non-features (red-line driven)

- No wallet-lookup / directory / "search an agent by name" feature — prohibited by the announcement and excluded by design.
- No QR-code or pairing-code sign-in; no server-side sessions (there is no server at all).
- No token, no sale, no staking, no rewards pool, nothing that could be read as a return promise.
