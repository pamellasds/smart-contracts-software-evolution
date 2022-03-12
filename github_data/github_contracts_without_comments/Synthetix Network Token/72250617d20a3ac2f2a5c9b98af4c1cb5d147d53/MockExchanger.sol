pragma solidity 0.4.25;

import ;


contract mockexchanger {
    uint256 private _mockreclaimamount;
    uint256 private _mockrefundamount;

    isynthetix synthetix;

    constructor(isynthetix _synthetix) public {
        synthetix = _synthetix;
    }

    
    function settle(address from, bytes32 currencykey) external view returns (uint256 reclaimed, uint256 refunded) {
        if (_mockreclaimamount > 0) {
            synthetix.synths(currencykey).burn(from, _mockreclaimamount);
        }

        if (_mockrefundamount > 0) {
            synthetix.synths(currencykey).issue(from, _mockrefundamount);
        }

        return (_mockreclaimamount, _mockrefundamount);
    }

    function settlementowing(address account, bytes32 currencykey)
        public
        view
        returns (uint reclaimamount, uint rebateamount)
    {
        return (_mockreclaimamount, _mockrefundamount);
    }

    function setreclaim(uint256 _reclaimamount) external {
        _mockreclaimamount = _reclaimamount;
    }

    function setrefund(uint256 _refundamount) external {
        _mockrefundamount = _refundamount;
    }
}
