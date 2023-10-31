// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {HorseStore} from "../src/HorseStore.sol";
import {HorseStoreYul} from "../src/HorseStoreYul.sol";
import {Test, console2} from "forge-std/Test.sol";

abstract contract Base_Test is Test {
    string public constant horseStoreLocation = "HorseStore";
    HorseStore horseStoreHuff;
    HorseStoreYul horseStoreYul;
    HorseStore horseStoreSol;

    function setUp() public virtual {
        horseStoreYul = new HorseStoreYul();
        horseStoreSol = new HorseStore();
    }
}
