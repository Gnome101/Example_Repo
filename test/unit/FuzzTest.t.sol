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
    Handler handler;
    address USER = makeAddr("user");
    uint256 SEND_VALUE = 10e18;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        targetFundMe = deployFundMe.run();
        handler = new Handler(payable(targetFundMe));
        targetContract(address(handler));
        bytes4[] memory selectors = new bytes4[](1);
        selectors[0] = Handler.fundContract.selector;

        targetSelector(
            FuzzSelector({addr: address(handler), selectors: selectors})
        );

        vm.deal(address(handler), SEND_VALUE);
    }

    function testFuzz(uint96 amount) public {
        vm.assume(amount > 0.01 ether);
        vm.deal(USER, amount);
        vm.prank(USER);
        targetFundMe.fund{value: amount}();
        uint256 amountFunded = targetFundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, amount);
    }

    // function invariant_amount() public view {
    //     uint256 amountFunded = targetFundMe.getAddressToAmountFunded(
    //         address(handler)
    //     );

    //     assertEq(amountFunded == 0, true);
    // }
}

//Fuzz Vs Invariant testing
// fuzz testing a random input is passed and then that function is tested
//invariant testing a sequence of random numbers and functions are called
