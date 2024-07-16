// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";
import {console} from "forge-std/console.sol";
error Fundme_NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 constant MINIMUM_PRICE = 5e18;
    address internal immutable i_owner;
    AggregatorV3Interface s_pricefeed;

    constructor(address pricefeed) {
        i_owner = msg.sender;
        s_pricefeed = AggregatorV3Interface(pricefeed);
    }

    modifier onlyOwner() {
        //require(msg.sender == owner,'must be the owner');
        if (msg.sender != i_owner) {
            revert Fundme_NotOwner();
        }
        _;
    }

    function getMinimumUsd() public pure returns (uint256) {
        return MINIMUM_PRICE;
    }

    address[] s_funders;
    mapping(address => uint256) private s_addressToAmount;

    function fund() public payable {
        require(
            msg.value.getpriceConvert(s_pricefeed) >= MINIMUM_PRICE,
            "not sufficient enough"
        );
        s_funders.push(msg.sender);
        s_addressToAmount[msg.sender] += msg.value;
    }

function cheapWithdraw() public onlyOwner {
    uint256 funderLength = s_funders.length;
        for (
            uint256 funderIndex = 0;
            funderIndex < funderLength;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmount[funder] = 0;
        }
        s_funders = new address[](0);

        uint256 ownerBalance = address(this).balance;
        
        (bool callSuccess, ) = payable(msg.sender).call{value: ownerBalance}(
            ""
        );
        require(callSuccess, "transaction failed");
        
    }


    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmount[funder] = 0;
        }
        s_funders = new address[](0);

        uint256 balanceBefore = address(this).balance;
        console.log("balance before:", balanceBefore);
        (bool callSuccess, ) = payable(msg.sender).call{value: balanceBefore}(
            ""
        );
        require(callSuccess, "transaction failed");
        uint256 balanceAfter = address(this).balance;
        console.log("balance after:", balanceAfter);
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getVersion() public view returns (uint256) {
        return s_pricefeed.version();
    }

    function getAddressToAmount(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmount[fundingAddress];
    }

    function getfunders(uint256 index) external view returns (address) {
        return s_funders[index];
    }
}
