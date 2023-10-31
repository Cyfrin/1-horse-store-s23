// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";
import {HorseStore} from "../src/HorseStore.sol";
import {HorseStoreYul} from "../src/HorseStoreYul.sol";
import {Test, console2} from "forge-std/Test.sol";

abstract contract Base_Test is Test {
    string public constant horseStoreLocation = "HorseStore";
    HorseStore horseStoreHuff;
    // HorseStoreYul horseStoreYul;
    HorseStore horseStoreSol;

    function setUp() public virtual {
        horseStoreHuff = HorseStore(HuffDeployer.config().deploy(horseStoreLocation));
        // horseStoreYul = new HorseStoreYul();

        // in halmos, this is deployed to `2863267842` aka 0xaaaa0002
        horseStoreSol = new HorseStore();
    }
}
