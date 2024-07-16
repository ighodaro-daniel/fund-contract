// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test,console} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe,WithdrawFundMe} from '../../script/Interaction.s.sol';
contract InteractionTest is Test {
    FundMe fundme;
    uint256 public constant funderAmount = 10 ether;
    uint256 public constant GASPRICE = 1;
    address USER = makeAddr("user");

    function setUp() external {
        DeployFundMe deployFundme = new DeployFundMe();
        fundme = deployFundme.run();
        vm.deal(USER, 10 ether);
    }

    function testUserCanFund() public{
        FundFundMe userFunding = new FundFundMe();
       vm.prank(USER);
       
        userFunding.fundFundMe{value: 0.05 ether}(address(fundme));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundme));

        console.log(address(fundme).balance);
        assertEq(address(fundme).balance,0);
       
    }



}
