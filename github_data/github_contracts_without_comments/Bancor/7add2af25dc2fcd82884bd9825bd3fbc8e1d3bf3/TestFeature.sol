pragma solidity ^0.4.21;
import ;


contract testfeatures {
    icontractfeatures public features;

    function testfeatures(icontractfeatures _features) public {
        features = _features;
    }

    function enablefeature(uint256 _feature, bool _enable) public {
        features.enablefeature(_feature, _enable);
    }
}
