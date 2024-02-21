// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.20;

import {ERC721Enumerable, ERC721} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {IHorseStore} from "./IHorseStore.sol";

/* 
 * @title HorseStore
 * @author equestrian_lover_420
 * @notice An NFT that represents a horse. Horses should be fed daily to keep happy, ideally several times a day. 
 */
contract HorseStore is IHorseStore, ERC721Enumerable {
    string constant NFT_NAME = "HorseStore";
    string constant NFT_SYMBOL = "HS";
    uint256 public constant HORSE_HAPPY_IF_FED_WITHIN = 1 days;

    mapping(uint256 id => uint256 lastFedTimeStamp) public horseIdToFedTimeStamp;

    constructor() ERC721(NFT_NAME, NFT_SYMBOL) {}

    /*
     * @notice allows anyone to mint their own horse NFT. 
     */
    function mintHorse() external {
        _safeMint(msg.sender, totalSupply());
    }

    /* 
     * @param horseId the id of the horse to feed
     * @notice allows anyone to feed anyone else's horse. 
     * 
     * @audit-medium: Feeding unminted horeses is currently allowed! 
     */
    function feedHorse(uint256 horseId) external {
        horseIdToFedTimeStamp[horseId] = block.timestamp;
    }

    /*
     * @param horseId the id of the horse to check
     * @return true if the horse is happy, false otherwise
     * @notice a horse is happy IFF it has been fed within the last HORSE_HAPPY_IF_FED_WITHIN seconds
     */
    function isHappyHorse(uint256 horseId) external view returns (bool) {
        if (horseIdToFedTimeStamp[horseId] <= block.timestamp - HORSE_HAPPY_IF_FED_WITHIN) {
            return false;
        }
        return true;
    }
}
