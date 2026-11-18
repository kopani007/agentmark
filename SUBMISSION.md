# Hackathon Submission — AgentMark

*Agent ID Hackathon — Binance Wallet × BNB Chain. Submission window closes
2026-12-09 08:00 UTC. Submit through the official channel linked from the
announcement.*

## Project name

**AgentMark**

## Website

**https://agentmark.officialcorpltd.workers.dev** — LIVE. A single Cloudflare Worker
serves the dApp page (from `web/index.html` in this repo), the badge artwork at
`/badge.png`, and ERC-721 metadata at `/metadata/<tokenId>`.

## Contract address(es) — BNB Chain mainnet

| Contract | Address |
|---|---|
| AgentMarkBadge | `0xBC682D5CF1aD8fFAE05BA119cf88BD6EDE75267C` |
| Agent ID (dependency, not ours) | `0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F` |

**Status: DEPLOYED on BNB Chain mainnet (2026-11-18).** AgentMarkBadge was deployed
via CREATE2 through the CreateX factory (`0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed`)
from officialcorpltd.ai with a wallet-guarded salt, so its address is deterministic
and matched the address predicted by simulation on two independent BSC RPCs before
deployment. Deployment tx:
[`0xade61c6cca498fd79a4d94a22ab3df2b10cec87b067bf965493f2c11c678a9c2`](https://bscscan.com/tx/0xade61c6cca498fd79a4d94a22ab3df2b10cec87b067bf965493f2c11c678a9c2).
Metadata base URI (constructor):
`https://agentmark.officialcorpltd.workers.dev/metadata/` (`tokenURI = baseURI + tokenId`).

Source code: public (MIT) at **https://github.com/kopani007/agentmark**.
Verification status:

- **Sourcify: EXACT MATCH** (creation + runtime bytecode), verified 2026-11-18 —
  https://sourcify.dev/#/lookup/0xBC682D5CF1aD8fFAE05BA119cf88BD6EDE75267C
- **BscScan: VERIFIED** (2026-11-18, submitted by the project owner from his own
  device via the public web form — the automated browser route was blocked by
  Cloudflare Turnstile). Contract page:
  https://bscscan.com/address/0xBC682D5CF1aD8fFAE05BA119cf88BD6EDE75267C#code

## What the project does

AgentMark is a free, soulbound badge and daily check-in dApp for Agent ID holders.
An address that holds an Agent ID can mint one non-transferable AgentMark Badge and
then check in once per day; the contract tracks each holder's total check-ins and
consecutive-day streak and emits an event per check-in, creating a public
"identity + liveness" record for agent wallets.

## Agent ID usage description

Agent ID is the access-control core of the product:

- The badge contract stores the official Agent ID contract address
  (`0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F`) as an immutable.
- **Every** state-changing function — `mintBadge()` and `checkIn()` — first performs
  a live on-chain check, `agentId.balanceOf(msg.sender) > 0`, against the Agent ID
  contract, and reverts if the caller does not currently hold an Agent ID. The
  check is re-evaluated on every transaction, never cached.
- The web front end reads Agent ID status live from the same contract and reflects
  it in the UI (holds Agent ID → mint enabled; badge owned → daily check-in
  enabled).
- Public view functions (`isAgentIdHolder`, `hasBadge`, `tokenIdOf`,
  `checkInStats`) let any other dApp reuse the same Agent ID gate and the
  activity record it produces.

## Why it fits the hackathon

- **Access control / identity** is one of the announcement's named use cases for
  Agent ID; AgentMark is a complete, working product built entirely on it.
- Live during the whole submission window; every mint is one interacting Agent ID
  address and every daily check-in is a further transaction from a verified
  Agent ID holder, driven by streaks rather than incentives.
- Safety by construction: no owner/admin powers at all, soulbound (non-transferable)
  badges, no funds held, no approvals solicited, no QR/pairing login, no credential
  collection, no return promises, no wallet-lookup features. Full mapping in
  `REDLINES.md`.

## Team / contact

- Built and operated by the team behind **officialcorpltd.ai** (Agent ID holder).
- Contact: X — @OfficialCorpLtd

## Checklist before submitting

- [x] Deploy `AgentMarkBadge` to BNB Chain mainnet with constructor args
      `(0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F, https://agentmark.officialcorpltd.workers.dev/metadata/)`
      via CreateX `deployCreate2` — deployed at
      `0xBC682D5CF1aD8fFAE05BA119cf88BD6EDE75267C`, tx `0xade61c6c…a9c2`
- [x] Verify source — Sourcify exact match (link above) AND BscScan verified
      2026-11-18 (owner-submitted web form)
- [x] Push this repo public — https://github.com/kopani007/agentmark (LICENSE included)
- [x] Host `web/index.html` with the final address filled in — LIVE at the URL above
      (Worker also serves `/badge.png` and `/metadata/<tokenId>`)
- [x] Smoke test from officialcorpltd.ai: mint + check-in on mainnet — done
      2026-11-18 (Badge #1 minted, check-in #1 recorded)
- [ ] Launch post on X; begin daily check-in promotion
- [ ] Watch `totalMinted()` — Innovation eligibility needs ≥30 Agent ID addresses
- [x] Submit before 2026-12-09 08:00 UTC — SUBMITTED 2026-11-18 20:12 WIB
      ("Submitted Successfully" confirmation screen; reward address
      0xeF28f36f0d19008056fD94A73131314A55C4ABf7, team OfficialCorpLtd)
- [x] Demo video (58 s, narrated) — https://raw.githubusercontent.com/kopani007/agentmark/main/demo.mp4
