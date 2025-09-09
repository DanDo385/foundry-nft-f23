// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {DeployBasicNft} from "../script/DeployBasicNft.s.sol";
import {BasicNft} from "../src/BasicNft.sol";
import {Test, console2} from "forge-std/Test.sol";
import {MintBasicNft} from "../script/Interactions.s.sol";
contract BasicNftTest is Test {
    string constant NFT_NAME = "Dogie";
    string constant NFT_SYMBOL = "DOG";
    BasicNft public basicNft;
    DeployBasicNft public deployer;
    address public deployerAddress;

    string public constant PUG_URI =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";
    address public constant USER = address(1);

    function setUp() public {
        deployer = new DeployBasicNft();
        basicNft = deployer.run();
    }

    function testInitializedCorrectly() public view {
        assert(keccak256(abi.encodePacked(basicNft.name())) == keccak256(abi.encodePacked((NFT_NAME))));
        assert(keccak256(abi.encodePacked(basicNft.symbol())) == keccak256(abi.encodePacked((NFT_SYMBOL))));
    }

    function testCanMintAndHaveABalance() public {
        vm.prank(USER);
        basicNft.mintNft(PUG_URI);

        assert(basicNft.balanceOf(USER) == 1);
    }

    function testTokenURIIsCorrect() public {
        vm.prank(USER);
        basicNft.mintNft(PUG_URI);

        assert(keccak256(abi.encodePacked(basicNft.tokenURI(0))) == keccak256(abi.encodePacked(PUG_URI)));
    }

    function testMintWithScript() public {
        uint256 startingTokenCount = basicNft.getTokenCounter();
        MintBasicNft mintBasicNft = new MintBasicNft();
        mintBasicNft.mintNftOnContract(address(basicNft));
        assert(basicNft.getTokenCounter() == startingTokenCount + 1);
    }

    function testTokenCounterIncrements() public {
        uint256 initialCounter = basicNft.getTokenCounter();
        
        vm.prank(USER);
        basicNft.mintNft(PUG_URI);
        assert(basicNft.getTokenCounter() == initialCounter + 1);
        
        vm.prank(USER);
        basicNft.mintNft("ipfs://another-uri");
        assert(basicNft.getTokenCounter() == initialCounter + 2);
    }

    function testTokenURINotFound() public {
        // Try to get URI for non-existent token
        vm.expectRevert(abi.encodeWithSignature("ERC721NonexistentToken(uint256)", 999));
        basicNft.tokenURI(999);
    }

    function testMultipleMints() public {
        address user2 = address(2);
        string memory uri2 = "ipfs://another-pug-uri";
        
        vm.prank(USER);
        basicNft.mintNft(PUG_URI);
        
        vm.prank(user2);
        basicNft.mintNft(uri2);
        
        assert(basicNft.balanceOf(USER) == 1);
        assert(basicNft.balanceOf(user2) == 1);
        assert(basicNft.ownerOf(0) == USER);
        assert(basicNft.ownerOf(1) == user2);
        
        assert(keccak256(abi.encodePacked(basicNft.tokenURI(0))) == keccak256(abi.encodePacked(PUG_URI)));
        assert(keccak256(abi.encodePacked(basicNft.tokenURI(1))) == keccak256(abi.encodePacked(uri2)));
    }

    function testEmptyTokenURI() public {
        vm.prank(USER);
        basicNft.mintNft(""); // Empty URI
        
        assert(basicNft.balanceOf(USER) == 1);
        assert(keccak256(abi.encodePacked(basicNft.tokenURI(0))) == keccak256(abi.encodePacked("")));
    }

    function testLongTokenURI() public {
        string memory longURI = "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=very-long-filename-that-might-cause-issues.json";
        
        vm.prank(USER);
        basicNft.mintNft(longURI);
        
        assert(keccak256(abi.encodePacked(basicNft.tokenURI(0))) == keccak256(abi.encodePacked(longURI)));
    }
}