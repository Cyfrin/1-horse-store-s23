// Try this in the playground! https://www.evm.codes/playground

object "HorseStoreYul" {
     code {
        // Contract deployment
        datacopy(0, dataoffset("runtime"), datasize("runtime"))
        return(0, datasize("runtime"))
     }
     object "runtime" {
        code {
            // The MAIN function of the contract, function dispatcher
            switch selector()
            // cast sig "updateHorseNumber(uint256)"
            case 0xcdfead2e {
                storeNumber(decodeAsUint(0))
            }
            // cast sig "readNumberOfHorses()"
            case 0xe026c017{
                returnUint(readNumber())
            }
            default {
                revert(0, 0)
            }

            function storeNumber(newNumber) {
                sstore(0, newNumber)
            }

            function readNumber() -> storedNumber{
                storedNumber := sload(0)
            }

            /* ---------- calldata decoding functions ----------- */
            function selector() -> s {
                s := div(calldataload(0), 0x100000000000000000000000000000000000000000000000000000000)
            }

            function decodeAsUint(offset) -> v {
                let pos := add(4, mul(offset, 0x20))
                if lt(calldatasize(), add(pos, 0x20)) {
                    revert(0, 0)
                }
                v := calldataload(pos)
            }

            function returnUint(v) {
                mstore(0, v)
                return(0, 0x20)
            }
        }
     }
}
