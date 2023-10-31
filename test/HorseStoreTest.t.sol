// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Base_Test, HorseStore, HorseStoreYul, HuffDeployer} from "./Base_Test.t.sol";

contract HorseStoreTest is Base_Test {
// function testDeployingHuffContractWorks() public {
//     HorseStore horseStoreLocal = HorseStore(HuffDeployer.deploy(horseStoreLocation));
//     assert(address(horseStoreLocal) != address(0));
// }

// function testReadHuffValue() public {
//     uint256 initalValue = horseStoreHuff.readNumberOfHorses();
//     assertEq(initalValue, 0);
// }

// function testStoreAndReadHorseNumberHuff() public {
//     uint256 numberOfHorses = 77;
//     horseStoreHuff.updateHorseNumber(numberOfHorses);
//     assertEq(horseStoreHuff.readNumberOfHorses(), numberOfHorses);
// }

// function testStoreAndReadHorseNumberYul() public {
//     uint256 numberOfHorses = 77;
//     horseStoreYul.updateHorseNumber(numberOfHorses);
//     assertEq(horseStoreYul.readNumberOfHorses(), numberOfHorses);
// }

// function testCompareHorseStores(uint256 randomNumberToStore) public {
//     horseStoreSol.updateHorseNumber(randomNumberToStore);
//     horseStoreHuff.updateHorseNumber(randomNumberToStore);
//     horseStoreYul.updateHorseNumber(randomNumberToStore);

//     assertEq(horseStoreSol.readNumberOfHorses(), randomNumberToStore);
//     assertEq(horseStoreHuff.readNumberOfHorses(), randomNumberToStore);
//     assertEq(horseStoreYul.readNumberOfHorses(), randomNumberToStore);
// }
}
