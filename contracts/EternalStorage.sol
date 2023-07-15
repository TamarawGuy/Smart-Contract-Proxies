// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

contract EternalStorage {
    mapping(bytes32 => uint256) internal uintStorage;
    mapping(bytes32 => bool) internal boolStorage;

    function getUintValue(bytes32 _record) public view returns (uint256) {
        return uintStorage[_record];
    }

    function setUintValue(bytes32 _record, uint256 _value) public {
        uintStorage[_record] = _value;
    }

    function getBoolValue(bytes32 _record) public view returns (bool) {
        return boolStorage[_record];
    }

    function setBoolValue(bytes32 _record, bool _value) public {
        boolStorage[_record] = _value;
    }
}

library ballotLib {
    function getNumberOfVotes(
        address _eternalStorage
    ) public view returns (uint256) {
        return EternalStorage(_eternalStorage).getUintValue(keccak256("votes"));
    }

    function setVoteCount(address _eternalStorage, uint _voteCount) public {
        EternalStorage(_eternalStorage).setUintValue(
            keccak256("votes"),
            _voteCount
        );
    }

    function getUserHasVoted(
        address _eternalStorage
    ) public view returns (bool) {
        return
            EternalStorage(_eternalStorage).getBoolValue(
                keccak256(abi.encodePacked("voted", msg.sender))
            );
    }

    function setUserHasVoted(address _eternalStorage) public {
        EternalStorage(_eternalStorage).setBoolValue(
            keccak256(abi.encodePacked("voted", msg.sender)),
            true
        );
    }
}

contract Ballot {
    using ballotLib for address;
    address eternalStorage;

    constructor(address _eternalStorage) {
        eternalStorage = _eternalStorage;
    }

    function getNumberOfVotes() public view returns (uint256) {
        return eternalStorage.getNumberOfVotes();
    }

    function vote() public {
        require(eternalStorage.getUserHasVoted() == false, "Already voted");
        eternalStorage.setUserHasVoted();
        eternalStorage.setVoteCount(eternalStorage.getNumberOfVotes() + 1);
    }
}
