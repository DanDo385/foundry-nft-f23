// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DeployBasicNft} from "../script/DeployBasicNft.s.sol";
import {DeployMoodNft} from "../script/DeployMoodNft.s.sol";
import {MintBasicNft} from "../script/Interactions.s.sol";
import {BasicNft} from "../src/BasicNft.sol";
import {MoodNft} from "../src/MoodNft.sol";

contract ScriptTest is Test {
    DeployBasicNft public deployBasicNft;
    DeployMoodNft public deployMoodNft;
    MintBasicNft public mintBasicNft;
    BasicNft public basicNft;
    MoodNft public moodNft;

    function setUp() public {
        deployBasicNft = new DeployBasicNft();
        deployMoodNft = new DeployMoodNft();
        mintBasicNft = new MintBasicNft();
    }

    function testDeployBasicNft() public {
        basicNft = deployBasicNft.run();
        
        assert(address(basicNft) != address(0));
        assert(keccak256(abi.encodePacked(basicNft.name())) == keccak256(abi.encodePacked("Dogie")));
        assert(keccak256(abi.encodePacked(basicNft.symbol())) == keccak256(abi.encodePacked("DOG")));
        assert(basicNft.getTokenCounter() == 0);
    }

    function testDeployMoodNft() public {
        moodNft = deployMoodNft.run();
        
        assert(address(moodNft) != address(0));
        assert(keccak256(abi.encodePacked(moodNft.name())) == keccak256(abi.encodePacked("Mood NFT")));
        assert(keccak256(abi.encodePacked(moodNft.symbol())) == keccak256(abi.encodePacked("MN")));
        assert(moodNft.getTokenCounter() == 0);
        
        // Test that SVG functions work
        string memory happySvg = moodNft.getHappySVG();
        string memory sadSvg = moodNft.getSadSVG();
        assert(bytes(happySvg).length > 0);
        assert(bytes(sadSvg).length > 0);
    }

    function testDeployMoodNftSvgGeneration() public {
        // Test the SVG generation functions
        string memory sadSvg = deployMoodNft.getSadSvg();
        string memory happySvg = deployMoodNft.getHappySvg();
        
        assert(bytes(sadSvg).length > 0);
        assert(bytes(happySvg).length > 0);
        assert(contains(sadSvg, "<svg"));
        assert(contains(happySvg, "<svg"));
        assert(contains(sadSvg, "</svg>"));
        assert(contains(happySvg, "</svg>"));
    }

    function testSvgToImageURI() public {
        string memory testSvg = "<svg><circle cx='50' cy='50' r='40'/></svg>";
        string memory imageURI = deployMoodNft.svgToImageURI(testSvg);
        
        assert(bytes(imageURI).length > 0);
        assert(contains(imageURI, "data:image/svg+xml;base64,"));
    }

    function testMintBasicNftRun() public {
        // Deploy a BasicNft first
        basicNft = deployBasicNft.run();
        uint256 initialCounter = basicNft.getTokenCounter();
        
        // The run function should have minted an NFT
        // Note: We can't test the actual run() function easily due to broadcast/prank conflicts
        // Instead, we test the mintNftOnContract function directly
        mintBasicNft.mintNftOnContract(address(basicNft));
        assert(basicNft.getTokenCounter() == initialCounter + 1);
    }

    function testMintBasicNftOnContract() public {
        // Deploy a BasicNft first
        basicNft = deployBasicNft.run();
        uint256 initialCounter = basicNft.getTokenCounter();
        
        // Mint using the contract address
        mintBasicNft.mintNftOnContract(address(basicNft));
        
        assert(basicNft.getTokenCounter() == initialCounter + 1);
    }

    function testMintBasicNftOnContractWithSpecificAddress() public {
        // Deploy a BasicNft first
        basicNft = deployBasicNft.run();
        uint256 initialCounter = basicNft.getTokenCounter();
        
        // Test with a specific contract address
        address contractAddress = address(basicNft);
        mintBasicNft.mintNftOnContract(contractAddress);
        
        assert(basicNft.getTokenCounter() == initialCounter + 1);
    }

    function testScriptConstants() public {
        // Test that the script constants are set correctly
        assert(deployBasicNft.DEFAULT_ANVIL_PRIVATE_KEY() == 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);
        assert(deployMoodNft.DEFAULT_ANVIL_PRIVATE_KEY() == 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);
        assert(mintBasicNft.DEFAULT_ANVIL_PRIVATE_KEY() == 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);
    }

    function testMoodNftConstructorParameters() public {
        // Test that the MoodNft is constructed with proper SVG URIs
        moodNft = deployMoodNft.run();
        
        string memory happySvg = moodNft.getHappySVG();
        string memory sadSvg = moodNft.getSadSVG();
        
        // Both should be valid data URIs
        assert(contains(happySvg, "data:image/svg+xml;base64,"));
        assert(contains(sadSvg, "data:image/svg+xml;base64,"));
        
        // They should be different
        assert(keccak256(abi.encodePacked(happySvg)) != keccak256(abi.encodePacked(sadSvg)));
    }

    function contains(string memory str, string memory substr) internal pure returns (bool) {
        bytes memory strBytes = bytes(str);
        bytes memory substrBytes = bytes(substr);
        
        if (substrBytes.length > strBytes.length) {
            return false;
        }
        
        for (uint i = 0; i <= strBytes.length - substrBytes.length; i++) {
            bool found = true;
            for (uint j = 0; j < substrBytes.length; j++) {
                if (strBytes[i + j] != substrBytes[j]) {
                    found = false;
                    break;
                }
            }
            if (found) {
                return true;
            }
        }
        return false;
    }
}
