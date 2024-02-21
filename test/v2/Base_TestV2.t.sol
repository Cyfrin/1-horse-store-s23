// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {HorseStore} from "../../src/horseStoreV2/HorseStore.sol";
import {Test, console2} from "forge-std/Test.sol";

abstract contract Base_TestV2 is Test {
    HorseStore horseStore;
    address user = makeAddr("user");
    string public constant NFT_NAME = "HorseStore";
    string public constant NFT_SYMBOL = "HS";

    function setUp() public virtual {
        horseStore = new HorseStore();
    }

    function testName() public {
        string memory name = horseStore.name();
        assertEq(name, NFT_NAME);
    }

    function testMintingHorseAssignsOwner(address randomOwner) public {
        vm.assume(randomOwner != address(0));
        vm.assume(!_isContract(randomOwner));

        uint256 horseId = horseStore.totalSupply();
        vm.prank(randomOwner);
        horseStore.mintHorse();
        assertEq(horseStore.ownerOf(horseId), randomOwner);
    }

    function testFeedingHorseUpdatesTimestamps() public {
        uint256 horseId = horseStore.totalSupply();
        vm.warp(10);
        vm.roll(10);
        vm.prank(user);
        horseStore.mintHorse();

        uint256 lastFedTimeStamp = block.timestamp;
        horseStore.feedHorse(horseId);

        assertEq(horseStore.horseIdToFedTimeStamp(horseId), lastFedTimeStamp);
    }

    function testFeedingMakesHappyHorse() public {
        uint256 horseId = horseStore.totalSupply();
        vm.warp(horseStore.HORSE_HAPPY_IF_FED_WITHIN());
        vm.roll(horseStore.HORSE_HAPPY_IF_FED_WITHIN());
        vm.prank(user);
        horseStore.mintHorse();
        horseStore.feedHorse(horseId);
        assertEq(horseStore.isHappyHorse(horseId), true);
    }

    function testNotFeedingMakesUnhappyHorse() public {
        uint256 horseId = horseStore.totalSupply();
        vm.warp(horseStore.HORSE_HAPPY_IF_FED_WITHIN());
        vm.roll(horseStore.HORSE_HAPPY_IF_FED_WITHIN());
        vm.prank(user);
        horseStore.mintHorse();
        assertEq(horseStore.isHappyHorse(horseId), false);
    }

    function testHorseIsHappyIfFedWithinPast24Hours(uint256 horseId, uint256 checkAt) public {
        uint256 fedAt = horseStore.HORSE_HAPPY_IF_FED_WITHIN();
        checkAt = bound(checkAt, fedAt + 1 seconds, fedAt + horseStore.HORSE_HAPPY_IF_FED_WITHIN() - 1 seconds);
        vm.warp(fedAt);
        horseStore.feedHorse(horseId);

        vm.warp(checkAt);
        assertEq(horseStore.isHappyHorse(horseId), true);
    }

    /*//////////////////////////////////////////////////////////////
                            HELPER FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    // Borrowed from an Old Openzeppelin codebase
    function _isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}
