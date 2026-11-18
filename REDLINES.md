# Red-Line Compliance Checklist

Each safety red line from the official Agent ID Hackathon announcement, mapped to
how AgentMark complies. (Announcement: Binance support article, Agent ID Hackathon,
60,000 USDC.)

| # | Red line (announcement) | How AgentMark complies |
|---|---|---|
| 1 | **No web-based QR-code login for Agentic Wallet.** Projects must not let users scan QR codes or enter pairing codes on third-party websites to sign in, nor store users' login sessions on servers to place orders on their behalf. | The web page has **no login at all**. It connects only through the visitor's own injected wallet provider (`window.ethereum`, EIP-1193) and asks the wallet to switch to BNB Chain (56). There is no QR code, no pairing code, no account system, and **no server** — the page is a single static HTML file; nothing is stored anywhere. |
| 2 | **No bypassing user transaction confirmation.** Skills/flows must not contain prompts that attempt to bypass confirmation; users must see and confirm asset actions themselves. | Every action (`mintBadge`, `checkIn`) is a plain `eth_sendTransaction` initiated by a button click and confirmed by the user inside their own wallet UI. The page never signs, never auto-sends, and contains no instruction designed to skip a confirmation. |
| 3 | **No unauthorized asset transfers.** No scheduled collection, automatic transfers to fixed addresses, bundled extra transfers, or soliciting unlimited approvals without the user's knowledge. | The contract **cannot move any user asset**: badges are soulbound (all transfer paths revert), the contract holds no funds and has no withdraw function, there are no approvals to solicit (`approve`/`setApprovalForAll` revert), no scheduled or bundled anything. Minting moves nothing except creating the caller's own badge. |
| 4 | **Contracts must be open-source with disclosed owner permissions.** Minting, tax, pause, freeze, and fund-withdrawal powers must be clearly documented. | Contract source is public (this repo, MIT) and will be BscScan-verified at deployment. **Owner permissions: NONE.** There is no owner or admin role in the code at all — no mint-on-behalf, no pause, no freeze, no tax, no withdraw, no upgrade. The only configuration is set once in the constructor and is immutable: the Agent ID contract address and the metadata base URI. This is stated in the contract's NatSpec header and in the README. |
| 5 | **No impersonation of the Binance brand.** Project/token names and domains must not use "Binance"/"BNB" to impersonate the official brand. | Project name **AgentMark**, token name **AgentMark Badge**, symbol **AMARK** — no "Binance", no "BNB", no lookalike branding anywhere in the name, code, page, or copy. (The page mentions "BNB Chain (56)" only as a factual network label for the chain selector.) |
| 6 | **No collection of sensitive credentials.** No seed phrases, private keys, API secrets, or pairing codes. | The page and contract never ask for, receive, or transmit any credential. The only input is a wallet connection through the injected provider; the only data read is public on-chain state. |
| 7 | **No promising returns.** Terms such as "passive income" or "automatic money-making" are prohibited. | Copy everywhere (page, README, submission, planned posts) describes the badge as an identity/participation mark that "carries no monetary value and promises no returns". The badge is free, non-transferable (cannot be sold), and attached to no token, pool, or reward mechanism. |
| 8 | **Trading products must display risk warnings.** | Not applicable — AgentMark has no trading, swapping, pricing, or market feature of any kind. |
| 9 | **Agent ID must not be packaged as a tool for looking up other people's wallets by name.** | AgentMark has **no directory, search, or lookup feature**. It never resolves names to wallets and never displays anyone else's data. The only lookups are the visitor checking *their own* connected address's status. Public view functions expose only the same per-address facts any block explorer shows. |
| 10 | **No abnormal behaviour / manipulation.** No malicious volume manipulation, illegitimate mass account registration for interactions, or market manipulation. | Growth is organic-only by policy: we operate a single wallet (officialcorpltd.ai) and will not create or borrow wallets to inflate interaction counts. Contract design itself resists gaming: minting requires holding a real (non-transferable) Agent ID, is limited to 1 per address ever, and check-ins are limited to 1 per address per day — there is no mechanism to manufacture volume. |

## Pre-submission verification

- [x] Contract compiles (solc 0.8.24, optimizer 200 runs)
- [x] 15/15 unit tests pass, including every gate/revert case
- [ ] Contract deployed to BNB Chain mainnet and source verified on BscScan *(phase 2 — requires explicit go + signing)*
- [ ] Web page pointed at the deployed contract address
- [ ] Submission materials sent inside the window (before 2026-12-09 08:00 UTC)
