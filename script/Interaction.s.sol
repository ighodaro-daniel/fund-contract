//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {FundMe} from "../src/FundMe.sol";
import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.05 ether;
    
    function fundFundMe(address getMostRecentDeployed) public payable {
        
        
        FundMe(payable(getMostRecentDeployed)).fund{value: SEND_VALUE}();
        
    }

    function run() external {
        address getMostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        fundFundMe(getMostRecentlyDeployed);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    

    function withdrawFundMe(address getMostRecentDeployed) public {
        vm.startBroadcast();
        FundMe(payable(getMostRecentDeployed)).cheapWithdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address getMostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        
        WithdrawFundMe(getMostRecentlyDeployed);
    
    }
}
