// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {DeployBasicNFT} from "../../script/DeployBasicNFT.s.sol";
import {BasicNFT} from "../../src/BasicNFT.sol";

contract BasicNFTTest is Test {
    DeployBasicNFT public deployer;
    BasicNFT public basicNft;

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
}
