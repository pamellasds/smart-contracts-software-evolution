pragma solidity ^0.5.16;

import ;


contract testablebinaryoptionmarket is binaryoptionmarket {
    constructor(
        address _owner,
        address _creator,
        uint[2] memory _creatorlimits,
        bytes32 _oraclekey,
        uint256 _strikeprice,
        bool _refundsenabled,
        uint[3] memory _times,
        uint[2] memory _bids,
        uint[3] memory _fees
    )
        public
        binaryoptionmarket(_owner, _creator, _creatorlimits, _oraclekey, _strikeprice, _refundsenabled, _times, _bids, _fees)
    {}

    function updateprices(
        uint256 longbids,
        uint256 shortbids,
        uint totaldebt
    ) public {
        _updateprices(longbids, shortbids, totaldebt);
    }

    function setmanager(address _manager) public {
        owner = _manager;
    }
}
