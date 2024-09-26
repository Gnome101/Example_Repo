//S// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testMinimumDollarIsFive() public view {
        console.log("hello");
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        console.log(fundMe.i_owner(), msg.sender);
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedversionIsAccurte() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFudnFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund(); // send 0 eth
    }

    function testFundUpdatesFundedDataStricture() public {
        uint256 SEND_VALUE = 10e18;

        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}(); // send 10 eth
        uint256 amountFunded = fundMe.getAddressToAmountFunded(address(this));
        assertEq(amountFunded, SEND_VALUE);
    }
}
