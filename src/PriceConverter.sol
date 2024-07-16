// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        
        // zksync address =   0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF

        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price * 10000000000);
    }

    function getpriceConvert(uint256 amount,AggregatorV3Interface priceFeed) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 convertedPrice = (ethPrice * amount) / 1000000000000000000;
        return convertedPrice;
    }
}
