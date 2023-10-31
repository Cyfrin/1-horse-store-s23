// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface ISimpleStorage {
    function storeNumber(uint256 newNumber) external;

    function readNumber() external view returns (uint256);
}
