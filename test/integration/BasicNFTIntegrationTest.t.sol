// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DeployBasicNFT} from "../../script/DeployBasicNFT.s.sol";
import {BasicNFT} from "../../src/BasicNFT.sol";

contract BasicNFTTest is Test {
    DeployBasicNFT public deployer;
    BasicNFT public basicNft;

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

    address public USER = makeAddr("user");
    string public constant SHIBA_INU_URI =
        "ipfs/QmbxNVpYPLi2gB11r5BS6ptt8Pxu5jZ5yCb5C7GQuHbdfh";

    function setUp() public {
        deployer = new DeployBasicNFT();
        basicNft = deployer.run();
    }

    function testName() public view {
        bytes32 expectedName = keccak256(abi.encodePacked("Dogie"));
        bytes32 actualName = keccak256(abi.encodePacked(basicNft.name()));

        assert(expectedName == actualName);
    }

    function testSymbol() public view {
        bytes32 expectedSymbol = keccak256(abi.encodePacked("DOG"));
        bytes32 actualSymbol = keccak256(abi.encodePacked(basicNft.symbol()));

        assert(expectedSymbol == actualSymbol);
    }

    function testMint() public {
        vm.prank(USER);

        basicNft.mintNft(SHIBA_INU_URI);

        assert(basicNft.balanceOf(USER) == 1);
        assert(
            keccak256(abi.encodePacked(SHIBA_INU_URI)) ==
                keccak256(abi.encodePacked(basicNft.tokenURI(0)))
        );
    }

    function testSafeTransferFrom() public {
        vm.prank(msg.sender);
        basicNft.mintNft(SHIBA_INU_URI);

        vm.prank(msg.sender);
        basicNft.safeTransferFrom(msg.sender, USER, 0);

        assertEq(basicNft.ownerOf(0), USER);
    }

    function testFailSafeTransferFromNotOwner() public {
        address owner = msg.sender;
        vm.prank(owner);
        basicNft.mintNft(SHIBA_INU_URI);
        vm.prank(USER);
        basicNft.safeTransferFrom(owner, USER, 0);
    }

    function testSafeTransferFromRevert() public {
        vm.prank(msg.sender);
        vm.expectRevert();
        basicNft.safeTransferFrom(msg.sender, USER, 0);
    }

    function testApprove() public {
        vm.prank(msg.sender);
        basicNft.mintNft(SHIBA_INU_URI);

        vm.prank(msg.sender);
        basicNft.approve(USER, 0);
        assertEq(basicNft.getApproved(0), USER);
    }

    function testApproveRevert() public {
        vm.prank(msg.sender);
        basicNft.mintNft(SHIBA_INU_URI);

        vm.prank(USER);
        vm.expectRevert();
        basicNft.approve(USER, 0);
    }

    function testSetApprovalForAll() public {
        vm.prank(msg.sender);
        basicNft.setApprovalForAll(USER, true);

        assertTrue(basicNft.isApprovedForAll(msg.sender, USER));

        vm.prank(msg.sender);
        basicNft.setApprovalForAll(USER, false);

        assertFalse(basicNft.isApprovedForAll(msg.sender, USER));
    }

    function testBalanceOf() public {
        vm.prank(msg.sender);
        basicNft.mintNft(SHIBA_INU_URI);
        vm.prank(msg.sender);
        basicNft.mintNft(SHIBA_INU_URI);
        assertEq(basicNft.balanceOf(msg.sender), 2);
    }

    function testEmitTransferEvent() public {
        vm.prank(msg.sender);
        basicNft.mintNft(SHIBA_INU_URI);
        vm.expectEmit(true, true, true, true);
        emit Transfer(msg.sender, USER, 0);

        vm.prank(msg.sender);
        basicNft.transferFrom(msg.sender, USER, 0);
    }

    function testEmitApprovalEvent() public {
        vm.prank(msg.sender);
        basicNft.mintNft(SHIBA_INU_URI);
        vm.expectEmit(true, true, true, true);
        emit Approval(msg.sender, USER, 0);

        vm.prank(msg.sender);
        basicNft.approve(USER, 0);
    }

    function testEmitApprovalForAllEvent() public {
        vm.expectEmit(true, true, true, true);
        emit ApprovalForAll(msg.sender, USER, true);
        vm.prank(msg.sender);
        basicNft.setApprovalForAll(USER, true);
    }
}
