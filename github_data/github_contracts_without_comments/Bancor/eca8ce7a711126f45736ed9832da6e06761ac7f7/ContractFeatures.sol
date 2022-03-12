pragma solidity ^0.4.21;
import ;


contract contractfeatures is icontractfeatures {
    mapping (address => uint256) private featureflags;

    
    function contractfeatures() public {
    }

    
    function issupported(address _contract, uint256 _features) public returns (bool) {
        return (featureflags[_contract] & _features) == _features;
    }

    
    function enablefeatures(uint256 _features, bool _enable) public {
        if (_enable) {
            if (issupported(msg.sender, _features))
                return;

            featureflags[msg.sender] |= _features;
        } else {
            if (!issupported(msg.sender, _features))
                return;

            featureflags[msg.sender] &= ~_features;
        }
    }
}
