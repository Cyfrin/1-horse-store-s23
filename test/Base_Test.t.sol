// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";
import {HorseStore} from "../src/HorseStore.sol";
import {HorseStoreYul} from "../src/HorseStoreYul.sol";
import {Test, console2} from "forge-std/Test.sol";

contract Dummy {}

abstract contract Base_Test is Test {
    string public constant horseStoreLocation = "HorseStore";
    HorseStore horseStoreHuff;
    HorseStoreYul horseStoreYul;
    HorseStore horseStoreSol;

    function setUp() public virtual {
        // horseStoreHuff = HorseStore(HuffDeployer.config().deploy(horseStoreLocation));
        horseStoreHuff = HorseStore(address(new Dummy()));

        vm.etch(
            address(horseStoreHuff),
            hex"5f3560e01c8063cdfead2e1461001b578063e026c01714610022575b6004355f55005b5f545f5260205ff3"
        );

        horseStoreYul = new HorseStoreYul();

        // in halmos, this is deployed to `2863267842` aka 0xaaaa0002
        horseStoreSol = new HorseStore();
    }
}

// TODO
// // using runtime bytecode:
// //      huffc src/HorseStore.huff --bin-runtime
// //
// // horseStoreHuff = HorseStore(address(new Dummy()));
// // vm.etch(address(horseStoreHuff), hex"5f3560e01c8063cdfead2e1461001b578063e026c01714610022575b6004355f55005b5f545f5260205ff3");

// // using deployment bytecode:
// //      huffc src/HorseStore.huff --bytecode
// bytes memory deployBytecode = hex"602b8060093d393df35f3560e01c8063cdfead2e1461001b578063e026c01714610022575b6004355f55005b5f545f5260205ff3";
// address horseStoreHuffAddr;
// assembly {
//     horseStoreHuffAddr := create(0, add(deployBytecode, 0x20), mload(deployBytecode))
// }
// horseStoreHuff = HorseStore(horseStoreHuffAddr);
