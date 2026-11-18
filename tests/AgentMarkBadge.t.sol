// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {AgentMarkBadge} from "../contracts/AgentMarkBadge.sol";
import {MockAgentID} from "../contracts/MockAgentID.sol";

contract AgentMarkBadgeTest is Test {
    MockAgentID internal agentId;
    AgentMarkBadge internal badge;

    address internal holder = address(0xA11CE);
    address internal holder2 = address(0xB0B);
    address internal stranger = address(0xDEAD);

    function setUp() public {
        agentId = new MockAgentID();
        badge = new AgentMarkBadge(address(agentId), "ipfs://agentmark/");

        // holder + holder2 own an Agent ID; stranger does not.
        agentId.mockMint(holder);
        agentId.mockMint(holder2);
    }

    // --------------------------------------------------------------
    // Mint gating
    // --------------------------------------------------------------
    function test_HolderCanMint() public {
        vm.prank(holder);
        badge.mintBadge();

        assertTrue(badge.hasBadge(holder));
        assertEq(badge.ownerOf(1), holder);
        assertEq(badge.balanceOf(holder), 1);
        assertEq(badge.totalMinted(), 1);
        assertEq(badge.tokenURI(1), "ipfs://agentmark/1");
    }

    function test_NonHolderMintReverts() public {
        vm.prank(stranger);
        vm.expectRevert(AgentMarkBadge.NotAgentIdHolder.selector);
        badge.mintBadge();
    }

    function test_SecondMintReverts() public {
        vm.prank(holder);
        badge.mintBadge();

        vm.prank(holder);
        vm.expectRevert(AgentMarkBadge.AlreadyHasBadge.selector);
        badge.mintBadge();
    }

    function test_MintEmitsBadgeMinted() public {
        vm.prank(holder);
        vm.expectEmit(true, true, false, false);
        emit AgentMarkBadge.BadgeMinted(holder, 1);
        badge.mintBadge();
    }

    // --------------------------------------------------------------
    // Soulbound
    // --------------------------------------------------------------
    function test_TransferReverts() public {
        vm.prank(holder);
        badge.mintBadge();

        vm.prank(holder);
        vm.expectRevert(AgentMarkBadge.Soulbound.selector);
        badge.transferFrom(holder, holder2, 1);
    }

    function test_SafeTransferReverts() public {
        vm.prank(holder);
        badge.mintBadge();

        vm.prank(holder);
        vm.expectRevert(AgentMarkBadge.Soulbound.selector);
        badge.safeTransferFrom(holder, holder2, 1);
    }

    function test_ApproveReverts() public {
        vm.prank(holder);
        badge.mintBadge();

        vm.prank(holder);
        vm.expectRevert(AgentMarkBadge.Soulbound.selector);
        badge.approve(holder2, 1);
    }

    // --------------------------------------------------------------
    // Check-in
    // --------------------------------------------------------------
    function test_HolderCheckInWorks() public {
        vm.prank(holder);
        badge.mintBadge();

        vm.prank(holder);
        badge.checkIn();

        (uint256 total, uint256 streak, uint256 best, uint256 lastDay) =
            badge.checkInStats(holder);
        assertEq(total, 1);
        assertEq(streak, 1);
        assertEq(best, 1);
        assertEq(lastDay, block.timestamp / 1 days);
        assertTrue(badge.checkedInToday(holder));
    }

    function test_NonHolderCheckInReverts() public {
        vm.prank(stranger);
        vm.expectRevert(AgentMarkBadge.NotAgentIdHolder.selector);
        badge.checkIn();
    }

    function test_CheckInWithoutBadgeReverts() public {
        // holder2 has an Agent ID but never minted a badge.
        vm.prank(holder2);
        vm.expectRevert(AgentMarkBadge.NoBadge.selector);
        badge.checkIn();
    }

    function test_SecondCheckInSameDayReverts() public {
        vm.startPrank(holder);
        badge.mintBadge();
        badge.checkIn();
        vm.expectRevert(AgentMarkBadge.AlreadyCheckedInToday.selector);
        badge.checkIn();
        vm.stopPrank();
    }

    function test_CheckInNextDayStreakIncrements() public {
        vm.startPrank(holder);
        badge.mintBadge();
        badge.checkIn();

        vm.warp(block.timestamp + 1 days);
        badge.checkIn();
        vm.stopPrank();

        (uint256 total, uint256 streak, uint256 best,) = badge.checkInStats(holder);
        assertEq(total, 2);
        assertEq(streak, 2);
        assertEq(best, 2);
    }

    function test_CheckInAfterGapResetsStreak() public {
        vm.startPrank(holder);
        badge.mintBadge();
        badge.checkIn();

        vm.warp(block.timestamp + 3 days); // skip two days
        badge.checkIn();
        vm.stopPrank();

        (uint256 total, uint256 streak, uint256 best,) = badge.checkInStats(holder);
        assertEq(total, 2);
        assertEq(streak, 1);
        assertEq(best, 1);
    }

    function test_CheckInEmitsEvent() public {
        vm.prank(holder);
        badge.mintBadge();

        uint256 today = block.timestamp / 1 days;
        vm.prank(holder);
        vm.expectEmit(true, true, false, true);
        emit AgentMarkBadge.CheckedIn(holder, today, 1, 1);
        badge.checkIn();
    }

    // --------------------------------------------------------------
    // Gate follows live Agent ID state
    // --------------------------------------------------------------
    function test_GateReadsLiveAgentIdBalance() public {
        // Give stranger an Agent ID -> mint now works.
        agentId.mockMint(stranger);
        vm.prank(stranger);
        badge.mintBadge();
        assertTrue(badge.hasBadge(stranger));

        // Remove holder2's Agent ID -> mint now reverts.
        agentId.mockBurn(holder2);
        vm.prank(holder2);
        vm.expectRevert(AgentMarkBadge.NotAgentIdHolder.selector);
        badge.mintBadge();
    }
}
