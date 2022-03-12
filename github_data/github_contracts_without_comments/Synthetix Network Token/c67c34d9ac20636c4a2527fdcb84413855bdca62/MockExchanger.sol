pragma solidity 0.4.25;

import ;


contract mockexchanger {
    uint256 private _mockreclaimamount;
    uint256 private _mockrefundamount;
    uint256 private _mocknumentries;
    uint256 private _mockmaxsecsleft;

    isynthetix synthetix;

    constructor(isynthetix _synthetix) public {
        synthetix = _synthetix;
    }

    
    function settle(address from, bytes32 currencykey)
        external
        returns (uint256 reclaimed, uint256 refunded, uint numentriessettled)
    {
        if (_mockreclaimamount > 0) {
            synthetix.synths(currencykey).burn(from, _mockreclaimamount);
        }

        if (_mockrefundamount > 0) {
            synthetix.synths(currencykey).issue(from, _mockrefundamount);
        }

        _mockmaxsecsleft = 0;

        return (_mockreclaimamount, _mockrefundamount, _mocknumentries);
    }

    function maxsecsleftinwaitingperiod(address account, bytes32 currencykey) public view returns (uint) {
        return _mockmaxsecsleft;
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

    function setmaxsecsleft(uint _maxsecsleft) external {
        _mockmaxsecsleft = _maxsecsleft;
    }
}
