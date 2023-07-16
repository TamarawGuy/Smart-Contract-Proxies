// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.18;

contract ProxyStorage {
    address public otherContractAddress;

    function setOtherAddressStorage(address _otherContractAddress) public {
        otherContractAddress = _otherContractAddress;
    }
}

contract NotLostStorage is ProxyStorage {
    address public myAddress;
    uint256 public muUint;

    function setAddress(address _address) public {
        myAddress = _address;
    }

    function setUint(uint256 _uint) public {
        muUint = _uint;
    }
}

contract ProxyNoMoreClash is ProxyStorage {
    constructor(address _otherContract) {
        setOtherAddress(_otherContract);
    }

    function setOtherAddress(address _otherContract) public {
        super.setOtherAddressStorage(_otherContract);
    }

    fallback() external payable {
        address _impl = otherContractAddress;

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
            }
        }
    }
}
