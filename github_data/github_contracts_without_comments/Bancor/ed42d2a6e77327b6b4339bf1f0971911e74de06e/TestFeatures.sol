pragma solidity ^0.4.23;
import ;


contract testfeatures {
    icontractfeatures public features;

    function testfeatures(icontractfeatures _features) public {
        features = _features;
    }

    function enablefeatures(uint256 _features, bool _enable) public {
        features.enablefeatures(_features, _enable);
    }
}
