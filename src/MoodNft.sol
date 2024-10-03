// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {ERC721} from "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MoodNft is ERC721 {
    uint256 private s_tokenCounter;
    string private s_sadSvgImageUri;
    string private s_happySvgImageUri;
    
    enum Mood {
        HAPPY,
        SAD
    }

    mapping(uint256 => Mood) private s_tokenIdToMood;

    event CreatedNft(uint256 indexed tokenId);

    error MoodNft__CantFlipMoodNotOwnerOfNft();

    constructor(
        string memory sadSvgURI, 
        string memory happySvgURI
    ) ERC721("Mood Nft", "MT") {
        s_tokenCounter = 0;
        s_sadSvgImageUri = sadSvgURI;
        s_happySvgImageUri = happySvgURI;
    }

    function mintNft() public {
        uint256 tokenCounter = s_tokenCounter;
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenIdToMood[s_tokenCounter] = Mood.HAPPY;
        s_tokenCounter++;
        emit CreatedNft(tokenCounter);
    }

    function flipMood(uint256 tokenId) public {
        if (getApproved(tokenId) != msg.sender && ownerOf(tokenId) != msg.sender) {
            revert MoodNft__CantFlipMoodNotOwnerOfNft();
        }

        if(s_tokenIdToMood[tokenId] == Mood.HAPPY) {
            s_tokenIdToMood[tokenId] = Mood.SAD;
        } else {
            s_tokenIdToMood[tokenId] == Mood.HAPPY;
        }
    }

    function _baseURI() internal pure override returns(string memory){
        return "data:application/json;base64,";
    }

    function tokenURI(uint256 tokenId) 
        public view override returns(string memory) {
            string storage imageURI;
             if(s_tokenIdToMood[tokenId] == Mood.HAPPY) {
                imageURI = s_happySvgImageUri;
             } else {
                imageURI = s_sadSvgImageUri;
             }

        return
            string(
                abi.encodePacked(
                    _baseURI(),
                        Base64.encode(
                            bytes(
                                abi.encodePacked(
                                '{"name":"',
                                            name(),
                                            '", "description":"An NFT that reflects the mood of the owner, 100% on Chain!", ',
                                            '"attributes": [{"trait_type": "moodiness", "value": 100}], "image":"',
                                            imageURI,
                                            '"}'
                                )
                            )
                        )   
                )
            );    
    }


}
