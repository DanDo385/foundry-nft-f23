// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MoodNft} from "../src/MoodNft.sol";
import {console} from "forge-std/console.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract DeployMoodNft is Script {
    uint256 public DEFAULT_ANVIL_PRIVATE_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    uint256 public deployerKey;

    function run() external returns (MoodNft) {
        vm.startBroadcast();
        // Create default SVG URIs for happy and sad moods
        string memory sadSvgUri = svgToImageURI(getSadSvg());
        string memory happySvgUri = svgToImageURI(getHappySvg());
        MoodNft moodNft = new MoodNft(sadSvgUri, happySvgUri);
        vm.stopBroadcast();
        return moodNft;
    }

    function svgToImageURI(string memory svg) public pure returns (string memory) {
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(
            bytes(string(abi.encodePacked(svg)))
        );
        return string(abi.encodePacked(baseURL, svgBase64Encoded));
    }

    function getSadSvg() public pure returns (string memory) {
        return string(
            abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100" viewBox="0 0 100 100">',
                '<circle cx="50" cy="50" r="40" fill="yellow" stroke="black" stroke-width="2"/>',
                '<circle cx="35" cy="40" r="5" fill="black"/>',
                '<circle cx="65" cy="40" r="5" fill="black"/>',
                '<path d="M 30 65 Q 50 80 70 65" stroke="black" stroke-width="3" fill="none"/>',
                '</svg>'
            )
        );
    }

    function getHappySvg() public pure returns (string memory) {
        return string(
            abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100" viewBox="0 0 100 100">',
                '<circle cx="50" cy="50" r="40" fill="yellow" stroke="black" stroke-width="2"/>',
                '<circle cx="35" cy="40" r="5" fill="black"/>',
                '<circle cx="65" cy="40" r="5" fill="black"/>',
                '<path d="M 30 60 Q 50 45 70 60" stroke="black" stroke-width="3" fill="none"/>',
                '</svg>'
            )
        );
    }
}
