// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract IntroInvariant {
    bool public flag;

    function func_1() external {}

    function func_2() external {}

    function func_3() external {}

    function func_4() external {}

    function func_5() external {
        flag = true;
    }
}

import "forge-std/Test.sol";

contract IntroInvariantTest is Test {
    IntroInvariant private target;

    function setUp() public {
        target = new IntroInvariant();
    }

    function invariant_flag_is_always_false() public view {
        assertEq(target.flag(), false);
    }
}
