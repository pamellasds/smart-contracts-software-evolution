pragma solidity ^0.5.16;

import ;
import ;



contract feepooleternalstorage is eternalstorage, limitedsetup {
    bytes32 constant last_fee_withdrawal = ;

    constructor(address _owner, address _feepool) public eternalstorage(_owner, _feepool) limitedsetup(6 weeks) {}

    function importfeewithdrawaldata(address[] calldata accounts, uint[] calldata feeperiodids)
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
