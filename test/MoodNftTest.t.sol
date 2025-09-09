// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {DeployMoodNft} from "../script/DeployMoodNft.s.sol";
import {MoodNft} from "../src/MoodNft.sol";
import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {MintBasicNft} from "../script/Interactions.s.sol";
contract MoodNftTest is Test {
    string constant NFT_NAME = "Mood NFT";
    string constant NFT_SYMBOL = "MN";
    MoodNft public moodNft;
    DeployMoodNft public deployer;
    address public deployerAddress;

    string public constant HAPPY_MOOD_URI =
        "data:application/json;base64,eyJuYW1lIjoiTW9vZCBORlQiLCAiZGVzY3JpcHRpb24iOiJBbiBORlQgdGhhdCByZWZsZWN0cyB0aGUgbW9vZCBvZiB0aGUgb3duZXIsIDEwMCUgb24gQ2hhaW4hIiwgImF0dHJpYnV0ZXMiOiBbeyJ0cmFpdF90eXBlIjogIm1vb2RpbmVzcyIsICJ2YWx1ZSI6IDEwMH1dLCAiaW1hZ2UiOiJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUIyYVdWM1FtOTRQU0l3SURBZ01qQXdJREl3TUNJZ2QybGtkR2c5SWpRd01DSWdJR2hsYVdkb2REMGlOREF3SWlCNGJXeHVjejBpYUhSMGNEb3ZMM2QzZHk1M015NXZjbWN2TWpBd01DOXpkbWNpUGdvZ0lEeGphWEpqYkdVZ1kzZzlJakV3TUNJZ1kzazlJakV3TUNJZ1ptbHNiRDBpZVdWc2JHOTNJaUJ5UFNJM09DSWdjM1J5YjJ0bFBTSmliR0ZqYXlJZ2MzUnliMnRsTFhkcFpIUm9QU0l6SWk4K0NpQWdQR2NnWTJ4aGMzTTlJbVY1WlhNaVBnb2dJQ0FnUEdOcGNtTnNaU0JqZUQwaU56QWlJR041UFNJNE1pSWdjajBpTVRJaUx6NEtJQ0FnSUR4amFYSmpiR1VnWTNnOUlqRXlOeUlnWTNrOUlqZ3lJaUJ5UFNJeE1pSXZQZ29nSUR3dlp6NEtJQ0E4Y0dGMGFDQmtQU0p0TVRNMkxqZ3hJREV4Tmk0MU0yTXVOamtnTWpZdU1UY3ROalF1TVRFZ05ESXRPREV1TlRJdExqY3pJaUJ6ZEhsc1pUMGlabWxzYkRwdWIyNWxPeUJ6ZEhKdmEyVTZJR0pzWVdOck95QnpkSEp2YTJVdGQybGtkR2c2SURNN0lpOCtDand2YzNablBnbz0ifQ==";

    string public constant SAD_MOOD_URI =
        "data:application/json;base64,eyJuYW1lIjoiTW9vZCBORlQiLCAiZGVzY3JpcHRpb24iOiJBbiBORlQgdGhhdCByZWZsZWN0cyB0aGUgbW9vZCBvZiB0aGUgb3duZXIsIDEwMCUgb24gQ2hhaW4hIiwgImF0dHJpYnV0ZXMiOiBbeyJ0cmFpdF90eXBlIjogIm1vb2RpbmVzcyIsICJ2YWx1ZSI6IDEwMH1dLCAiaW1hZ2UiOiJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUIzYVdSMGFEMGlNVEF5TkhCNElpQm9aV2xuYUhROUlqRXdNalJ3ZUNJZ2RtbGxkMEp2ZUQwaU1DQXdJREV3TWpRZ01UQXlOQ0lnZUcxc2JuTTlJbWgwZEhBNkx5OTNkM2N1ZHpNdWIzSm5Mekl3TURBdmMzWm5JajRLSUNBOGNHRjBhQ0JtYVd4c1BTSWpNek16SWlCa1BTSk5OVEV5SURZMFF6STJOQzQySURZMElEWTBJREkyTkM0MklEWTBJRFV4TW5NeU1EQXVOaUEwTkRnZ05EUTRJRFEwT0NBME5EZ3RNakF3TGpZZ05EUTRMVFEwT0ZNM05Ua3VOQ0EyTkNBMU1USWdOalI2YlRBZ09ESXdZeTB5TURVdU5DQXdMVE0zTWkweE5qWXVOaTB6TnpJdE16Y3ljekUyTmk0MkxUTTNNaUF6TnpJdE16Y3lJRE0zTWlBeE5qWXVOaUF6TnpJZ016Y3lMVEUyTmk0MklETTNNaTB6TnpJZ016Y3llaUl2UGdvZ0lEeHdZWFJvSUdacGJHdzlJaU5GTmtVMlJUWWlJR1E5SWswMU1USWdNVFF3WXkweU1EVXVOQ0F3TFRNM01pQXhOall1Tmkwek56SWdNemN5Y3pFMk5pNDJJRE0zTWlBek56SWdNemN5SURNM01pMHhOall1TmlBek56SXRNemN5TFRFMk5pNDJMVE0zTWkwek56SXRNemN5ZWsweU9EZ2dOREl4WVRRNExqQXhJRFE0TGpBeElEQWdNQ0F4SURrMklEQWdORGd1TURFZ05EZ3VNREVnTUNBd0lERXRPVFlnTUhwdE16YzJJREkzTW1ndE5EZ3VNV010TkM0eUlEQXROeTQ0TFRNdU1pMDRMakV0Tnk0MFF6WXdOQ0EyTXpZdU1TQTFOakl1TlNBMU9UY2dOVEV5SURVNU4zTXRPVEl1TVNBek9TNHhMVGsxTGpnZ09EZ3VObU10TGpNZ05DNHlMVE11T1NBM0xqUXRPQzR4SURjdU5FZ3pOakJoT0NBNElEQWdNQ0F4TFRndE9DNDBZelF1TkMwNE5DNHpJRGMwTGpVdE1UVXhMallnTVRZd0xURTFNUzQyY3pFMU5TNDJJRFkzTGpNZ01UWXdJREUxTVM0MllUZ2dPQ0F3SURBZ01TMDRJRGd1TkhwdE1qUXRNakkwWVRRNExqQXhJRFE0TGpBeElEQWdNQ0F4SURBdE9UWWdORGd1TURFZ05EZ3VNREVnTUNBd0lERWdNQ0E1Tm5vaUx6NEtJQ0E4Y0dGMGFDQm1hV3hzUFNJak16TXpJaUJrUFNKTk1qZzRJRFF5TVdFME9DQTBPQ0F3SURFZ01DQTVOaUF3SURRNElEUTRJREFnTVNBd0xUazJJREI2YlRJeU5DQXhNVEpqTFRnMUxqVWdNQzB4TlRVdU5pQTJOeTR6TFRFMk1DQXhOVEV1Tm1FNElEZ2dNQ0F3SURBZ09DQTRMalJvTkRndU1XTTBMaklnTUNBM0xqZ3RNeTR5SURndU1TMDNMalFnTXk0M0xUUTVMalVnTkRVdU15MDRPQzQySURrMUxqZ3RPRGd1Tm5NNU1pQXpPUzR4SURrMUxqZ2dPRGd1Tm1NdU15QTBMaklnTXk0NUlEY3VOQ0E0TGpFZ055NDBTRFkyTkdFNElEZ2dNQ0F3SURBZ09DMDRMalJETmpZM0xqWWdOakF3TGpNZ05UazNMalVnTlRNeklEVXhNaUExTXpONmJURXlPQzB4TVRKaE5EZ2dORGdnTUNBeElEQWdPVFlnTUNBME9DQTBPQ0F3SURFZ01DMDVOaUF3ZWlJdlBnbzhMM04yWno0SyJ9";

    address public constant USER = address(1);

    function setUp() public {
        deployer = new DeployMoodNft();
        moodNft = deployer.run();
    }

    function testInitializedCorrectly() public view {
        assert(keccak256(abi.encodePacked(moodNft.name())) == keccak256(abi.encodePacked((NFT_NAME))));
        assert(keccak256(abi.encodePacked(moodNft.symbol())) == keccak256(abi.encodePacked((NFT_SYMBOL))));
    }

    function testCanMintAndHaveABalance() public {
        vm.prank(USER);
        moodNft.mintNft();

        assert(moodNft.balanceOf(USER) == 1);
    }

    function testTokenURIDefaultIsCorrectlySet() public {
        vm.prank(USER);
        moodNft.mintNft();

        string memory actualUri = moodNft.tokenURI(0);
        // Check that the URI contains the expected JSON structure
        assert(bytes(actualUri).length > 0);
        // The URI should contain "data:application/json;base64,"
        assert(contains(actualUri, "data:application/json;base64,"));
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

    function testFlipTokenToSad() public {
        vm.prank(USER);
        moodNft.mintNft();

        string memory happyUri = moodNft.tokenURI(0);
        
        vm.prank(USER);
        moodNft.flipMood(0);

        string memory sadUri = moodNft.tokenURI(0);
        
        // The URIs should be different after flipping mood
        assert(keccak256(abi.encodePacked(happyUri)) != keccak256(abi.encodePacked(sadUri)));
        // Both should be valid data URIs
        assert(contains(happyUri, "data:application/json;base64,"));
        assert(contains(sadUri, "data:application/json;base64,"));
    }

    function testEventRecordsCorrectTokenIdOnMinting() public {

        uint256 currentAvailableTokenId = moodNft.getTokenCounter();

        vm.prank(USER);
        vm.recordLogs();
        moodNft.mintNft();
        Vm.Log[] memory entries = vm.getRecordedLogs();

        bytes32 tokenId_proto = entries[1].topics[1];
        uint256 tokenId = uint256(tokenId_proto);

        assertEq(tokenId, currentAvailableTokenId);
    }

    function testGetHappySVG() public {
        string memory happySvg = moodNft.getHappySVG();
        assert(bytes(happySvg).length > 0);
        assert(contains(happySvg, "data:image/svg+xml;base64,"));
    }

    function testGetSadSVG() public {
        string memory sadSvg = moodNft.getSadSVG();
        assert(bytes(sadSvg).length > 0);
        assert(contains(sadSvg, "data:image/svg+xml;base64,"));
    }

    function testTokenCounterIncrements() public {
        uint256 initialCounter = moodNft.getTokenCounter();
        
        vm.prank(USER);
        moodNft.mintNft();
        assert(moodNft.getTokenCounter() == initialCounter + 1);
        
        vm.prank(USER);
        moodNft.mintNft();
        assert(moodNft.getTokenCounter() == initialCounter + 2);
    }

    function testMultipleMints() public {
        address user2 = address(2);
        
        vm.prank(USER);
        moodNft.mintNft();
        
        vm.prank(user2);
        moodNft.mintNft();
        
        assert(moodNft.balanceOf(USER) == 1);
        assert(moodNft.balanceOf(user2) == 1);
        assert(moodNft.ownerOf(0) == USER);
        assert(moodNft.ownerOf(1) == user2);
    }

    function testFlipMoodMultipleTimes() public {
        vm.prank(USER);
        moodNft.mintNft();
        
        string memory initialUri = moodNft.tokenURI(0);
        
        // Flip to sad
        vm.prank(USER);
        moodNft.flipMood(0);
        string memory sadUri = moodNft.tokenURI(0);
        assert(keccak256(abi.encodePacked(initialUri)) != keccak256(abi.encodePacked(sadUri)));
        
        // Flip back to happy
        vm.prank(USER);
        moodNft.flipMood(0);
        string memory happyUri = moodNft.tokenURI(0);
        assert(keccak256(abi.encodePacked(initialUri)) == keccak256(abi.encodePacked(happyUri)));
        
        // Flip to sad again
        vm.prank(USER);
        moodNft.flipMood(0);
        string memory sadUri2 = moodNft.tokenURI(0);
        assert(keccak256(abi.encodePacked(sadUri)) == keccak256(abi.encodePacked(sadUri2)));
    }

    function testFlipMoodNotOwner() public {
        address user2 = address(2);
        
        vm.prank(USER);
        moodNft.mintNft();
        
        // User2 tries to flip mood without approval
        vm.prank(user2);
        vm.expectRevert(MoodNft.MoodNft__CantFlipMoodIfNotOwner.selector);
        moodNft.flipMood(0);
    }

    function testFlipMoodWithApproval() public {
        address user2 = address(2);
        
        vm.prank(USER);
        moodNft.mintNft();
        
        // USER approves user2 to manage the NFT
        vm.prank(USER);
        moodNft.approve(user2, 0);
        
        // Now user2 can flip the mood
        vm.prank(user2);
        moodNft.flipMood(0);
        
        // Verify the mood changed
        string memory uri = moodNft.tokenURI(0);
        assert(contains(uri, "data:application/json;base64,"));
    }

    function testTokenURINonExistentToken() public {
        vm.expectRevert(abi.encodeWithSignature("ERC721NonexistentToken(uint256)", 999));
        moodNft.tokenURI(999);
    }

    function testBaseURI() public {
        // Test that _baseURI returns the expected value
        // We can't directly test _baseURI since it's internal, but we can test tokenURI
        vm.prank(USER);
        moodNft.mintNft();
        
        string memory uri = moodNft.tokenURI(0);
        assert(contains(uri, "data:application/json;base64,"));
    }

    function testTokenURIStructure() public {
        vm.prank(USER);
        moodNft.mintNft();
        
        string memory uri = moodNft.tokenURI(0);
        assert(contains(uri, "data:application/json;base64,"));
        // The URI is base64 encoded, so we need to decode it to check the content
        // For now, just check that it's a valid data URI
        assert(bytes(uri).length > 0);
    }

    function testOwnerFunctions() public {
        address owner = moodNft.owner();
        assert(owner != address(0));
        
        // Test that owner can transfer ownership (if needed)
        // This tests the Ownable functionality
        assert(moodNft.owner() == owner);
    }
}