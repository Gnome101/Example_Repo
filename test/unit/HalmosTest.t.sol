//S// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {SymTest} from "lib/halmos-cheatcodes/src/SymTest.sol";

contract HalmosTest is Test, SymTest {
    FundMe fundMe;
    address USER = makeAddr("user");

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function check_fund() public {
        // Create a symbolic address and amount
        uint256 amount = svm.createUint256("amount");
        // Explicitly set funder's balance to be larger than the minimum funding amount
        vm.deal(USER, amount); // Deal the funder 10 ETH

        // Remove assumption for funder balance and just fund using the symbolic amount
        vm.prank(USER); // Set the funder as the caller
        fundMe.fund{value: amount}(); // Call fund with the symbolic amount if within bounds

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);

        assertEq(amountFunded, amount);
    }
}
