#!/usr/bin/env python3
"""Local-only gas measurement: deploys AgentMarkBadge to a local anvil
instance and reports gasUsed for deployment, mintBadge and checkIn.
No external network, no real keys (anvil's unlocked dev account)."""
import json
import urllib.request

RPC = "http://127.0.0.1:8545"
DEPLOYER = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"  # anvil dev account #0


def rpc(method, params):
    req = urllib.request.Request(
        RPC,
        data=json.dumps({"jsonrpc": "2.0", "id": 1, "method": method, "params": params}).encode(),
        headers={"Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req) as r:
        out = json.load(r)
    if "error" in out:
        raise RuntimeError(out["error"])
    return out["result"]


def send(tx):
    h = rpc("eth_sendTransaction", [tx])
    receipt = rpc("eth_getTransactionReceipt", [h])
    assert receipt["status"] == "0x1", f"tx failed: {h}"
    return receipt


def enc_address(a):
    return a.lower().replace("0x", "").rjust(64, "0")


def enc_string(s):
    b = s.encode()
    pad = (32 - len(b) % 32) % 32
    return len(b).to_bytes(32, "big").hex() + (b + b"\x00" * pad).hex()


with open("/tmp/mock-bytecode.txt") as f:
    mock_code = f.read().strip()
with open("/tmp/badge-bytecode.txt") as f:
    badge_code = f.read().strip()

# 1. Deploy mock
r = send({"from": DEPLOYER, "data": mock_code})
mock_addr = r["contractAddress"]
print(f"MockAgentID deployed: {mock_addr} (deploy gas {int(r['gasUsed'], 16)})")

# 2. Deploy badge: constructor(address, string)
args = enc_address(mock_addr) + (64).to_bytes(32, "big").hex() + enc_string("ipfs://agentmark/")
r = send({"from": DEPLOYER, "data": badge_code + args})
badge_addr = r["contractAddress"]
deploy_gas = int(r["gasUsed"], 16)
print(f"AgentMarkBadge deployed: {badge_addr}")
print(f"DEPLOY_GAS={deploy_gas}")

# 3. Grant mock Agent ID to deployer, then mint + check-in
send({"from": DEPLOYER, "to": mock_addr, "data": "0x12e87ced" + enc_address(DEPLOYER)})
r = send({"from": DEPLOYER, "to": badge_addr, "data": "0xda1b3cb0"})
print(f"MINT_GAS={int(r['gasUsed'], 16)}")
r = send({"from": DEPLOYER, "to": badge_addr, "data": "0x183ff085"})
print(f"CHECKIN_GAS={int(r['gasUsed'], 16)}")

runtime_len = (len(badge_code) - 2) // 2
print(f"CREATION_BYTECODE_BYTES={runtime_len}")
