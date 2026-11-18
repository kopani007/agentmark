# AgentMark

**A soulbound badge + daily check-in for Agent ID holders on BNB Chain.**

AgentMark turns your Agent ID into an active on-chain mark. If your wallet holds an
Agent ID, you can mint the AgentMark Badge — free, one per address, non-transferable —
and check in daily to build a public streak. Agent ID ownership is verified **live,
on-chain, on every action**: no Agent ID, no badge, no check-in.

The badge is an identity and participation mark. It carries no monetary value and
promises no returns.

Built for the Binance Wallet × BNB Chain **Agent ID Hackathon** (2026).

## How it works

| Action | Requirement | Limit |
|---|---|---|
| `mintBadge()` | `balanceOf(you) > 0` on the Agent ID contract, checked live at mint time | 1 per address, ever |
| `checkIn()` | Same live Agent ID check + you own the badge | 1 per UTC day |

- **Agent ID contract (BNB Chain):** `0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F` (SPACE ID Agent ID)
- **Badge contract (BNB Chain):** `0xBC682D5CF1aD8fFAE05BA119cf88BD6EDE75267C` — **DEPLOYED**
  on BNB Chain mainnet via CREATE2 (CreateX factory) from officialcorpltd.ai, so the
  address is deterministic and was fixed before launch. Deployment tx:
  [`0xade61c6cca498fd79a4d94a22ab3df2b10cec87b067bf965493f2c11c678a9c2`](https://bscscan.com/tx/0xade61c6cca498fd79a4d94a22ab3df2b10cec87b067bf965493f2c11c678a9c2)
- **Source verification:** **exact match on Sourcify** (creation + runtime bytecode) —
  [sourcify.dev lookup](https://sourcify.dev/#/lookup/0xBC682D5CF1aD8fFAE05BA119cf88BD6EDE75267C).
  Direct BscScan verification is pending a BscScan API key (identical source and
  compiler settings; see `SUBMISSION.md`).
- **Web app:** **https://agentmark.officialcorpltd.workers.dev** — a single Cloudflare
  Worker serving the dApp page (`web/index.html`), the badge artwork (`/badge.png`) and
  ERC-721 metadata (`/metadata/<tokenId>`, matching `tokenURI = baseURI + tokenId`).
  No accounts, no backend session.

Check-ins emit a `CheckedIn(holder, day, streak, total)` event, so "active agent"
history is publicly readable by anyone — including other dApps that want to gate on
*identity + recent activity* instead of identity alone.

## Owner permissions: NONE

This contract has **no owner and no admin role**. There is no pause, no freeze, no
tax, no withdraw, no upgrade path, and no way to mint on behalf of someone else.
The Agent ID contract address and the metadata base URI are set once in the
constructor and are immutable. The only way a badge can exist is an Agent ID holder
minting it for their own address.

Badges are **soulbound**: `transferFrom`, `safeTransferFrom`, `approve`, and
`setApprovalForAll` all revert.

## Repository layout

```
contracts/AgentMarkBadge.sol   the badge + check-in contract (the product)
contracts/MockAgentID.sol      test-only stand-in for the Agent ID contract
tests/AgentMarkBadge.t.sol     Foundry test suite (15 tests)
web/index.html                 static dApp page (injected wallet provider only)
scripts/measure_gas.py         local gas measurement helper (anvil)
DESIGN.md                      concept, judging-criteria mapping, growth plan
REDLINES.md                    hackathon red-line compliance checklist
SUBMISSION.md                  hackathon submission materials (draft)
```

## Build & test

Requires [Foundry](https://getfoundry.sh).

```bash
forge build
forge test
```

All 15 tests pass, covering: holder mints; non-holder mint reverts; second mint
reverts; transfers and approvals revert (soulbound); holder check-in works;
non-holder check-in reverts; check-in without a badge reverts; second check-in on
the same day reverts; next-day streak increments; streak resets after a gap; and
the gate following live Agent ID balance changes.

## Gas (measured locally, anvil)

| Operation | Gas |
|---|---|
| Deploy `AgentMarkBadge` | 842,144 |
| `mintBadge()` | 101,915 |
| `checkIn()` (first) | 120,507 |

At the BNB Chain gas price observed on 2026-11-18 (0.05 gwei, agreed by two public
RPCs), deployment costs ≈ **0.0000421 BNB (≈ $0.025)** and a user interaction costs
well under a cent. Even at a conservative 1 gwei, deployment is ≈ 0.000842 BNB
(≈ $0.50). BNB price reference: $589.35 (CoinGecko, 2026-11-18).

## Safety design

- No QR-code / pairing-code sign-in; the page uses only the visitor's injected
  wallet provider, and every transaction is confirmed by the user in their wallet.
- No credentials are ever requested or stored; there is no backend.
- No lookup/directory features — Agent ID is used purely as an access gate for the
  caller's own actions.
- See `REDLINES.md` for the full checklist.

## License

MIT — see `LICENSE` and the SPDX headers in each source file.
