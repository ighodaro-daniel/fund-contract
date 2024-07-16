// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundme;
    uint256 public constant funderAmount = 10e18;
    uint256 public constant GASPRICE = 1;
    address USER = makeAddr("user");

    function setUp() external {
        DeployFundMe deployFundme = new DeployFundMe();
        fundme = deployFundme.run();
        vm.deal(USER, 10 ether);
    }

    function testMinimumUsd() public view {
        assertEq(fundme.getMinimumUsd(), 5e18);
    }

    function testOwner() public view {
        console.log(fundme.getOwner());
        assertEq(fundme.getOwner(), msg.sender);
    }

    function testVersionIsAccurate() public view {
        uint256 version = fundme.getVersion();

        assertEq(version, 4);
    }

    function testFailForNotEnoughEthUsd() public {
        //vm.expectRevert();

        fundme.fund{value: 0}();
    }

    function testUpdatefundAccount() public {
        //uint256 snapshot = vm.snapshot();
        vm.prank(USER);
        fundme.fund{value: funderAmount}();
        uint256 getSenderFund = fundme.getAddressToAmount(USER);
        //vm.revertTo(snapshot);
        assertEq(getSenderFund, funderAmount);
    }

    function testAddedFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundme.fund{value: funderAmount}();
        address funder = fundme.getfunders(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundme.fund{value: funderAmount}();
        _;
    }

    function onlyOwnerCanWitdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundme.withdraw();
    }

    function testOnwerWithdrawBalanceCheaper() public funded {
        uint256 startOwnerBalance = fundme.getOwner().balance;
        uint256 startFundBalance = address(fundme).balance;
        vm.prank(fundme.getOwner());

        fundme.cheapWithdraw();
        uint256 endOwnerBalance = fundme.getOwner().balance;
        uint256 endFundBalance = address(fundme).balance;
        console.log("owner balance after claim:", endOwnerBalance);
        assertEq(endFundBalance, 0);
        assertEq(startFundBalance + startOwnerBalance, endOwnerBalance);
    }

    function testOnwerWithdrawBalance() public funded {
        uint256 startOwnerBalance = fundme.getOwner().balance;
        uint256 startFundBalance = address(fundme).balance;
        vm.prank(fundme.getOwner());

        fundme.withdraw();
        uint256 endOwnerBalance = fundme.getOwner().balance;
        uint256 endFundBalance = address(fundme).balance;
        console.log("owner balance after claim:", endOwnerBalance);
        assertEq(endFundBalance, 0);
        assertEq(startFundBalance + startOwnerBalance, endOwnerBalance);
    }

    function testMultipleWithdraw() public {
        uint160 numberOfWalletAddresses = 10;
        uint160 startPoint = 1;
        for (uint160 i = startPoint; i < numberOfWalletAddresses; i++) {
            hoax(address(i), 10 ether);
            fundme.fund{value: 10 ether}();
        }

        uint256 startOwnerBalance = fundme.getOwner().balance;
        uint256 startFundBalance = address(fundme).balance;
        console.log("initial owner balance:", startOwnerBalance);
        console.log("balance before withdrawal:", startFundBalance);

        uint256 gasStart = gasleft();
        vm.txGasPrice(GASPRICE);
        vm.startPrank(fundme.getOwner());
        fundme.withdraw();
        vm.stopPrank();

        uint256 gasEnd = gasleft();
        uint256 gasSpent = (gasEnd - gasStart) * tx.gasprice;

        console.log("gas spent:", gasSpent);
        uint256 endFundBalance = address(fundme).balance;
        console.log("address full fund:", endFundBalance);
        console.log("final balance:", fundme.getOwner().balance);
        assertEq(endFundBalance, 0);
    }
}
