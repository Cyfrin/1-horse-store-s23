# First Flight #7: Horse Store - Findings Report

# Table of contents
- ### [Contest Summary](#contest-summary)
- ### [Results Summary](#results-summary)
- ## High Risk Findings
    - [H-01. Feeding horses at certain block timestamps will fail, violating the invariant that horses must be able to be fed at all times](#H-01)
    - [H-02. Checking if a horse is happy after being fed in the past 24 hours returns incorrect result, violating the invariant](#H-02)
    - [H-03. Huff implementation cant mint more than one NFT](#H-03)
    - [H-04. Huff implementation cant mint more than one NFT](#H-04)
    - [H-05. Default Function Dispatching Calls `totalSupply()`](#H-05)
- ## Medium Risk Findings
    - [M-01. HorseStore.huff Incorrect implementation of the horseIdToFedTimeStamp mapping](#M-01)
    - [M-02. SafeTransferFrom() Not Implemented in Huff Code](#M-02)
    - [M-03. Huff Implementation Not Rejecting Ether Transfers](#M-03)
- ## Low Risk Findings
    - [L-01. It is possible to feed a horse with an invalid token ID, i.e., an ID that does not correspond to any minted horse NFT](#L-01)
    - [L-02. Unsupported Opcode PUSH0 in Solidity 0.8.20 for Deployment on Arbitrum Chain](#L-02)
    - [L-03. The same `horseId` can be happy on `Arbitrum` but unhappy on `Ethereum`](#L-03)


# <a id='contest-summary'></a>Contest Summary

### Sponsor: First Flight #7

### Dates: Jan 11th, 2024 - Jan 18th, 2024

[See more contest details here](https://www.codehawks.com/contests/clr6s75ut00013qg9z8bpkalo)

# <a id='results-summary'></a>Results Summary

### Number of findings:
   - High: 5
   - Medium: 3
   - Low: 3


# High Risk Findings

## <a id='H-01'></a>H-01. Feeding horses at certain block timestamps will fail, violating the invariant that horses must be able to be fed at all times

_Submitted by [0x4non](/profile/clk3udrho0004mb08dm6y7y17), [Honour](/profile/clrc98bu4000011oz4po0q5dd), [Kaiziron](/profile/clk418fns001ejl08ygpwwp08), [KiteWeb3](/profile/clk9pzw3j000smh08313lj91l), [0xTheBlackPanther](/profile/clnca1ftl0000lf08bfytq099), [n0kto](/profile/clm0jkw6w0000jv08gaj4hof4), [shikhar229169](/profile/clk3yh639002emf08ywok1hzf), [flokapi2](/profile/clq707ku40000yzp9blkwbqkc), [stefanlatinovic](/profile/clpbb43ek0014aevzt4shbvx2), [ceseshi](/profile/cln8zm3hz000gmf08kqdt7i5b), [Turetos](/profile/clof0okll002ila08y4of251r), [wafflemakr](/profile/clmm1t0210000mi08hak3ir5r), [Coffee](/profile/clln3vyj7000cml0877uhlb7j), [0xloscar01](/profile/cllgowxgy0002la08qi9bhab4), [Ritos](/profile/clqc7vjma0000jmo2axfqt88m). Selected submission by: [stefanlatinovic](/profile/clpbb43ek0014aevzt4shbvx2)._      
				
### Relevant GitHub Links
	
https://github.com/Cyfrin/2024-01-horse-store/blob/main/src/HorseStore.huff#L86

https://github.com/Cyfrin/2024-01-horse-store/blob/main/src/HorseStore.huff#L88

## Summary

Feeding a horse at specific block timestamps is prevented by the implementation of the `HorseStore.huff::FEED_HORSE()` function, leading to Denial-of-Service (DoS).

## Vulnerability Details

The `HorseStore.huff::FEED_HORSE()` function contains a code segment that reverts the transaction if the remainder of the current block timestamp and number `17` (`0x11`) is equal to `0`, which is expressed as:

```
0x11 timestamp mod
endFeed jumpi
revert
endFeed:
stop
```

## Impact

Horses are not able to be fed at all times.

## Proof of Concept (PoC)

Add the next test in `HorseStoreHuff.t.sol`.

```javascript
function test_FeedingHorseRevertsAtSpecificTimestamps(uint256 horseId, uint256 feedAt) public {
    vm.assume(feedAt % 0x11 == 0); // simulate the timestamp of the block at which a transaction will fail
    vm.warp(feedAt);

    vm.expectRevert();
    horseStore.feedHorse(horseId);
}
```

Run a test with `forge test --mt test_FeedingHorseRevertsAtSpecificTimestamps`.

## Tools Used

- Foundry

## Recommendations

It is recommended to remove the code that reverts at certain block timestamps. 

Recommended changes to `HorseStore.huff::FEED_HORSE()` function:

```diff
#define macro FEED_HORSE() = takes (0) returns (0) {
    timestamp               // [timestamp]
    0x04 calldataload       // [horseId, timestamp]
    STORE_ELEMENT(0x00)     // []

    // End execution 
-    0x11 timestamp mod      
-    endFeed jumpi                
-    revert 
-    endFeed:
    stop
}
```

Add the next test in `HorseStoreHuff.t.sol`.

```javascript
function test_FeedingHorseIsPossibleAtAnyTimestamp(uint256 horseId, uint256 feedAt) public {
    vm.warp(feedAt);

    horseStore.feedHorse(horseId);
}
```

Run a test with `forge test --mt test_FeedingHorseIsPossibleAtAnyTimestamp`.
## <a id='H-02'></a>H-02. Checking if a horse is happy after being fed in the past 24 hours returns incorrect result, violating the invariant

_Submitted by [Poor4ever](/profile/clqed8yto0000xs7svdgqz0cs), [VicRdev](/profile/clpbjipom001uxpj2hued91zg), [Kaiziron](/profile/clk418fns001ejl08ygpwwp08), [Honour](/profile/clrc98bu4000011oz4po0q5dd), [n0kto](/profile/clm0jkw6w0000jv08gaj4hof4), [shikhar229169](/profile/clk3yh639002emf08ywok1hzf), [stefanlatinovic](/profile/clpbb43ek0014aevzt4shbvx2), [ceseshi](/profile/cln8zm3hz000gmf08kqdt7i5b), [wafflemakr](/profile/clmm1t0210000mi08hak3ir5r), [Coffee](/profile/clln3vyj7000cml0877uhlb7j), [Ritos](/profile/clqc7vjma0000jmo2axfqt88m), [0x18a6](/profile/clrfli8sn00007xk2xgi0xg2l). Selected submission by: [stefanlatinovic](/profile/clpbb43ek0014aevzt4shbvx2)._      
				
### Relevant GitHub Links
	
https://github.com/Cyfrin/2024-01-horse-store/blob/main/src/HorseStore.huff#L100

## Summary

A horse is marked as not happy even if it has been fed within the past 24 hours.

## Vulnerability Details

The current implementation of the `HorseStore.huff::IS_HAPPY_HORSE()` function won't provide an accurate result as it returns `false` even if the horse has been fed within the past 24 hours.

## Impact

One of the contract's invariants has been violated because the check for the horse's happiness is resulting in a false negative.

## Proof of Concept (PoC)

Add the next test in `HorseStoreHuff.t.sol`.

```javascript
function test_HorseIsNotHappyIfFedWithinPast24Hours(uint256 horseId, uint256 checkAt) public {
    uint256 fedAt = horseStore.HORSE_HAPPY_IF_FED_WITHIN();
    checkAt = bound(checkAt, fedAt + 1 seconds, fedAt + horseStore.HORSE_HAPPY_IF_FED_WITHIN() - 1 seconds); // it has been less than 24 hours since the last feeding time
    vm.warp(fedAt);
    horseStore.feedHorse(horseId);
    
    vm.warp(checkAt);
    assertEq(horseStore.isHappyHorse(horseId), false); // horse seems unhappy despite being fed less than 24 hours ago
}
```

Run a test with `forge test --mt test_HorseIsNotHappyIfFedWithinPast24Hours`.

## Tools Used

- Foundry

## Recommendations

Recommended changes to `HorseStore.huff::IS_HAPPY_HORSE()` function:

```diff
#define macro IS_HAPPY_HORSE() = takes (0) returns (0) {
    0x04 calldataload                   // [horseId]
    LOAD_ELEMENT(0x00)                  // [horseFedTimestamp]
    timestamp                           // [timestamp, horseFedTimestamp]
    dup2 dup2                           // [timestamp, horseFedTimestamp, timestamp, horseFedTimestamp]
    sub                                 // [timestamp - horseFedTimestamp, timestamp, horseFedTimestamp]
    [HORSE_HAPPY_IF_FED_WITHIN_CONST]   // [HORSE_HAPPY_IF_FED_WITHIN, timestamp - horseFedTimestamp, timestamp, horseFedTimestamp]
-    lt                                  // [HORSE_HAPPY_IF_FED_WITHIN < timestamp - horseFedTimestamp, timestamp, horseFedTimestamp]
+    gt                                  // [HORSE_HAPPY_IF_FED_WITHIN > timestamp - horseFedTimestamp, timestamp, horseFedTimestamp]
    start_return_true jumpi             // [timestamp, horseFedTimestamp]
    eq                                  // [timestamp == horseFedTimestamp]
    start_return 
    jump
    
    start_return_true:
    0x01

    start_return:
    // Store value in memory.
    0x00 mstore

    // Return value
    0x20 0x00 return
}
```

Add the next test in `HorseStoreHuff.t.sol`.

```javascript
function test_HorseIsHappyIfFedWithinPast24Hours(uint256 horseId, uint256 checkAt) public {
    uint256 fedAt = horseStore.HORSE_HAPPY_IF_FED_WITHIN();
    checkAt = bound(checkAt, fedAt + 1 seconds, fedAt + horseStore.HORSE_HAPPY_IF_FED_WITHIN() - 1 seconds); // it has been less than 24 hours since the last feeding time
    vm.warp(fedAt);
    horseStore.feedHorse(horseId);
    
    vm.warp(checkAt);
    assertEq(horseStore.isHappyHorse(horseId), true);
}
```

Run a test with `forge test --mt test_HorseIsHappyIfFedWithinPast24Hours`.
## <a id='H-03'></a>H-03. Huff implementation cant mint more than one NFT

_Submitted by [0x4non](/profile/clk3udrho0004mb08dm6y7y17), [Poor4ever](/profile/clqed8yto0000xs7svdgqz0cs), [0xTheBlackPanther](/profile/clnca1ftl0000lf08bfytq099), [VicRdev](/profile/clpbjipom001uxpj2hued91zg), [jerseyjoewalcott](/profile/clnueldbf000lky08h4g3kjx4), [Honour](/profile/clrc98bu4000011oz4po0q5dd), [bigBagBoogy](/profile/clk4a6w3s000wmr08ea0okpuz), [n0kto](/profile/clm0jkw6w0000jv08gaj4hof4), [Turetos](/profile/clof0okll002ila08y4of251r), [flokapi2](/profile/clq707ku40000yzp9blkwbqkc), [stefanlatinovic](/profile/clpbb43ek0014aevzt4shbvx2), [naman1729](/profile/clk41lnhu005wla08y1k4zaom), [TorpedopistolIxc41](/profile/clk5ki3ah0000jq08yaeho8g7), [ceseshi](/profile/cln8zm3hz000gmf08kqdt7i5b), [Aitor](/profile/clk44j5cn000wl908r2o0n9w5), [CloudTact](/profile/clriba5t60000szv0zi8a6o4c), [azanux](/profile/clk45q9ry0000l5080kf923kw), [wafflemakr](/profile/clmm1t0210000mi08hak3ir5r), [0xloscar01](/profile/cllgowxgy0002la08qi9bhab4), [0x18a6](/profile/clrfli8sn00007xk2xgi0xg2l), [shikhar229169](/profile/clk3yh639002emf08ywok1hzf). Selected submission by: [0x4non](/profile/clk3udrho0004mb08dm6y7y17)._      
				
### Relevant GitHub Links
	
https://github.com/Cyfrin/2024-01-horse-store/blob/9e1e017ca3db93ed6e719505fcd9dccb1c5df8d8/src/HorseStore.huff#L73-L78

## Summary
The contract fails to increment the total supply of NFTs with each mint, leading to repeated attempts to mint the same NFT identifier and consequently causing the transaction to revert.

## Vulnerability Details
The issue is located in the minting function `MINT_HORSE()` within the Huff code. The function, designed to mint a new NFT, references the `TOTAL_SUPPLY` but does not increment it after minting an NFT. This oversight results in the `TOTAL_SUPPLY` remaining constant, causing every minting attempt after the first to try to mint an NFT with an already existing identifier. 

The relevant code from the `HorseStore.huff` file is as follows:
```solidity
#define macro MINT_HORSE() = takes (0) returns (0) {
    [TOTAL_SUPPLY] // [TOTAL_SUPPLY]
    caller         // [msg.sender, TOTAL_SUPPLY]
    _MINT()        // [] 
    stop           // []
}
```

## Impact
This bug effectively renders the contract incapable of minting more than one unique NFT, severely limiting the functionality and utility of the NFT contract. It directly contradicts the expected behavior of an NFT minting process, where each minted token should have a unique identifier.

## Tools Used
Manual review

## Recommendations
To rectify this problem, the following changes are recommended:
1. Modify the `MINT_HORSE()` function to increment the `TOTAL_SUPPLY` each time an NFT is successfully minted. This can be achieved by adding a line of code within the macro to increment the `TOTAL_SUPPLY` storage variable.
2. Ensure that the incrementation logic correctly handles potential overflows to maintain contract security.
3. After implementing the changes, thoroughly test the updated contract to verify that each minting operation results in a unique NFT identifier and that the `TOTAL_SUPPLY` reflects the correct number of minted NFTs.

Sample fix:

```solidity
#define macro MINT_HORSE() = takes (0) returns (0) {
    [TOTAL_SUPPLY]  // [TOTAL_SUPPLY]
    sload           // [totalSupply]
    dup1            // [totalSupply, totalSupply]
    caller          // [msg.sender, totalSupply, totalSupply]
    _MINT()         // [totalSupply] 
    0x01 add        // [totalSupply]
    [TOTAL_SUPPLY] sstore
    stop            // []
}
```

## POC

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";
import {HorseStore} from "../src/HorseStore.sol";

import {IERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

contract MixedHuffTest is Test {
    string public constant NFT_NAME = "HorseStore";
    string public constant NFT_SYMBOL = "HS";
    string public constant horseStoreLocation = "HorseStore";
    HorseStore horseStoreHuff;
    HorseStore horseStoreSol;

    function setUp() public  {
        horseStoreSol = new HorseStore();
        horseStoreHuff = HorseStore(
            HuffDeployer.config().with_args(bytes.concat(abi.encode(NFT_NAME), abi.encode(NFT_SYMBOL))).deploy(
                horseStoreLocation
            )
        );
    }

    function testMintTwo() public {
        address user = makeAddr("user");
        deal(user, 1 ether);
        vm.warp(10);
        vm.roll(10);
        vm.startPrank(user);

        horseStoreSol.mintHorse();
        horseStoreSol.mintHorse();
        assertEq(horseStoreSol.totalSupply(), 2);
        assertEq(horseStoreSol.balanceOf(user), 2);
        
        // lets try the same with huff version
        horseStoreHuff.mintHorse();
        // this will revert with message ALREADY_MINTED
        horseStoreHuff.mintHorse();
        assertEq(horseStoreHuff.totalSupply(), 2);
        assertEq(horseStoreHuff.balanceOf(user), 2);
        
        vm.stopPrank();
    }
}
```
## <a id='H-04'></a>H-04. Huff implementation cant mint more than one NFT

_Submitted by [0x4non](/profile/clk3udrho0004mb08dm6y7y17), [Poor4ever](/profile/clqed8yto0000xs7svdgqz0cs), [VicRdev](/profile/clpbjipom001uxpj2hued91zg), [jerseyjoewalcott](/profile/clnueldbf000lky08h4g3kjx4), [Honour](/profile/clrc98bu4000011oz4po0q5dd), [bigBagBoogy](/profile/clk4a6w3s000wmr08ea0okpuz), [n0kto](/profile/clm0jkw6w0000jv08gaj4hof4), [Turetos](/profile/clof0okll002ila08y4of251r), [flokapi2](/profile/clq707ku40000yzp9blkwbqkc), [stefanlatinovic](/profile/clpbb43ek0014aevzt4shbvx2), [ceseshi](/profile/cln8zm3hz000gmf08kqdt7i5b), [Coffee](/profile/clln3vyj7000cml0877uhlb7j), [0xloscar01](/profile/cllgowxgy0002la08qi9bhab4), [0x18a6](/profile/clrfli8sn00007xk2xgi0xg2l). Selected submission by: [0x4non](/profile/clk3udrho0004mb08dm6y7y17)._      
				
### Relevant GitHub Links
	
https://github.com/Cyfrin/2024-01-horse-store/blob/9e1e017ca3db93ed6e719505fcd9dccb1c5df8d8/src/HorseStore.huff#L73-L78

## Summary
The contract fails to increment the total supply of NFTs with each mint, leading to repeated attempts to mint the same NFT identifier and consequently causing the transaction to revert.

## Vulnerability Details
The issue is located in the minting function `MINT_HORSE()` within the Huff code. The function, designed to mint a new NFT, references the `TOTAL_SUPPLY` but does not increment it after minting an NFT. This oversight results in the `TOTAL_SUPPLY` remaining constant, causing every minting attempt after the first to try to mint an NFT with an already existing identifier. 

The relevant code from the `HorseStore.huff` file is as follows:
```solidity
#define macro MINT_HORSE() = takes (0) returns (0) {
    [TOTAL_SUPPLY] // [TOTAL_SUPPLY]
    caller         // [msg.sender, TOTAL_SUPPLY]
    _MINT()        // [] 
    stop           // []
}
```

## Impact
This bug effectively renders the contract incapable of minting more than one unique NFT, severely limiting the functionality and utility of the NFT contract. It directly contradicts the expected behavior of an NFT minting process, where each minted token should have a unique identifier.

## Tools Used
Manual review

## Recommendations
To rectify this problem, the following changes are recommended:
1. Modify the `MINT_HORSE()` function to increment the `TOTAL_SUPPLY` each time an NFT is successfully minted. This can be achieved by adding a line of code within the macro to increment the `TOTAL_SUPPLY` storage variable.
2. Ensure that the incrementation logic correctly handles potential overflows to maintain contract security.
3. After implementing the changes, thoroughly test the updated contract to verify that each minting operation results in a unique NFT identifier and that the `TOTAL_SUPPLY` reflects the correct number of minted NFTs.

Sample fix:
```solidity
#define macro MINT_HORSE() = takes (0) returns (0) {
    [TOTAL_SUPPLY]  // [TOTAL_SUPPLY]
    sload           // [totalSupply]
    dup1            // [totalSupply, totalSupply]
    caller          // [msg.sender, totalSupply, totalSupply]
    _MINT()         // [totalSupply] 
    0x01 add        // [totalSupply]
    [TOTAL_SUPPLY] sstore
    stop            // []
}
```

## POC

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";
import {HorseStore} from "../src/HorseStore.sol";

import {IERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

contract MixedHuffTest is Test {
    string public constant NFT_NAME = "HorseStore";
    string public constant NFT_SYMBOL = "HS";
    string public constant horseStoreLocation = "HorseStore";
    HorseStore horseStoreHuff;
    HorseStore horseStoreSol;

    function setUp() public  {
        horseStoreSol = new HorseStore();
        horseStoreHuff = HorseStore(
            HuffDeployer.config().with_args(bytes.concat(abi.encode(NFT_NAME), abi.encode(NFT_SYMBOL))).deploy(
                horseStoreLocation
            )
        );
    }

    function testMintTwo() public {
        address user = makeAddr("user");
        deal(user, 1 ether);
        vm.warp(10);
        vm.roll(10);
        vm.startPrank(user);

        horseStoreSol.mintHorse();
        horseStoreSol.mintHorse();
        assertEq(horseStoreSol.totalSupply(), 2);
        assertEq(horseStoreSol.balanceOf(user), 2);
        
        // lets try the same with huff version
        horseStoreHuff.mintHorse();
        // this will revert with message ALREADY_MINTED
        horseStoreHuff.mintHorse();
        assertEq(horseStoreHuff.totalSupply(), 2);
        assertEq(horseStoreHuff.balanceOf(user), 2);
        
        vm.stopPrank();
    }
}
```
## <a id='H-05'></a>H-05. Default Function Dispatching Calls `totalSupply()`

_Submitted by [Poor4ever](/profile/clqed8yto0000xs7svdgqz0cs), [0xTheBlackPanther](/profile/clnca1ftl0000lf08bfytq099), [n0kto](/profile/clm0jkw6w0000jv08gaj4hof4), [Turetos](/profile/clof0okll002ila08y4of251r), [stefanlatinovic](/profile/clpbb43ek0014aevzt4shbvx2), [flokapi2](/profile/clq707ku40000yzp9blkwbqkc), [Honour](/profile/clrc98bu4000011oz4po0q5dd), [ceseshi](/profile/cln8zm3hz000gmf08kqdt7i5b), [TorpedopistolIxc41](/profile/clk5ki3ah0000jq08yaeho8g7), [EloiManuel](/profile/clq2hor730000b8vl1unuep88). Selected submission by: [EloiManuel](/profile/clq2hor730000b8vl1unuep88)._      
				
### Relevant GitHub Links
	
https://github.com/Cyfrin/2024-01-horse-store/blob/8255173c9340c12501881c9ecdd4175ff7350f5d/src/HorseStore.huff#L169

## Summary
The default function called (equivalent to Solidity's `fallback()`) when interacting with the Huff version of the `HorseStore` contract (`HorseStore.huff`) will call the logic of the `totalSupply()` function.

## Vulnerability Details
Below is the code snippet where it is possible to see that the default function that will be called if no signature is matched will be `GET_TOTAL_SUPPLY()` which contains the logic of `totalSupply()`.

```
    dup1 __FUNC_SIG(balanceOf) eq balanceOf jumpi
    dup1 __FUNC_SIG(ownerOf) eq ownerOf jumpi

    totalSupply:
@>      GET_TOTAL_SUPPLY()
    ...
```

Also, a default `MINT_HORSE()` is present at the end of the dispatching logic which doesn't really make sense:

```diff
      ownerOf:
         OWNER_OF()
@> MINT_HORSE()
}
```

## Impact
Any user calling the contract with a random or empty function signature will be effectively calling `totalSupply()` instead of reverting.

## Tools Used
Foundry and manual analysis.

## Recommendations
It is recommended to add a failed dispatch logic when no function signature matches:

```diff
    dup1 __FUNC_SIG(balanceOf) eq balanceOf jumpi
    dup1 __FUNC_SIG(ownerOf) eq ownerOf jumpi

+   // Revert on failed dispatch
+   0x00 dup1 revert

    totalSupply:
        GET_TOTAL_SUPPLY()
```

Also, make sure to also remove the last `MINT_HORSE()` function call at the end of the dispatching logic to avoid any future logic errors:

```diff
   ownerOf:
        OWNER_OF()
- MINT_HORSE()
}
```

# Medium Risk Findings

## <a id='M-01'></a>M-01. HorseStore.huff Incorrect implementation of the horseIdToFedTimeStamp mapping

_Submitted by [Poor4ever](/profile/clqed8yto0000xs7svdgqz0cs), [DarkTower ](/team/clmuj4vc00005mo08knfwx1dl). Selected submission by: [Poor4ever](/profile/clqed8yto0000xs7svdgqz0cs)._      
				
### Relevant GitHub Links
	
https://github.com/Cyfrin/2024-01-horse-store/blob/main/src/HorseStore.huff#L66

https://github.com/Cyfrin/2024-01-horse-store/blob/main/src/HorseStore.huff#L83

## Summary
HorseStore.huff Incorrect implementation of the `horseIdToFedTimeStamp` mapping

## Vulnerability Details
According to the specification, the storage of mapping values in the EVM should be at `keccak256(key, slot)`, However, the implemented method is `STORE_ELEMENT()`, which stores the value to the slot `keccak256(abi.encode(key))`.

Add this test to Base_Test.t.sol and run forge test --mt testSlot -vvvv to validate the issue

```javascript
    function testSlot() public {
        uint timestamp = 1705152551;
        vm.warp(timestamp);
        vm.prank(user);
        for (uint256 index; index < 10; index++) {
            horseStore.feedHorse(index);
            bytes32 value = vm.load(address(horseStore), keccak256(abi.encode(index)));
            assertEq(value, bytes32(timestamp));
        }
```

## Impact
May lead to unexpected storage conflicts, as the storage slot calculation for Dynamically-Sized Arrays is keccak256(abi.encode(slot)) + index

## Tools Used
manual inspection

## Recommendations
Make the following changes:

line 49 add:
```diff
/* Storage Slots */
   #define constant TOTAL_SUPPLY = FREE_STORAGE_POINTER()
   #define constant OWNER_LOCATION = FREE_STORAGE_POINTER()
   #define constant BALANCE_LOCATION = FREE_STORAGE_POINTER()
   #define constant SINGLE_APPROVAL_LOCATION = FREE_STORAGE_POINTER()
+ #define constant HORSE_FED_TIMESTAMP_LOCATION = FREE_STORAGE_POINTER()
```
Modify line 83
```diff
#define macro FEED_HORSE() = takes (0) returns (0) {
    timestamp               // [timestamp]
    0x04 calldataload       // [horseId, timestamp]
-  STORE_ELEMENT(0x00)     // []
+  [HORSE_FED_TIMESTAMP_LOCATION] STORE_ELEMENT_FROM_KEYS(0x00)     // []
    // End execution 
    0x11 timestamp mod      
    endFeed jumpi                
    revert 
    endFeed:
    stop
}
```
Modify line 66
```diff
#define macro GET_HORSE_FED_TIMESTAMP() = takes (0) returns (0) {
    0x04 calldataload       // [horseId]
-  GET_SLOT_FROM_KEY(0x00) // [horseFedTimestamp]
+  [HORSE_FED_TIMESTAMP_LOCATION] LOAD_ELEMENT_FROM_KEYS(0x00) // [horseFedTimestamp]
    sload                   // []

    0x00 mstore             // [] Store value in memory.
    0x20 0x00 return        // Returns what' sin memory
}
```
Modify line 99
```diff
#define macro IS_HAPPY_HORSE() = takes (0) returns (0) {
    0x04 calldataload                   // [horseId]
    LOAD_ELEMENT(0x00)                  // [horseFedTimestamp]
    timestamp                           // [timestamp, horseFedTimestamp]
    dup2 dup2                           // [timestamp, horseFedTimestamp, timestamp, horseFedTimestamp]
    sub                                 // [timestamp - horseFedTimestamp, timestamp, horseFedTimestamp]
-  [HORSE_HAPPY_IF_FED_WITHIN_CONST]   // [HORSE_HAPPY_IF_FED_WITHIN, timestamp - horseFedTimestamp, timestamp, horseFedTimestamp]
+  [HORSE_FED_TIMESTAMP_LOCATION] LOAD_ELEMENT_FROM_KEYS(0x00)   // [HORSE_HAPPY_IF_FED_WITHIN, timestamp - horseFedTimestamp, timestamp, horseFedTimestamp]
    lt                                  // [HORSE_HAPPY_IF_FED_WITHIN < timestamp - horseFedTimestamp, timestamp, horseFedTimestamp]
    start_return_true jumpi             // [timestamp, horseFedTimestamp]
    eq                                  // [timestamp == horseFedTimestamp]
    start_return 
    jump
```
## <a id='M-02'></a>M-02. SafeTransferFrom() Not Implemented in Huff Code

_Submitted by [0x4non](/profile/clk3udrho0004mb08dm6y7y17), [VicRdev](/profile/clpbjipom001uxpj2hued91zg), [jerseyjoewalcott](/profile/clnueldbf000lky08h4g3kjx4), [abhishekthakur](/profile/clkaqh5590000k108p39ktfwl), [Kaiziron](/profile/clk418fns001ejl08ygpwwp08), [n0kto](/profile/clm0jkw6w0000jv08gaj4hof4), [KiteWeb3](/profile/clk9pzw3j000smh08313lj91l), [flokapi2](/profile/clq707ku40000yzp9blkwbqkc), [TorpedopistolIxc41](/profile/clk5ki3ah0000jq08yaeho8g7), [ceseshi](/profile/cln8zm3hz000gmf08kqdt7i5b), [Aitor](/profile/clk44j5cn000wl908r2o0n9w5), [Louis](/profile/clloixi3x0000la08i46r5hc8), [0x18a6](/profile/clrfli8sn00007xk2xgi0xg2l), [EloiManuel](/profile/clq2hor730000b8vl1unuep88). Selected submission by: [Aitor](/profile/clk44j5cn000wl908r2o0n9w5)._      
				
### Relevant GitHub Links
	
https://github.com/Cyfrin/2024-01-horse-store/blob/main/src/HorseStore.huff#L18

## Summary

SafeTransferFrom() works perfectly well in the Solidity code (as it correctly imports the ERC721 Open Zeppelin contract), but in the Huff version the safeTransferFrom() function is not defined. This leads us to a high severity vulnerability:

1. The Huff version was supposed to implement 100% of the Solidity version.
2. The safeTransferFrom function guarantees that the recipient is able to receive the NFT and with this implementation this is not guaranteed if the recipient is a contract.

## Vulnerability Details

As we can see, in the ERC721 definitions:

```
#define function transfer(address,uint256) nonpayable returns ()
#define function transferFrom(address,address,uint256) nonpayable returns ()
```

The definition `transfer(address,uint256)` should be removed, as has no functionality and safeTransferFrom() should be added:

```
#define function safeTransferFrom(address,address,uint256) nonpayable returns ()
```

Check how correctly works in the Solidity version:

```
function test_approveTransferSafeTransfer() external {
        vm.startPrank(peter);
        horseStore.mintHorse();
        horseStore.approve(maryJane, 0);
        vm.stopPrank();
        vm.startPrank(maryJane);
        horseStore.transferFrom(peter, maryJane, 0);
        assertEq(horseStore.ownerOf(0), maryJane);
        horseStore.safeTransferFrom(maryJane, norman, 0, "");
        vm.stopPrank();
        assertEq(horseStore.ownerOf(0), norman);
    }
```

```
➜  2024-01-horse-store git:(main) ✗ forge test --mt test_approveTransferSafeTransfer
[⠒] Compiling...No files changed, compilation skipped
[⠢] Compiling...

Running 1 test for test/HorseStoreSolidity.t.sol:HorseStoreSolidity
[PASS] test_approveTransferSafeTransfer() (gas: 146529)
Test result: ok. 1 passed; 0 failed; 0 skipped; finished in 4.72ms

Ran 1 test suites: 1 tests passed, 0 failed, 0 skipped (1 total tests)
➜  2024-01-horse-store git:(main) ✗
```

But if we move the function to Huff test:

```
function test_huffApproveTransferSafeTransfer() external {
        vm.startPrank(peter);
        horseStore.mintHorse();
        horseStore.approve(maryJane, 0);
        vm.stopPrank();
        vm.startPrank(maryJane);
        horseStore.transferFrom(peter, maryJane, 0);
        assertEq(horseStore.ownerOf(0), maryJane);
        horseStore.safeTransferFrom(maryJane, norman, 0, "");
        vm.stopPrank();
        assertEq(horseStore.ownerOf(0), norman);
    }

```

```
  ├─ [2501] 0x6d2eed85750d316088343D6d5e91ca59eb052768::safeTransferFrom(0x0000000000000000000000000000000000000003, 0x0000000000000000000000000000000000000004, 0, 0x)
    │   └─ ← 0x0000000000000000000000000000000000000000000000000000000000000000
    ├─ [0] VM::stopPrank()
    │   └─ ← ()
    ├─ [594] 0x6d2eed85750d316088343D6d5e91ca59eb052768::ownerOf(0) [staticcall]
    │   └─ ← 0x0000000000000000000000000000000000000003
    ├─ emit log(val: "Error: a == b not satisfied [address]")
    ├─ emit log_named_address(key: "      Left", val: 0x0000000000000000000000000000000000000003)
    ├─ emit log_named_address(key: "     Right", val: 0x0000000000000000000000000000000000000004)
    ├─ [0] VM::store(VM: [0x7109709ECfa91a80626fF3989D68f67F5b1DD12D], 0x6661696c65640000000000000000000000000000000000000000000000000000, 0x0000000000000000000000000000000000000000000000000000000000000001)
    │   └─ ← ()
    └─ ← ()

Test result: FAILED. 0 passed; 1 failed; 0 skipped; finished in 645.98ms

Ran 1 test suites: 0 tests passed, 1 failed, 0 skipped (1 total tests)

Failing tests:
Encountered 1 failing test in test/HorseStoreHuff.t.sol:HorseStoreHuff
[FAIL. Reason: assertion failed] test_huffApproveTransferSafeTransfer() (gas: 101578)
```

## Impact

This is a HIGH vulnerability because the protocol is unable to guarantee that an NFT is correctly delivered to the receiver.

## Tools Used

Foundry

## Recommendations

The function safeTransferFrom() should be implemented in the Huff version. 
## <a id='M-03'></a>M-03. Huff Implementation Not Rejecting Ether Transfers

_Submitted by [0x4non](/profile/clk3udrho0004mb08dm6y7y17), [0xTheBlackPanther](/profile/clnca1ftl0000lf08bfytq099), [n0kto](/profile/clm0jkw6w0000jv08gaj4hof4), [Louis](/profile/clloixi3x0000la08i46r5hc8). Selected submission by: [0x4non](/profile/clk3udrho0004mb08dm6y7y17)._      
				


## Summary
The Horse Store project's Huff rendition of its NFT contract currently lacks the functionality to reject Ether transfers. This omission potentially allows users to inadvertently send Ether to the contract, which may result in the loss of funds, as the contract does not have a mechanism to return or utilize these Ether.

## Vulnerability Details
In its current state, the Huff version of the NFT contract does not contain checks or restrictions against receiving Ether. This could happen in two ways:
1. Direct Ether transfers to the contract address.
2. Executing functions with a non-zero `msg.value`.

Without appropriate safeguards, these actions could lead to Ether being permanently locked within the contract, as there is no function to withdraw or refund the Ether.

## Impact
The potential impact of this vulnerability includes:
- Unintentional loss of funds for users who mistakenly send Ether to the contract.
- Negative user experience and possible reputational damage for the project.
- Increased scrutiny and potential security concerns from the community and stakeholders.

## Tools Used
Manual review

## Recommendations
To mitigate this vulnerability and enhance the security of the contract, is recommended to implement a check in the Huff dispatcher to reject all incoming Ether transfers. This can be achieved by adding a condition that reverts the transaction if `msg.value` is greater than zero.

```diff
diff --git a/src/HorseStore.huff b/src/HorseStore.huff
index 4e17fea..e72ac9d 100644
--- a/src/HorseStore.huff
+++ b/src/HorseStore.huff
@@ -1,6 +1,7 @@
 /* Imports */
 #include "../lib/huffmate/src/data-structures/Hashmap.huff"
 #include "../lib/huffmate/src/utils/CommonErrors.huff"
+#include "../lib/huffmate/src/auth/NonPayable.huff"
 
 /* HorseStore Interface */
 #define function mintHorse() nonpayable returns ()
@@ -142,6 +143,9 @@
 }
 
 #define macro MAIN() = takes (0) returns (0) {
+    // reject any call with value
+    NON_PAYABLE()
+
     // Identify which function is being called.
     0x00 calldataload 0xE0 shr
 ```

## POC
```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";
import {HorseStore} from "../src/HorseStore.sol";

import {IERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

contract MixedHuffTest is Test {
    string public constant NFT_NAME = "HorseStore";
    string public constant NFT_SYMBOL = "HS";
    string public constant horseStoreLocation = "HorseStore";
    HorseStore horseStoreHuff;
    HorseStore horseStoreSol;

    function setUp() public  {
        horseStoreSol = new HorseStore();
        horseStoreHuff = HorseStore(
            HuffDeployer.config().with_args(bytes.concat(abi.encode(NFT_NAME), abi.encode(NFT_SYMBOL))).deploy(
                horseStoreLocation
            )
        );
    }

    function testRejectEther() public {
        vm.expectRevert();
        payable(address(horseStoreSol)).transfer(1 ether);

        (bool success, ) = address(horseStoreSol).call{value: 1 ether}("");
        assertFalse(success, "should fail");

        // lets try with huff version
        vm.expectRevert();
        payable(address(horseStoreHuff)).transfer(1 ether);

        (success, ) = address(horseStoreHuff).call{value: 1 ether}("");
        assertFalse(success, "should fail");
    }


    function testMintWithValue() public {
        address user = makeAddr("user");
        deal(user, 1 ether);
        vm.warp(10);
        vm.roll(10);
        vm.startPrank(user);
       
        (bool success, ) = address(horseStoreSol).call{value: 1 ether}(abi.encodeWithSignature("mintHorse()"));
        assertTrue(!success, "mintHorse() should fail");
        
        // lets try the same with huff version

        /// sending ether should revert
        (success, ) = address(horseStoreHuff).call{value: 1 ether}(abi.encodeWithSignature("mintHorse()"));
        assertTrue(!success, "mintHorse() should fail");

        vm.stopPrank();
    }
}
```

# Low Risk Findings

## <a id='L-01'></a>L-01. It is possible to feed a horse with an invalid token ID, i.e., an ID that does not correspond to any minted horse NFT

_Submitted by [Kaiziron](/profile/clk418fns001ejl08ygpwwp08), [Poor4ever](/profile/clqed8yto0000xs7svdgqz0cs), [0xTheBlackPanther](/profile/clnca1ftl0000lf08bfytq099), [0xVinylDavyl](/profile/clkeaiat40000l309ruc9obdh), [0x4non](/profile/clk3udrho0004mb08dm6y7y17), [eLSeR17](/profile/cloa521640004k008nepn5h9o), [0x18a6](/profile/clrfli8sn00007xk2xgi0xg2l), [n0kto](/profile/clm0jkw6w0000jv08gaj4hof4), [KiteWeb3](/profile/clk9pzw3j000smh08313lj91l), [shikhar229169](/profile/clk3yh639002emf08ywok1hzf), [flokapi2](/profile/clq707ku40000yzp9blkwbqkc), [stefanlatinovic](/profile/clpbb43ek0014aevzt4shbvx2), [Pelz](/profile/clokuwofs000yih08n1oqrf6d), [TorpedopistolIxc41](/profile/clk5ki3ah0000jq08yaeho8g7), [thenpuli](/profile/clrhsnkp80059kiqliakiv8r7), [ceseshi](/profile/cln8zm3hz000gmf08kqdt7i5b), [CloudTact](/profile/clriba5t60000szv0zi8a6o4c), [Yovchev](/profile/clri0w7sc001idl0rzvadvlih), [Bube](/profile/clk3y8e9u000cjq08uw5phym7), [ducky7](/profile/clk70u7i6000yl508yjlhkrkv), [mircha](/profile/clptqoe7m000uny9kfivcensf), [paprikrumplikas](/profile/clrj23lnp006g14oum8qxro25), [EloiManuel](/profile/clq2hor730000b8vl1unuep88). Selected submission by: [stefanlatinovic](/profile/clpbb43ek0014aevzt4shbvx2)._      
				
### Relevant GitHub Links
	
https://github.com/Cyfrin/2024-01-horse-store/blob/main/src/HorseStore.sol#L32

https://github.com/Cyfrin/2024-01-horse-store/blob/main/src/HorseStore.huff#L80

## Summary

It is possible to feed a horse whose token has not been minted yet or is burned.

## Vulnerability Details

It is possible to feed a horse with an ID that has not yet been minted and subsequently mint a horse with the same ID. This can lead to incorrect results when verifying the horse's happiness, as the verification process may indicate that the horse is happy even when it shouldn't be.

## Impact

Feeding a non-minted horse may cause false happiness verification results post-minting.

## Proof of Concept (PoC)

Add the next test in `Base_Test.t.sol`.

```javascript
function test_FeedingNotMintedHorseIsAllowed(uint256 horseId, uint256 feedAt) public {
    vm.warp(feedAt);
    horseStore.feedHorse(horseId); // feeding a horse that is not minted is allowed

    assertEq(horseStore.horseIdToFedTimeStamp(horseId), feedAt);
}
```

Run a test with `forge test --mt test_FeedingNotMintedHorseIsAllowed`.

## Tools Used

- Foundry

## Recommendations

To properly feed a horse, it's important to verify the validity of the token ID.

Recommended changes in `HorseStore.sol::feedHorse()` function:

```diff
function feedHorse(uint256 horseId) external {
+    _requireOwned(horseId); // reverts if the token with `horseId` has not been minted yet, or if it has been burned
    horseIdToFedTimeStamp[horseId] = block.timestamp;
}
```

Add the next test to `HorseStoreSolidity.t.sol`.

```javascript
import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

function test_FeedingHorseBeforeMintingItIsNotAllowed(address randomOwner) public {
    vm.assume(randomOwner != address(0));
    vm.assume(!_isContract(randomOwner));

    uint256 horseId = horseStore.totalSupply();
    vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, horseId));
    horseStore.feedHorse(horseId);
}
```

Run a test with `forge test --mt test_FeedingHorseBeforeMintingItIsNotAllowed`.

Recommended changes to `HorseStore.huff::FEED_HORSE()` function:

```diff
#define macro FEED_HORSE() = takes (0) returns (0) {
    timestamp               // [timestamp]
    0x04 calldataload       // [horseId, timestamp]
+    dup1                                           // [horseId, horseId, timestamp]
+    // revert if owner is zero address/not minted
+    [OWNER_LOCATION] LOAD_ELEMENT_FROM_KEYS(0x00)  // [owner, horseId, timestamp]
+    dup1 continue jumpi
+    NOT_MINTED(0x00)
+    continue:
+    dup3 dup3                                      // [horseId, timestamp, owner, horseId, timestamp]
+    STORE_ELEMENT(0x00)                            // [owner, horseId, timestamp]

    // End execution 
    0x11 timestamp mod      
    endFeed jumpi                
    revert 
    endFeed:
    stop
}
```

Add the next test to `HorseStoreHuff.t.sol`.

```javascript
function test_FeedingHorseBeforeMintingItIsNotAllowed(address randomOwner) public {
    vm.assume(randomOwner != address(0));
    vm.assume(!_isContract(randomOwner));

    uint256 horseId = horseStore.totalSupply();
    vm.expectRevert("NOT_MINTED");
    horseStore.feedHorse(horseId);
}
```

Run a test with `forge test --mt test_FeedingHorseBeforeMintingItIsNotAllowed`.
## <a id='L-02'></a>L-02. Unsupported Opcode PUSH0 in Solidity 0.8.20 for Deployment on Arbitrum Chain

_Submitted by [0xTheBlackPanther](/profile/clnca1ftl0000lf08bfytq099), [VicRdev](/profile/clpbjipom001uxpj2hued91zg), [tamoghna](/profile/clkcqn89o000imk08sam8bb8a), [abhishekthakur](/profile/clkaqh5590000k108p39ktfwl), [Kaiziron](/profile/clk418fns001ejl08ygpwwp08), [KiteWeb3](/profile/clk9pzw3j000smh08313lj91l), [n0kto](/profile/clm0jkw6w0000jv08gaj4hof4), [naman1729](/profile/clk41lnhu005wla08y1k4zaom), [EloiManuel](/profile/clq2hor730000b8vl1unuep88), [TorpedopistolIxc41](/profile/clk5ki3ah0000jq08yaeho8g7), [wafflemakr](/profile/clmm1t0210000mi08hak3ir5r), [Bube](/profile/clk3y8e9u000cjq08uw5phym7), [paprikrumplikas](/profile/clrj23lnp006g14oum8qxro25). Selected submission by: [EloiManuel](/profile/clq2hor730000b8vl1unuep88)._      
				
### Relevant GitHub Links
	
https://github.com/Cyfrin/2024-01-horse-store/blob/8255173c9340c12501881c9ecdd4175ff7350f5d/src/HorseStore.sol#L2

https://github.com/Cyfrin/2024-01-horse-store/blob/8255173c9340c12501881c9ecdd4175ff7350f5d/src/IHorseStore.sol#L2

## Summary
The contract is set to be deployed on Arbitrum chain but the solidity version `0.8.20` has opcode `PUSH0` which is not yet supported on Arbitrum, thus it cannot be deployed.

## Vulnerability Details
The concern is regarding the usage of solc version 0.8.20 in the smart contract. The version exhibits the `PUSH0` opcode and is currently not supported across all EVM chains. The contract is required to be deployed on Arbitrum chain, but it doesn't support the `PUSH0` opcode. The vulnerability here is that the contracts compiled with solidity versions above `0.8.19` will not be able to deploy, or even if they are able to deploy then may not function properly and may lead to other consequences.

It is important to mention that this report is valid as of 18/01/2024 and Arbitrum is expected tu fully support `PUSH0` (Shanghai) by the end of this month (27th of January).

References:
 - Official Arbitrum docs about Solidity support: https://docs.arbitrum.io/for-devs/concepts/differences-between-arbitrum-ethereum/solidity-support
 - Tweet about full `PUSH0` support on Arbitrum: ohttps://x.com/ArbitrumDevs/status/1745198708155715976?s=20
 - Similar finding from a past first flight: https://www.codehawks.com/submissions/clq5cx9x60001kd8vrc01dirq/28
 - Security Analysis of Smart Contract Migration from Ethereum to Arbitrum: https://arxiv.org/abs/2307.14773

## Impact
The impact of using the solidity version `0.8.20` is that it comes with the `PUSH0` opcode and this opcode is not supported on Arbitrum causing the smart contract to malfunction and the contract may not execute correctly.

## Tools Used
Manual review.

## Recommendations
`PUSH0` opcode comes with `0.8.20` and higher versions, therefore switching to `0.8.19` will make the smart contract fully compatible to be deployed on Arbitrum chain.

- HorseStore.sol
- IHorseStore.sol

```diff
    // SPDX-License-Identifier: MIT
-    pragma solidity 0.8.20;
+    pragma solidity 0.8.20;
```

## <a id='L-03'></a>L-03. The same `horseId` can be happy on `Arbitrum` but unhappy on `Ethereum`

_Submitted by [n0kto](/profile/clm0jkw6w0000jv08gaj4hof4), [Bube](/profile/clk3y8e9u000cjq08uw5phym7). Selected submission by: [Bube](/profile/clk3y8e9u000cjq08uw5phym7)._      
				
### Relevant GitHub Links
	
https://github.com/Cyfrin/2024-01-horse-store/blob/8255173c9340c12501881c9ecdd4175ff7350f5d/src/HorseStore.sol#L42

## Summary

At the same time the same horse can be `happy` on `Arbitrum` and `unhappy` on `Ethereum` due to the way in which `block.timestamp` works on `Arbitrum`.

## Vulnerability Details

The project will be deployed on `Arbitrum` and `Ethereum`. Also, the `HorseStore::isHappyHorse` relies on `block.timestamp` to check the time when the horse was last fed. But the `block.timestamp` on `Arbitrum` works differently.

In the Arbitrum documentation is said:

```
Block timestamps on Arbitrum are not linked to the timestamp of the L1 block. They are updated every L2 block based on the sequencer's clock. These timestamps must follow these two rules:

- Must be always equal or greater than the previous L2 block timestamp
- Must fall within the established boundaries (24 hours earlier than the current time or 1 hour in the future). More on this below.

Furthermore, for transactions that are force-included from L1 (bypassing the sequencer), the block timestamp will be equal to either the L1 timestamp when the transaction was put in the delayed inbox on L1 (not when it was force-included), or the L2 timestamp of the previous L2 block, whichever of the two timestamps is greater.

```

https://docs.arbitrum.io/for-devs/concepts/differences-between-arbitrum-ethereum/block-numbers-and-time#block-timestamps-arbitrum-vs-ethereum


## Impact

Due to the way in which the `block.timestamp` works on `Arbitrum` it is possible the following scenario:

Bob feeds the horse with Id `1` at 15 hour on 18 January. On the next day (19 January) at 17 hour Alice checks if the horse with Id `1` is happy. The contract is deployed on Arbitrum and the `block.timestamp` can return value that is 24 hours earlier than the current time. So, the `HorseStore::isHappyHorse` function returns `true`, because for the function is 17 hour on 18 January and the horse was fed 2 hours ago. But actually the horse was fed 26 hours ago and it is unhappy. On the Ethereum the horse will be unhappy.


## Tools Used
Manual Review

## Recommendations
Ensure that the return value of the `HorseStore::isHappyHorse` function is reliable on every chain that the project is deployed.




