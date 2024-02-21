// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.20;

import {IERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

/* 
 * @title IHorseStore
 * @author equestrian_lover_420
 */
interface IHorseStore is IERC721Enumerable {
    function mintHorse() external;

    function feedHorse(uint256 horseId) external;

    function isHappyHorse(uint256 horseId) external view returns (bool);
}
