pragma solidity 0.4.25;

import ;


contract mockexchanger {
    uint256 private _mockreclaimamount;
    uint256 private _mockrefundamount;
    uint256 private _mocknumentries;

    isynthetix synthetix;

    constructor(isynthetix _synthetix) public {
        synthetix = _synthetix;
    }

    
    function settle(address from, bytes32 currencykey)
        external
        view
        returns (uint256 reclaimed, uint256 refunded, uint numentriessettled)
    {
        if (_mockreclaimamount > 0) {
            synthetix.synths(currencykey).burn(from, _mockreclaimamount);
        }

        if (_mockrefundamount > 0) {
            synthetix.synths(currencykey).issue(from, _mockrefundamount);
        }

        return (_mockreclaimamount, _mockrefundamount, _mocknumentries);
    }

    function settlementowing(address account, bytes32 currencykey) public view returns (uint, uint, uint) {
        return (_mockreclaimamount, _mockrefundamount, _mocknumentries);
    }

    function setreclaim(uint256 _reclaimamount) external {
        _mockreclaimamount = _reclaimamount;
    }

    function setrefund(uint256 _refundamount) external {
        _mockrefundamount = _refundamount;
    }

    function setnumentries(uint256 _numentries) external {
        _mocknumentries = _numentries;
    }
}
