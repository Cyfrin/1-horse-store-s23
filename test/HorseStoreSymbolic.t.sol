// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Base_Test, HorseStore, HorseStoreYul} from "./Base_Test.t.sol";

contract HorseStoreSymbolic is Base_Test {
    // https://twitter.com/zachobront/status/1633906650514898947
    // halmos --function check_storeAndReadAreIdentical
    function check_storeAndReadAreIdentical(uint256 randomNumber) public {
        // horseStoreHuff.updateHorseNumber(randomNumber);
        // horseStoreYul.updateHorseNumber(randomNumber);
        horseStoreSol.updateHorseNumber(randomNumber);

        // assert(horseStoreHuff.readNumberOfHorses() == randomNumber);
        // assert(horseStoreYul.readNumberOfHorses() == randomNumber);
        assert(horseStoreSol.readNumberOfHorses() == randomNumber);
    }
}
