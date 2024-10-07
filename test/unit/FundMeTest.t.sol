//S// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {stdStorage, StdStorage} from "forge-std/Test.sol";

contract FundMeTest is Test {
    using stdStorage for StdStorage;
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 SEND_VALUE = 10e18;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, 10e18);
        vm.deal(USER, SEND_VALUE);
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        console.log(fundMe.getOwner(), msg.sender);
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedversionIsAccurte() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFudnFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund(); // send 0 eth
    }

    function testFundUpdatesFundedDataStucture() public {
        // stdstore
        // .target(address(fundMe)) // Target the FundMe contract
        //     .sig(fundMe.getAddressToAmountFunded.selector)
        //     .with_key(USER)
        //     .checked_write(12); // Specify the user address as the key for the mapping

        vm.prank(USER);

        fundMe.fund{value: SEND_VALUE}(); // send 10 eth
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(USER, funder);
    }

    modifier funded() {
        vm.startPrank(USER);
        fundMe.fund{value: SEND_VALUE};
        vm.stopPrank();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMutipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //vm.prank new address
            console.log("Funder", i);
            hoax(address(i), SEND_VALUE);
            console.log("Hoaxing", i);
            fundMe.fund{value: SEND_VALUE}();

            //vm.deal new address
            //fund the fundme
        }
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.txGasPrice(GAS_PRICE);
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        //Assert
        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }

    function testWithdrawFromMutipleFundersCheaper() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //vm.prank new address
            console.log("Funder", i);
            hoax(address(i), SEND_VALUE);
            console.log("Hoaxing", i);
            fundMe.fund{value: SEND_VALUE}();

            //vm.deal new address
            //fund the fundme
        }
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.txGasPrice(GAS_PRICE);
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        //Assert
        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }
}
