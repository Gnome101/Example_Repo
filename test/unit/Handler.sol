// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {CommonBase} from "forge-std/Base.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {StdUtils} from "forge-std/StdUtils.sol";
import {FundMe} from "../../src/FundMe.sol";

contract Handler is CommonBase, StdCheats, StdUtils {
    FundMe targetFundMe;

    constructor(address payable _targetFundMe) {
        targetFundMe = FundMe(_targetFundMe);
    }

    function fundContract(uint256 amount) public {
        amount = bound(amount, 0, address(this).balance);
        targetFundMe.fund{value: amount}();
    }

    function withdrawContract() public {
        targetFundMe.withdraw();
    }
}
