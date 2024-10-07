// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {stdStorage, StdStorage} from "forge-std/Test.sol";
import {Handler} from "./Handler.sol";

contract FundMeTest is Test {
    using stdStorage for StdStorage;
    FundMe targetFundMe;
    Handler[] public handlers;
    address USER = makeAddr("user");
    uint256 SEND_VALUE = 10e18;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        targetFundMe = deployFundMe.run();
        for (uint i = 0; i < 5; i++) {
            handlers.push(new Handler(payable(targetFundMe)));
            vm.deal(address(handlers[i]), SEND_VALUE);
        }
    }

    function testFuzz(uint96 amount) public {
        vm.assume(amount > 0.01 ether);
        vm.deal(USER, amount);
        vm.prank(USER);
        targetFundMe.fund{value: amount}();
        uint256 amountFunded = targetFundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, amount);
    }

    mapping(address => bool) seen;

    function invariant_contract_balance_equals_sum_of_funded() public {
        uint256 totalFunded = 0;
        uint256 fundersLength = targetFundMe.getFunderLength();
        for (uint256 i = 0; i < fundersLength; i++) {
            address funder = targetFundMe.getFunder(i);
            if (!seen[funder]) {
                uint256 fundedAmount = targetFundMe.getAddressToAmountFunded(
                    funder
                );
                totalFunded += fundedAmount;
                seen[funder] = true;
            }
        }
        assertEq(address(targetFundMe).balance, totalFunded);
    }

    function testFuzz_only_owner_can_withdraw(address caller) public {
        // Exclude the owner from the fuzzed addresses
        vm.assume(caller != targetFundMe.getOwner());

        // Start prank as the fuzzed caller
        vm.prank(caller);

        // Expect the FundMe__NotOwner error to be thrown
        vm.expectRevert(FundMe.FundMe__NotOwner.selector);

        // Attempt to withdraw funds
        targetFundMe.withdraw();
    }

    function invariant_reset_after_withdrawal() public {
        if (address(targetFundMe).balance == 0) {
            uint256 fundersLength = targetFundMe.getFunderLength();
            for (uint256 i = 0; i < fundersLength; i++) {
                address funder = targetFundMe.getFunder(i);
                uint256 fundedAmount = targetFundMe.getAddressToAmountFunded(
                    funder
                );
                assertEq(fundedAmount, 0);
            }
        }
    }
}

//Fuzz Vs Invariant testing
// fuzz testing a random input is passed and then that function is tested
//invariant testing a sequence of random numbers and functions are called
