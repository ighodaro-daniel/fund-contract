// SPDX-License-Identifier:MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {FundMe} from "../src/FundMe.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPrice = helperConfig.activeAddress();
        vm.startBroadcast();
        FundMe fundme = new FundMe(ethUsdPrice);
        vm.stopBroadcast();
        return fundme;
    }
}
