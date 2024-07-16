// SPDX-License-Identifier:MIT
pragma solidity ^0.8.19;
import{Script} from 'forge-std/Script.sol';
import {MockV3Aggregator} from '../test/mocks/MockV3Aggregator.sol';
contract HelperConfig is Script{
   NetworkConfig  public activeAddress;
   uint8 public constant DECIMALS = 8;
   int256 public constant INITIAL_ANSWER = 2000e8;
   struct  NetworkConfig {
     address pricefeed;
   }
   constructor(){
    if(block.chainid == 11155111){
        activeAddress =  getSepoliaEthConfig();
    }else{
        activeAddress = getAnvilEthConfig();
    }
   }

    function getSepoliaEthConfig() public pure returns(NetworkConfig memory){
 NetworkConfig memory sepoliaEth = NetworkConfig({
    pricefeed:  0x694AA1769357215DE4FAC081bf1f309aDC325306
 });
 return sepoliaEth;
    }

    function getAnvilEthConfig()public  returns(NetworkConfig memory){
         if (activeAddress.pricefeed != address(0)){
            return activeAddress;
         }
         
         vm.startBroadcast();
        MockV3Aggregator mockv3aggregator = new MockV3Aggregator(DECIMALS,INITIAL_ANSWER);
         vm.stopBroadcast();
        NetworkConfig  memory anvilEth = NetworkConfig({
            pricefeed: address(mockv3aggregator)
        });
        return anvilEth;

    }
}