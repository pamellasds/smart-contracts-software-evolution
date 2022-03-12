pragma solidity 0.4.26;
import ;

contract oldbancorconverter {
    uint256 private amount;

    constructor(uint256 _amount) public {
        amount = _amount;
    }

    function getreturn(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount) external view returns (uint256) {
        _fromtoken;
        _totoken;
        _amount;
        return (amount);
    }
}

contract newbancorconverter {
    uint256 private amount;
    uint256 private fee;

    constructor(uint256 _amount, uint256 _fee) public {
        amount = _amount;
        fee = _fee;
    }

    function getreturn(ierc20token _fromtoken, ierc20token _totoken, uint256 _amount) external view returns (uint256, uint256) {
        _fromtoken;
        _totoken;
        _amount;
        return (amount, fee);
    }
}

contract testbancornetwork is bancornetwork {
    oldbancorconverter private oldbancorconverter;
    newbancorconverter private newbancorconverter;

    constructor(uint256 _amount, uint256 _fee) public bancornetwork(icontractregistry(address(1))) {
        oldbancorconverter = new oldbancorconverter(_amount);
        newbancorconverter = new newbancorconverter(_amount, _fee);
    }

    function getreturnold() external view returns (uint256, uint256) {
        return getreturn(address(oldbancorconverter), ierc20token(0), ierc20token(0), uint256(0));
    }

    function getreturnnew() external view returns (uint256, uint256) {
        return getreturn(address(newbancorconverter), ierc20token(0), ierc20token(0), uint256(0));
    }
}
