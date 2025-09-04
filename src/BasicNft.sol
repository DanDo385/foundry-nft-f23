// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {ERC721} from "openzeppelin-contracts/token/ERC721/ERC721.sol";

contract BasicNft is ERC721 {
    uint256 private s_tokenCounter;

    constructor() ERC721("Doggie", "DOG") {
        s_tokenCounter = 0;
    }

    function tokenURI(uint256 tokenId) public pure override returns (string memory) {
        return 
