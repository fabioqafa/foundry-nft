// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {MoodNFT} from "../../src/MoodNFT.sol";
import {DeployMoodNFT} from "../../script/DeployMoodNFT.s.sol";

contract MoodNFTIntegrationTest is Test {
    MoodNFT moodNft;
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );
    string public constant HAPPY_SVG_TOKEN_URI =
        "data:application/json;base64,eyJuYW1lIjoiTW9vZCBORlQiLCAiZGVzY3JpcHRpb24iOiJBbiBORlQgdGhhdCByZWZsZWN0cyB0aGUgb3duZXJzIG1vb2QuIiwgImF0dHJpYnV0ZXMiOiBbeyJ0cmFpdF90eXBlIjogIm1vb2RpbmVzcyIsICJ2YWx1ZSI6IDEwMH1dLCAiaW1hZ2UiOiJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUIyYVdWM1FtOTRQU0l3SURBZ01qQXdJREl3TUNJZ2QybGtkR2c5SWpRd01DSWdhR1ZwWjJoMFBTSTBNREFpSUhodGJHNXpQU0pvZEhSd09pOHZkM2QzTG5jekxtOXlaeTh5TURBd0wzTjJaeUkrQ2lBZ0lDQThZMmx5WTJ4bElHTjRQU0l4TURBaUlHTjVQU0l4TURBaUlHWnBiR3c5SW5sbGJHeHZkeUlnY2owaU56Z2lJSE4wY205clpUMGlZbXhoWTJzaUlITjBjbTlyWlMxM2FXUjBhRDBpTXlJZ0x6NEtJQ0FnSUR4bklHTnNZWE56UFNKbGVXVnpJajRLSUNBZ0lDQWdJQ0E4WTJseVkyeGxJR040UFNJM01DSWdZM2s5SWpneUlpQnlQU0l4TWlJZ0x6NEtJQ0FnSUNBZ0lDQThZMmx5WTJ4bElHTjRQU0l4TWpjaUlHTjVQU0k0TWlJZ2NqMGlNVElpSUM4K0NpQWdJQ0E4TDJjK0NpQWdJQ0E4Y0dGMGFDQmtQU0p0TVRNMkxqZ3hJREV4Tmk0MU0yTXVOamtnTWpZdU1UY3ROalF1TVRFZ05ESXRPREV1TlRJdExqY3pJaUJ6ZEhsc1pUMGlabWxzYkRwdWIyNWxPeUJ6ZEhKdmEyVTZJR0pzWVdOck95QnpkSEp2YTJVdGQybGtkR2c2SURNN0lpQXZQZ284TDNOMlp6ND0ifQ==";

    string public constant SAD_SVG_TOKEN_URI =
        "data:application/json;base64,eyJuYW1lIjoiTW9vZCBORlQiLCAiZGVzY3JpcHRpb24iOiJBbiBORlQgdGhhdCByZWZsZWN0cyB0aGUgb3duZXJzIG1vb2QuIiwgImF0dHJpYnV0ZXMiOiBbeyJ0cmFpdF90eXBlIjogIm1vb2RpbmVzcyIsICJ2YWx1ZSI6IDEwMH1dLCAiaW1hZ2UiOiJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBEOTRiV3dnZG1WeWMybHZiajBpTVM0d0lpQnpkR0Z1WkdGc2IyNWxQU0p1YnlJL1BnbzhjM1puSUhkcFpIUm9QU0l4TURJMGNIZ2lJR2hsYVdkb2REMGlNVEF5TkhCNElpQjJhV1YzUW05NFBTSXdJREFnTVRBeU5DQXhNREkwSWlCNGJXeHVjejBpYUhSMGNEb3ZMM2QzZHk1M015NXZjbWN2TWpBd01DOXpkbWNpUGdvZ0lDQWdQSEJoZEdnZ1ptbHNiRDBpSXpNek15SUtJQ0FnSUNBZ0lDQmtQU0pOTlRFeUlEWTBRekkyTkM0MklEWTBJRFkwSURJMk5DNDJJRFkwSURVeE1uTXlNREF1TmlBME5EZ2dORFE0SURRME9DQTBORGd0TWpBd0xqWWdORFE0TFRRME9GTTNOVGt1TkNBMk5DQTFNVElnTmpSNmJUQWdPREl3WXkweU1EVXVOQ0F3TFRNM01pMHhOall1Tmkwek56SXRNemN5Y3pFMk5pNDJMVE0zTWlBek56SXRNemN5SURNM01pQXhOall1TmlBek56SWdNemN5TFRFMk5pNDJJRE0zTWkwek56SWdNemN5ZWlJZ0x6NEtJQ0FnSUR4d1lYUm9JR1pwYkd3OUlpTkZOa1UyUlRZaUNpQWdJQ0FnSUNBZ1pEMGlUVFV4TWlBeE5EQmpMVEl3TlM0MElEQXRNemN5SURFMk5pNDJMVE0zTWlBek56SnpNVFkyTGpZZ016Y3lJRE0zTWlBek56SWdNemN5TFRFMk5pNDJJRE0zTWkwek56SXRNVFkyTGpZdE16Y3lMVE0zTWkwek56SjZUVEk0T0NBME1qRmhORGd1TURFZ05EZ3VNREVnTUNBd0lERWdPVFlnTUNBME9DNHdNU0EwT0M0d01TQXdJREFnTVMwNU5pQXdlbTB6TnpZZ01qY3lhQzAwT0M0eFl5MDBMaklnTUMwM0xqZ3RNeTR5TFRndU1TMDNMalJETmpBMElEWXpOaTR4SURVMk1pNDFJRFU1TnlBMU1USWdOVGszY3kwNU1pNHhJRE01TGpFdE9UVXVPQ0E0T0M0Mll5MHVNeUEwTGpJdE15NDVJRGN1TkMwNExqRWdOeTQwU0RNMk1HRTRJRGdnTUNBd0lERXRPQzA0TGpSak5DNDBMVGcwTGpNZ056UXVOUzB4TlRFdU5pQXhOakF0TVRVeExqWnpNVFUxTGpZZ05qY3VNeUF4TmpBZ01UVXhMalpoT0NBNElEQWdNQ0F4TFRnZ09DNDBlbTB5TkMweU1qUmhORGd1TURFZ05EZ3VNREVnTUNBd0lERWdNQzA1TmlBME9DNHdNU0EwT0M0d01TQXdJREFnTVNBd0lEazJlaUlnTHo0S0lDQWdJRHh3WVhSb0lHWnBiR3c5SWlNek16TWlDaUFnSUNBZ0lDQWdaRDBpVFRJNE9DQTBNakZoTkRnZ05EZ2dNQ0F4SURBZ09UWWdNQ0EwT0NBME9DQXdJREVnTUMwNU5pQXdlbTB5TWpRZ01URXlZeTA0TlM0MUlEQXRNVFUxTGpZZ05qY3VNeTB4TmpBZ01UVXhMalpoT0NBNElEQWdNQ0F3SURnZ09DNDBhRFE0TGpGak5DNHlJREFnTnk0NExUTXVNaUE0TGpFdE55NDBJRE11TnkwME9TNDFJRFExTGpNdE9EZ3VOaUE1TlM0NExUZzRMalp6T1RJZ016a3VNU0E1TlM0NElEZzRMalpqTGpNZ05DNHlJRE11T1NBM0xqUWdPQzR4SURjdU5FZzJOalJoT0NBNElEQWdNQ0F3SURndE9DNDBRelkyTnk0MklEWXdNQzR6SURVNU55NDFJRFV6TXlBMU1USWdOVE16ZW0weE1qZ3RNVEV5WVRRNElEUTRJREFnTVNBd0lEazJJREFnTkRnZ05EZ2dNQ0F4SURBdE9UWWdNSG9pSUM4K0Nqd3ZjM1puUGc9PSJ9";
    DeployMoodNFT deployer;
    address USER = makeAddr("USER");

    function setUp() public {
        deployer = new DeployMoodNFT();
        moodNft = deployer.run();
    }

    function testName() public view {
        bytes32 expectedName = keccak256(abi.encodePacked("Mood NFT"));
        bytes32 actualName = keccak256(abi.encodePacked(moodNft.name()));

        assert(expectedName == actualName);
    }

    function testSymbol() public view {
        bytes32 expectedSymbol = keccak256(abi.encodePacked("MN"));
        bytes32 actualSymbol = keccak256(abi.encodePacked(moodNft.symbol()));

        assert(expectedSymbol == actualSymbol);
    }

    function testMint() public {
        vm.prank(USER);

        moodNft.mintNFT();

        assert(moodNft.balanceOf(USER) == 1);
    }

    function testSafeTransferFrom() public {
        vm.prank(msg.sender);
        moodNft.mintNFT();

        vm.prank(msg.sender);
        moodNft.safeTransferFrom(msg.sender, USER, 0);

        assertEq(moodNft.ownerOf(0), USER);
    }

    function testFailSafeTransferFromNotOwner() public {
        address owner = msg.sender;
        vm.prank(owner);
        moodNft.mintNFT();
        vm.prank(USER);
        moodNft.safeTransferFrom(owner, USER, 0);
    }

    function testSafeTransferFromRevert() public {
        vm.prank(msg.sender);
        vm.expectRevert();
        moodNft.safeTransferFrom(msg.sender, USER, 0);
    }

    function testApprove() public {
        vm.prank(msg.sender);
        moodNft.mintNFT();

        vm.prank(msg.sender);
        moodNft.approve(USER, 0);
        assertEq(moodNft.getApproved(0), USER);
    }

    function testApproveRevert() public {
        vm.prank(msg.sender);
        moodNft.mintNFT();

        vm.prank(USER);
        vm.expectRevert();
        moodNft.approve(USER, 0);
    }

    function testSetApprovalForAll() public {
        vm.prank(msg.sender);
        moodNft.setApprovalForAll(USER, true);

        assertTrue(moodNft.isApprovedForAll(msg.sender, USER));

        vm.prank(msg.sender);
        moodNft.setApprovalForAll(USER, false);

        assertFalse(moodNft.isApprovedForAll(msg.sender, USER));
    }

    function testBalanceOf() public {
        vm.prank(msg.sender);
        moodNft.mintNFT();
        vm.prank(msg.sender);
        moodNft.mintNFT();
        assertEq(moodNft.balanceOf(msg.sender), 2);
    }

    function testEmitTransferEvent() public {
        vm.prank(msg.sender);
        moodNft.mintNFT();
        vm.expectEmit(true, true, true, true);
        emit Transfer(msg.sender, USER, 0);

        vm.prank(msg.sender);
        moodNft.transferFrom(msg.sender, USER, 0);
    }

    function testEmitApprovalEvent() public {
        vm.prank(msg.sender);
        moodNft.mintNFT();
        vm.expectEmit(true, true, true, true);
        emit Approval(msg.sender, USER, 0);

        vm.prank(msg.sender);
        moodNft.approve(USER, 0);
    }

    function testEmitApprovalForAllEvent() public {
        vm.expectEmit(true, true, true, true);
        emit ApprovalForAll(msg.sender, USER, true);
        vm.prank(msg.sender);
        moodNft.setApprovalForAll(USER, true);
    }

    function testTokenURI() public {
        vm.prank(USER);
        moodNft.mintNFT();
        assertEq(moodNft.tokenURI(0), HAPPY_SVG_TOKEN_URI);
    }

    function testFlip() public {
        vm.prank(USER);
        moodNft.mintNFT();
        vm.prank(USER);
        moodNft.flipMood(0);

        assertEq(moodNft.tokenURI(0), SAD_SVG_TOKEN_URI);
    }
}
