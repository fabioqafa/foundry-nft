// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {MoodNFT} from "../src/MoodNFT.sol";

contract MintMoodNFT is Script {
    string constant SHIBA_INU_URI =
        "https://ipfs.io/ipfs/QmWosvaceNLgWVT1pTU9q6VjUATDLDWrfxk2egQff9VHQx";

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "MoodNFT",
            block.chainid
        );
        mintMoodNftOnContract(mostRecentlyDeployed);
        flipMoodNftOnContracts(mostRecentlyDeployed, 0);
    }

    function mintMoodNftOnContract(address contractAddress) public {
        vm.startBroadcast();
        MoodNFT(contractAddress).mintNFT();
        vm.stopBroadcast();
    }

    function flipMoodNftOnContracts(
        address contractAddress,
        uint256 tokenId
    ) public {
        vm.startBroadcast();
        MoodNFT(contractAddress).flipMood(tokenId);
        vm.stopBroadcast();
    }
}
