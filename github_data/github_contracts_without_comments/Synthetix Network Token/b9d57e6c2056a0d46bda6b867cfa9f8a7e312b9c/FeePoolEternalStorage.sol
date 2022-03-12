

pragma solidity 0.4.25;

import ;
import ;

contract feepooleternalstorage is eternalstorage, limitedsetup {

    bytes32 constant last_fee_withdrawal = ;

    
    constructor(address _owner, address _feepool)
        eternalstorage(_owner, _feepool)
        limitedsetup(6 weeks)
        public
    {
    }

    
    function importfeewithdrawaldata(address[] accounts, uint[] feeperiodids)
        external
        onlyowner
        onlyduringsetup
    {
        require(accounts.length == feeperiodids.length, );

        for (uint8 i = 0; i < accounts.length; i++) {
            this.setuintvalue(keccak256(abi.encodepacked(last_fee_withdrawal, accounts[i])), feeperiodids[i]);
        }
    }
}