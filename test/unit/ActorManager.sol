// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {CommonBase} from "forge-std/Base.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {StdUtils} from "forge-std/StdUtils.sol";
import {FundMe} from "../../src/FundMe.sol";
import {Handler} from "./Handler.sol";

contract ActorManager is CommonBase, StdCheats, StdUtils {
    Handler[] public handlers;

    constructor(Handler[] memory _handlers) {
        handlers = _handlers;
    }

    function fundContract(uint256 i, uint256 amount) public {
        i = bound(i, 0, handlers.length - 1);
        handlers[i].fundContract(amount);
    }

    function withdrawContract(uint256 i) public {
        i = bound(i, 0, handlers.length - 1);
        handlers[i].withdrawContract();
    }
}
