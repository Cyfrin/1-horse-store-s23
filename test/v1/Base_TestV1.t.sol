// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {HorseStore} from "../../src/horseStoreV1/HorseStore.sol";
import {HorseStoreYul} from "../../src/horseStoreV1/HorseStoreYul.sol";
import {Test, console2} from "forge-std/Test.sol";

abstract contract Base_TestV1 is Test {
    string public constant horseStoreLocation = "horseStoreV1/HorseStore";
    HorseStore horseStoreHuff;
    HorseStoreYul horseStoreYul;
    HorseStore horseStoreSol;

    function setUp() public virtual {
        horseStoreYul = new HorseStoreYul();
        horseStoreSol = new HorseStore();
    }
}
