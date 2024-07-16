// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SimpleStorage {
    uint256 favNumber;

    struct People {
        string name;
        uint256 number;
    }

    mapping(string => uint256) public PeopleArchive;

    People[] public ListOfPeople;

    function updateNumber(uint256 num) public {
        favNumber = num;
    }

    function viewNumber() public view returns (uint256) {
        return favNumber;
    }

    function AddPeople(string memory _name, uint256 _number) public {
        ListOfPeople.push(People(_name, _number));
        PeopleArchive[_name] = _number;
    }
}
