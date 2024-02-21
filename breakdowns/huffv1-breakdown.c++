// We breakdown the huff contract
// Binary: 602b8060093d393df35f3560e01c8063cdfead2e1461001b578063e026c01714610022575b6004355f55005b5f545f5260205ff3

// 1. Contract Creation Code
// All it does is stick our contract on-chain. No checks. 
PUSH1 0x2b        // [2b]
DUP1              // [2b, 2b]
PUSH1 0x09        // [09, 2b, 2b]
RETURNDATASIZE    // [returndatasize, 09, 2b, 2b]
CODECOPY          // [2b]
RETURNDATASIZE    // [returndatasize, 2b]
RETURN            // []

// 2. Runtime Code
// We go RIGHT away into the function dispatching
// #define macro MAIN() = takes (0) returns (0) {
PUSH0             // [0]
CALLDATALOAD      // [calldataload]
PUSH1 0xe0        // [e0, calldataload]
SHR               // [calldataload >> e0 (function selector!)]
DUP1              // [function_selector, function_selector]
// cast sig updateHorseNumber(uint256)
PUSH4 0xcdfead2e  // [cdfead2e, function_selector, function_selector]
EQ                // [function_selector == cdfead2e, function_selector]
PUSH2 0x001b      // [1b, function_selector == cdfead2e, function_selector]
JUMPI             // [function_selector]
DUP1              // [function_selector, function_selector]
// cast sig readNumberOfHorses()
PUSH4 0xe026c017  // [e026c017, function_selector, function_selector]
EQ                // [function_selector == e026c017, function_selector]
PUSH2 0x0022      // [0022, function_selector == e026c017, function_selector]
JUMPI             // [function_selector]

// Jump dest for updateHorseNumber
// Woah! We found a bug too! If there is not matching function selector, we will just keep going here! 
JUMPDEST          // [function_selector]   
PUSH1 0x04        // [04, function_selector]
CALLDATALOAD      // [calldataload (without function selector), function_selector]
PUSH0             // [0, calldataload, function_selector]
SSTORE            // [function_selector]
STOP              // [function_selector]

// Jump dest for readNumberOfHorses
JUMPDEST          // [function_selector]
PUSH0             // [0, function_selector]
SLOAD             // [storage value at slot 0, function_selector]
PUSH0             // [0, storage value at slot 0, function_selector]
// load the storage value at slot 0 into memory 
MSTORE            // [function_selector]
PUSH1 0x20        // [20, function_selector]
PUSH0             // [0, 20, function_selector]
RETURN            // [function_selector]