
pragma solidity 0.6.12;
import ;

contract oldconverter {
    uint256 private amount;

    constructor(uint256 _amount) public {
        amount = _amount;
    }

    function getreturn(ierc20token _sourcetoken, ierc20token _targettoken, uint256 _amount) external view returns (uint256) {
        _sourcetoken;
        _targettoken;
        _amount;
        return (amount);
    }
}

contract newconverter {
    uint256 private amount;
    uint256 private fee;

    constructor(uint256 _amount, uint256 _fee) public {
        amount = _amount;
        fee = _fee;
    }

    function getreturn(ierc20token _sourcetoken, ierc20token _targettoken, uint256 _amount) external view returns (uint256, uint256) {
        _sourcetoken;
        _targettoken;
        _amount;
        return (amount, fee);
    }
}

contract converterv27orlowerwithoutfallback {
}

contract converterv27orlowerwithfallback {
    receive() external payable {
    }
}

contract converterv28orhigherwithoutfallback {
    function isv28orhigher() public pure returns (bool) {
        return true;
    }
}

contract converterv28orhigherwithfallback {
    function isv28orhigher() public pure returns (bool) {
        return true;
    }

    receive() external payable {
        revert();
    }
}

contract testbancornetwork is bancornetwork {
    oldconverter private oldconverter;
    newconverter private newconverter;

    constructor(uint256 _amount, uint256 _fee) public bancornetwork(icontractregistry(address(1))) {
        oldconverter = new oldconverter(_amount);
        newconverter = new newconverter(_amount, _fee);
    }

    function isv28orhigherconverterexternal(iconverter _converter) external view returns (bool) {
        return super.isv28orhigherconverter(_converter);
    }

    function getreturnold() external view returns (uint256, uint256) {
        return getreturn(iconverter(payable(address(oldconverter))), ierc20token(0), ierc20token(0), uint256(0));
    }

    function getreturnnew() external view returns (uint256, uint256) {
        return getreturn(iconverter(payable(address(newconverter))), ierc20token(0), ierc20token(0), uint256(0));
    }
}
