pragma solidity ^0.4.21;
import ;


contract contractfeatures is icontractfeatures {
    mapping (address => uint256) private featureflags;

    event featuresaddition(address indexed _address, uint256 _features);
    event featuresremoval(address indexed _address, uint256 _features);

    
    function contractfeatures() public {
    }

    
    function issupported(address _contract, uint256 _features) public view returns (bool) {
        return (featureflags[_contract] & _features) == _features;
    }

    
    function enablefeatures(uint256 _features, bool _enable) public {
        if (_enable) {
            if (issupported(msg.sender, _features))
                return;

            featureflags[msg.sender] |= _features;

            emit featuresaddition(msg.sender, _features);
        } else {
            if (!issupported(msg.sender, _features))
                return;

            featureflags[msg.sender] &= ~_features;

            emit featuresremoval(msg.sender, _features);
        }
    }
}
