// We break down all the opcodes of our solidity contract
// You can find the final opcodes in `solidity-breakdown.md`

// 1. CONTRACT CREATION CODE
// Free Memory Pointer
PUSH1 0x80        // [80]
PUSH1 0x40        // [40, 80]
MSTORE            // []

// Check msg.value, and jump
CALLVALUE          // [msg.value]
DUP1               // [msg.value, msg.value]
ISZERO             // [msg.value == 0, msg.value]
PUSH1 0xE          // [E, msg.value == 0, msg.value]
// Jump to JUMPDEST instruction at position E if Value is not sent
JUMPI              // [msg.value] 

// We only reach this part if msg.value has value, and will revert the TX
PUSH0              // [0, msg.value]
DUP1               // [0, 0, msg.value]
REVERT             // [msg.value]

// Finally, we push our contract code on-chain
JUMPDEST           // [msg.value] 
POP                // []
PUSH1 0xA5         // [A5]
DUP1               // [A5, A5]
PUSH2 0x1B         // [1B, A5, A5]
PUSH0              // [0, 1B, A5, A5]
CODECOPY           // [A5]
PUSH0              // [0, A5]
RETURN             // []

// End Contract Creation Code
INVALID            // []

// 2. RUNTIME CODE
// Free Memory Pointer
PUSH1 0x80         // [80]
PUSH1 0x40         // [40, 80]
MSTORE             // []

// msg.value check, jump to function if no value, revert otherwise
CALLVALUE          // [msg.value]   
DUP1               // [msg.value, msg.value]
ISZERO             // [msg.value == 0, msg.value]
PUSH1 0xE          // [E, msg.value == 0, msg.value]
JUMPI              // [msg.value]

// Revert if msg.value has value
PUSH0              // [0, msg.value]
DUP1               // [0, 0, msg.value]
REVERT             // [msg.value]

// We check the calldata to see if it's big enough for a function selector. 
// We jump to a revert if its too small
JUMPDEST           // [msg.value]
POP                // []
PUSH1 0x4          // [4]
CALLDATASIZE       // [calldatasize, 4]
// This is the check that says "hey, function selectors are 4 bytes, does the calldata have at least 4 bytes?"
LT                 // [calldatasize < 4]
PUSH1 0x30         // [30, calldatasize < 4]
JUMPI              // []

// Now, we finally find the function selector, and we start doing "function dispatching"
// This is where we compare the function selector from the call data to the function selectors of our functions
// First, we need to get our function selector
PUSH0              // [0]
CALLDATALOAD       // [calldata]
PUSH1 0xE0         // [E0, calldata]
// We shift our calldata to the right by 0xE0 so we can just get the first 4 bytes, aka, the selector!
SHR                // [calldata >> E0 (function_selector)]
DUP1               // [function_selector, function_selector]
// cast sig "updateHorseNumber(uint256)" ->  0xCDFEAD2E
// We are checking to see if the calldata is for the `updateHorseNumber(uint256)` function!
PUSH4 0xCDFEAD2E   // [CDFEAD2E, function_selector, function_selector]
EQ                 // [function_selector == CDFEAD2E, function_selector]
PUSH1 0x34         // [34, function_selector == CDFEAD2E, function_selector]
// If the function selector matches, we jump to the updateHorseNumber(uint256) part of the bytecode!
JUMPI              // [function_selector]

// If it doesn't match, we have to check our other function!
DUP1               // [function_selector, function_selector]
// cast sig "readNumberOfHorses()" -> 0xE026C017
PUSH4 0xE026C017   // [E026C017, function_selector, function_selector]
EQ                 // [function_selector == E026C017, function_selector]
PUSH1 0x45         // [45, function_selector == E026C017, function_selector]
// Jump to the "readNumberOfHorses()" section if it matches!
JUMPI              // [function_selector]

// One of our revert destinations
// Also, if none of our function selctors match, we revert!
JUMPDEST           // [function_selector]
PUSH0              // [0, function_selector]
DUP1               // [0, 0, function_selector]
REVERT             // [function_selector]

// updateHorseNumber jump dest 1
// This is the jump destination of the `updateHorseNumber(uint256)` function!
// We do a little bit of stack setup for the function, and jump again
JUMPDEST           // [function_selector]                                
PUSH1 0x43         // [43, function_selector]                            
PUSH1 0x3F         // [3F, 43, function_selector]                       
CALLDATASIZE       // [calldatasize, 3F, 43, function_selector]         
PUSH1 0x4          // [4, calldatasize, 3F, 43, function_selector]      
PUSH1 0x59         // [59, 4, calldatasize, 3F, 43, function_selector]  
JUMP               // [4, calldatasize, 3F, 43, function_selector]      

// updateHorseNumber jump dest 4
// We can FINALLY run sstore to save our value to storage. Only NOW that we have:
// 1. Done the function dispatch
// 2. Checked for any msg.value
// 3. Checked to see if the calldata is big enough to add a uint256
// 4. Removed the function selector from the calldata 
JUMPDEST           // [calldata (without function selector), 43, function_selector]
PUSH0              // [0, calldata, 43, function_selector]
SSTORE             // [43, function_selector]
JUMP               // [function_selector]

// updateHorseNumber jump dest 5
// And we are done!!
JUMPDEST           // [function_selector]
STOP               // [function_selector]


// readNumberOfHorses jump dest 1
JUMPDEST           // [function_selector]       
PUSH0              // [0, function_selector] 
SLOAD              // [storage value at slot 0, function_selector]
// 0x40 is the location in memory of our free memory pointer!
// 0x40 holds where free memory starts. It starts at 0x80
PUSH1 0x40         // [40, storage value at slot 0, function_selector]
MLOAD              // [memory value at 0x40 (free memory pointer!), storage value at slot 0, function_selector]
SWAP1              // [storage value at slot 0, free memory pointer, function_selector]
DUP2               // [free memory pointer, storage value at slot 0, free memory pointer, function_selector]
// The MSTORE function will put our `storage value at slot 0` into memory where our free memory pointer says free memory starts (0x40)
MSTORE             // [free memory pointer, function_selector]
PUSH1 0x20         // [20, free memory pointer, function_selector]
ADD                // [20 + free memory pointer, function_selector]
PUSH1 0x40         // [40, 20 + free memory pointer, function_selector]
MLOAD              // [memory at 0x40 (free memory pointer!), 20 + free memory pointer, function_selector]
DUP1               // [free memory pointer, free memory pointer, 20 + free memory pointer, function_selector]
SWAP2              // [20 + free memory pointer, free memory pointer, free memory pointer, function_selector]
SUB                // [(20 + free memory pointer) - (free memory pointer) aka 20, free memory pointer, function_selector]
SWAP1              // [free memory pointer, 20, function_selector]
// To return our value, we need to point to storage. Since we placed our SLOADed value into the free memory pointer location, we can just return that!
// The 20 stands for how big it should be. 0x20 == 32 bytes, a uint256 is 32 bytes. 
RETURN             // [function_selector]

// updateHorseNumber jump dest 2
// We check to see there is enough calldata for the function (not including the function selector)
// A uint256 is 32 bytes! (0x20 == 32 bytes)
// If there isn't enough data, we revert
JUMPDEST            // [4, calldatasize, 3F, 43, function_selector]
PUSH0               // [0, 4, calldatasize, 3F, 43, function_selector]
PUSH1 0x20          // [20, 0, 4, calldatasize, 3F, 43, function_selector]
DUP3                // [4, 20, 0, 4, calldatasize, 3F, 43, function_selector]
DUP5                // [calldatasize, 4, 20, 0, 4, calldatasize, 3F, 43, function_selector]
SUB                 // [calldatasize - 4, 20, 0, 4, calldatasize, 3F, 43, function_selector]
SLT                 // [(calldatasize - 4) < 20, 0, 4, calldatasize, 3F, 43, function_selector]
// if (calldatasize - 4) < 20 is "true" it will be anything other than 0, aka 1. False is 0
ISZERO              // [(calldatasize - 4) < 20 == 0, 0, 4, calldatasize, 3F, 43, function_selector]
PUSH1 0x68          // [68, (calldatasize - 4) < 20 == 0, 0, 4, calldatasize, 3F, 43, function_selector]
JUMPI               // [0, 4, calldatasize, 3F, 43, function_selector]
// Jump back to updateHorseNumber jump dest 1 if there is enough data
PUSH0               // [0, 0, 4, calldatasize, 3F, 43, function_selector]
DUP1                // [0, 0, 0, 4, calldatasize, 3F, 43, function_selector]
REVERT              // [0, 0, 4, calldatasize, 3F, 43, function_selector]

// updateHorseNumber jump dest 3
// This gets the calldata, butremoves the function selector
JUMPDEST            // [0, 4, calldatasize, 3F, 43, function_selector]
POP                 // [4, calldatasize, 3F, 43, function_selector]
CALLDATALOAD        // [calldata (without function selector), calldatasize, 3F, 43, function_selector]
SWAP2               // [3F, calldatasize, calldata, 43, function_selector]
SWAP1               // [calldatasize, 3F, calldata, 43, function_selector]
POP                 // [3F, calldata, 43, function_selector]
JUMP                // [calldata, 43, function_selector]

// End Runtime Code
INVALID            


// 3. CONTRACT METADATA
// Contract metadata. Not reachable. Has some stuff that helps identify what solidity compiler version was used and stuff. Not important for us. 
LOG2 PUSH5 0x6970667358 0x22 SLT KECCAK256 0xA9 0xF8 0xF9 ISZERO CALLDATASIZE PUSH11 0xDA1B50AA56817AA4D80C37 0x2A 0x2B SWAP15 0xE0 0xCD 0xE4 OR CALLDATASIZE 0x5D 0xD4 0xBE SWAP15 0xC8 PUSH28 0x5464736F6C6343000814003300000000000000000000000000000000