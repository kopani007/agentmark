# BscScan manual verification — copy these values exactly

Contract already deployed. Open https://bscscan.com/verifyContract and fill:

## Step 1

- Contract Address: `0xBC682D5CF1aD8fFAE05BA119cf88BD6EDE75267C`
- Compiler Type: **Solidity (Single file)**
- Compiler Version: **v0.8.24+commit.e11b9ed9**
- Open Source License Type: **MIT License (MIT)**
- Tick the terms-of-service agreement, then Continue.

## Step 2

- **Source code**: open the raw file
  https://raw.githubusercontent.com/kopani007/agentmark/main/contracts/AgentMarkBadge.sol
  in another tab, select all, copy, and paste it into the source box.
- Optimization: **Yes**
- Runs (Optimizer): `200`
- EVM Version: **cancun (default for >= v0.8.24)**
- License Type: **MIT License (MIT)**
- Constructor Arguments ABI-encoded (paste WITHOUT any 0x prefix, one line):

```
00000000000000000000000060b9262456de011f7d15a54cdd8c48baaa8b022f0000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000003768747470733a2f2f6167656e746d61726b2e6f6666696369616c636f72706c74642e776f726b6572732e6465762f6d657461646174612f000000000000000000
```

- Complete the Cloudflare check, then click **Verify and Publish** /
  "Submit source code for verification".

Expected result: "Contract successfully verified" and a green checkmark on
https://bscscan.com/address/0xBC682D5CF1aD8fFAE05BA119cf88BD6EDE75267C#code
