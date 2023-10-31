// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Base_Test, HorseStore, HorseStoreYul} from "./Base_Test.t.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

contract HorseStoreTest is Base_Test {
    function setUp() public override {
        super.setUp();
        horseStoreHuff = HorseStore(HuffDeployer.config().deploy(horseStoreLocation));
    }

    function testReadHuffValue() public {
        uint256 initalValue = horseStoreHuff.readNumberOfHorses();
        assertEq(initalValue, 0);
    }

    function testStoreAndReadHorseNumberHuff() public {
        uint256 numberOfHorses = 77;
        horseStoreHuff.updateHorseNumber(numberOfHorses);
        assertEq(horseStoreHuff.readNumberOfHorses(), numberOfHorses);
    }

    function testStoreAndReadHorseNumberYul() public {
        uint256 numberOfHorses = 77;
        horseStoreYul.updateHorseNumber(numberOfHorses);
        assertEq(horseStoreYul.readNumberOfHorses(), numberOfHorses);
    }

    function testCompareHorseStores(uint256 randomNumberToStore) public {
        horseStoreSol.updateHorseNumber(randomNumberToStore);
        horseStoreHuff.updateHorseNumber(randomNumberToStore);
        horseStoreYul.updateHorseNumber(randomNumberToStore);

        assertEq(horseStoreSol.readNumberOfHorses(), randomNumberToStore);
        assertEq(horseStoreHuff.readNumberOfHorses(), randomNumberToStore);
        assertEq(horseStoreYul.readNumberOfHorses(), randomNumberToStore);
    }
}
