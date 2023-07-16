// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.18;

abstract contract Upgradeable {
    mapping(bytes4 => uint32) internal _sizes;
    address _dest;

    function initialize() public virtual;

    function replace(address target) public {
        _dest = target;
        target.delegatecall(
            abi.encodeWithSelector(bytes4(keccak256("initialize()")))
        );
    }
}

contract Dispatcher is Upgradeable {
    constructor(address target) {
        replace(target);
    }

    function initialize() public override {
        assert(0);
    }

    fallback() external {
        bytes4 sig;
        assembly {
            sig := calldataload(0)
        }
        uint len = _sizes[sig];
        address target = _dest;

        assembly {
            calldatacopy(0x0, 0x0, calldatasize())
            let result := delegatecall(
                sub(gas(), 10000),
                target,
                0x0,
                calldatasize(),
                0,
                len
            )
            return(0, len)
        }
    }
}

contract Example is Upgradeable {
    uint _value;

    function initialize() public override {
        _sizes[bytes4(keccak256("getUint()"))] = 32;
    }

    function getUint() public view returns (uint) {
        return _value;
    }

    function setUint(uint value) public {
        _value = value;
    }
}
