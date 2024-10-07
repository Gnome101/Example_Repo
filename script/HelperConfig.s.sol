//S// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {MockV3Aggregator} from "../test/Mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;
    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaETHConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilConfig();
        }
    }

    function getSepoliaETHConfig() public pure returns (NetworkConfig memory) {
        //price feed addy
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    uint8 public constant DECIMALS = 8;
    int256 public constant INITAL_PRICE = 2000e8;

    function getOrCreateAnvilConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        // vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITAL_PRICE
        );
        // vm.stopBroadcast();

        NetworkConfig memory anvilConifg = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConifg;
    }
}
