// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice Minimal interface for the SPACE ID Agent ID contract (BNB Chain).
///         Agent ID contract: 0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F
///         Holding check per the hackathon announcement: balanceOf(address) > 0.
interface IAgentID {
    function balanceOf(address owner) external view returns (uint256);
}

/// @title AgentMarkBadge
/// @notice A soulbound (non-transferable) ERC-721 badge that only Agent ID
///         holders can mint — one per address, free — plus a daily check-in
///         that is gated by the same Agent ID holding check.
///
///         Agent ID is the access-control core of this product: every
///         state-changing user action (mint, check-in) first verifies
///         `agentId.balanceOf(msg.sender) > 0` against the official
///         Agent ID contract on BNB Chain.
///
/// @dev OWNER POWERS: NONE. This contract has no owner, no admin role, no
///      pause, no freeze, no withdraw, no upgrade path, and no way to mint
///      on behalf of another address. The Agent ID contract address and the
///      metadata base URI are set once in the constructor and are immutable.
///      The only way a badge can come into existence is `mintBadge()` called
///      by an Agent ID holder for their own address.
contract AgentMarkBadge {
    // ------------------------------------------------------------------
    // ERC-721 metadata
    // ------------------------------------------------------------------
    string public constant name = "AgentMark Badge";
    string public constant symbol = "AMARK";

    /// @notice The official Agent ID (SPACE ID) contract on BNB Chain.
    IAgentID public immutable agentId;

    /// @notice Metadata base URI (tokenURI = baseURI + tokenId). Immutable.
    string private _baseTokenURI;

    // ------------------------------------------------------------------
    // State
    // ------------------------------------------------------------------
    uint256 private _nextTokenId = 1;

    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _tokenIdOf; // 0 = no badge

    /// @notice Total badges minted so far.
    uint256 public totalMinted;

    struct CheckInStats {
        uint256 totalCheckIns;
        uint256 currentStreak;
        uint256 bestStreak;
        uint256 lastCheckInDay; // UTC day number (block.timestamp / 86400)
    }

    mapping(address => CheckInStats) private _checkIns;

    // ------------------------------------------------------------------
    // Events
    // ------------------------------------------------------------------
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event BadgeMinted(address indexed holder, uint256 indexed tokenId);
    event CheckedIn(
        address indexed holder, uint256 indexed day, uint256 currentStreak, uint256 totalCheckIns
    );

    // ------------------------------------------------------------------
    // Errors
    // ------------------------------------------------------------------
    error NotAgentIdHolder();
    error AlreadyHasBadge();
    error Soulbound();
    error AlreadyCheckedInToday();
    error NoBadge();
    error NonexistentToken(uint256 tokenId);
    error ZeroAddress();

    constructor(address agentIdContract, string memory baseTokenURI) {
        if (agentIdContract == address(0)) revert ZeroAddress();
        agentId = IAgentID(agentIdContract);
        _baseTokenURI = baseTokenURI;
    }

    // ------------------------------------------------------------------
    // Agent ID gate
    // ------------------------------------------------------------------
    /// @notice True if `account` currently holds at least one Agent ID.
    function isAgentIdHolder(address account) public view returns (bool) {
        return agentId.balanceOf(account) > 0;
    }

    modifier onlyAgentIdHolder() {
        if (!isAgentIdHolder(msg.sender)) revert NotAgentIdHolder();
        _;
    }

    // ------------------------------------------------------------------
    // Mint (free, 1 per address, Agent-ID-gated)
    // ------------------------------------------------------------------
    /// @notice Mint your badge. Free (no value accepted or required),
    ///         one per address, caller must hold an Agent ID.
    function mintBadge() external onlyAgentIdHolder {
        if (_tokenIdOf[msg.sender] != 0) revert AlreadyHasBadge();

        uint256 tokenId = _nextTokenId++;
        _owners[tokenId] = msg.sender;
        _tokenIdOf[msg.sender] = tokenId;
        totalMinted += 1;

        emit Transfer(address(0), msg.sender, tokenId);
        emit BadgeMinted(msg.sender, tokenId);
    }

    // ------------------------------------------------------------------
    // Daily check-in (Agent-ID-gated, one per UTC day)
    // ------------------------------------------------------------------
    /// @notice Check in for today (UTC). Requires holding an Agent ID and
    ///         having minted a badge. Tracks total count and day streaks.
    ///         Emits CheckedIn so participation is publicly countable.
    function checkIn() external onlyAgentIdHolder {
        if (_tokenIdOf[msg.sender] == 0) revert NoBadge();

        uint256 today = block.timestamp / 1 days;
        CheckInStats storage s = _checkIns[msg.sender];
        // totalCheckIns > 0 guard: a fresh account has lastCheckInDay == 0,
        // which must not collide with day 0.
        if (s.totalCheckIns > 0 && s.lastCheckInDay == today) {
            revert AlreadyCheckedInToday();
        }

        if (s.totalCheckIns > 0 && today > 0 && s.lastCheckInDay == today - 1) {
            s.currentStreak += 1;
        } else {
            s.currentStreak = 1;
        }
        if (s.currentStreak > s.bestStreak) s.bestStreak = s.currentStreak;
        s.totalCheckIns += 1;
        s.lastCheckInDay = today;

        emit CheckedIn(msg.sender, today, s.currentStreak, s.totalCheckIns);
    }

    // ------------------------------------------------------------------
    // Views
    // ------------------------------------------------------------------
    /// @notice True if `account` has minted a badge.
    function hasBadge(address account) external view returns (bool) {
        return _tokenIdOf[account] != 0;
    }

    /// @notice Badge token id owned by `account` (0 if none).
    function tokenIdOf(address account) external view returns (uint256) {
        return _tokenIdOf[account];
    }

    /// @notice Check-in statistics for `account`.
    function checkInStats(address account)
        external
        view
        returns (
            uint256 totalCheckIns,
            uint256 currentStreak,
            uint256 bestStreak,
            uint256 lastCheckInDay
        )
    {
        CheckInStats storage s = _checkIns[account];
        return (s.totalCheckIns, s.currentStreak, s.bestStreak, s.lastCheckInDay);
    }

    /// @notice Whether `account` has already checked in today (UTC).
    function checkedInToday(address account) external view returns (bool) {
        CheckInStats storage s = _checkIns[account];
        return s.totalCheckIns > 0 && s.lastCheckInDay == block.timestamp / 1 days;
    }

    // ------------------------------------------------------------------
    // ERC-721 read interface
    // ------------------------------------------------------------------
    function balanceOf(address owner) external view returns (uint256) {
        if (owner == address(0)) revert ZeroAddress();
        return _tokenIdOf[owner] == 0 ? 0 : 1;
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        if (owner == address(0)) revert NonexistentToken(tokenId);
        return owner;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        ownerOf(tokenId); // reverts for nonexistent tokens
        return string(abi.encodePacked(_baseTokenURI, _toString(tokenId)));
    }

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return interfaceId == 0x80ac58cd // ERC-721
            || interfaceId == 0x5b5e139f // ERC-721 metadata
            || interfaceId == 0x01ffc9a7; // ERC-165
    }

    // ------------------------------------------------------------------
    // Soulbound: every transfer / approval path reverts.
    // Badges are identity marks — they can never move between wallets.
    // ------------------------------------------------------------------
    function transferFrom(address, address, uint256) external pure {
        revert Soulbound();
    }

    function safeTransferFrom(address, address, uint256) external pure {
        revert Soulbound();
    }

    function safeTransferFrom(address, address, uint256, bytes calldata) external pure {
        revert Soulbound();
    }

    function approve(address, uint256) external pure {
        revert Soulbound();
    }

    function setApprovalForAll(address, bool) external pure {
        revert Soulbound();
    }

    function getApproved(uint256 tokenId) external view returns (address) {
        ownerOf(tokenId); // reverts for nonexistent tokens
        return address(0);
    }

    function isApprovedForAll(address, address) external pure returns (bool) {
        return false;
    }

    // ------------------------------------------------------------------
    // Internal helpers
    // ------------------------------------------------------------------
    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
