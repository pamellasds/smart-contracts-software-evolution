pragma solidity ^0.4.21;
import ;


contract contractfeatures is icontractfeatures {
    mapping (address => uint256) private featureflags;

    
    function contractfeatures() public {
    }

    
    function issupported(address _contract, uint256 _feature) public returns (bool) {
        return (featureflags[_contract] & _feature) == _feature;
    }

    
    function enablefeature(uint256 _feature, bool _enable) public {
        if (_enable) {
            if (issupported(msg.sender, _feature))
                return;

            featureflags[msg.sender] |= _feature;
        } else {
            if (!issupported(msg.sender, _feature))
                return;

            featureflags[msg.sender] &= ~_feature;
        }
    }
}
