// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title MockAgentID
/// @notice Test-only stand-in for the SPACE ID Agent ID contract
///         (0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F on BNB Chain).
///         Implements only what AgentMarkBadge reads: balanceOf(address).
///         NOT for deployment — production uses the real Agent ID contract.
contract MockAgentID {
    mapping(address => uint256) private _balances;

    /// @notice Test helper: grant an "Agent ID" to an account.
    function mockMint(address to) external {
        _balances[to] += 1;
    }

    /// @notice Test helper: remove an account's "Agent ID".
    function mockBurn(address from) external {
        if (_balances[from] > 0) _balances[from] -= 1;
    }

    function balanceOf(address owner) external view returns (uint256) {
        return _balances[owner];
    }
}
