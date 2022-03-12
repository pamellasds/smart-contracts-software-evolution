

pragma solidity 0.4.25;

import ;
import ;
import ;
import ;

contract feepoolstate is selfdestructible, limitedsetup {
    using safemath for uint;
    using safedecimalmath for uint;

    

    uint8 constant public fee_period_length = 6;

    address public feepool;

    
    struct issuancedata {
        uint debtpercentage;
        uint debtentryindex;
    }

    
    mapping(address => issuancedata[fee_period_length]) public accountissuanceledger;

    
    constructor(address _owner, ifeepool _feepool)
        selfdestructible(_owner)
        limitedsetup(6 weeks)
        public
    {
        feepool = _feepool;
    }

    

    
    function setfeepool(ifeepool _feepool)
        external
        onlyowner
    {
        feepool = _feepool;
    }

    

    
    function getaccountsdebtentry(address account, uint index)
        public
        view
        returns (uint debtpercentage, uint debtentryindex)
    {
        require(index < fee_period_length, );

        debtpercentage = accountissuanceledger[account][index].debtpercentage;
        debtentryindex = accountissuanceledger[account][index].debtentryindex;
    }

    
    function applicableissuancedata(address account, uint closingdebtindex)
        external
        view
        returns (uint, uint)
    {
        issuancedata[fee_period_length] memory issuancedata = accountissuanceledger[account];
        
        
        
        for (uint i = 0; i < fee_period_length; i++) {
            if (closingdebtindex >= issuancedata[i].debtentryindex) {
                return (issuancedata[i].debtpercentage, issuancedata[i].debtentryindex);
            }
        }
    }

    

    
    function appendaccountissuancerecord(address account, uint debtratio, uint debtentryindex, uint currentperiodstartdebtindex)
        external
        onlyfeepool
    {
        
        if (accountissuanceledger[account][0].debtentryindex < currentperiodstartdebtindex) {
             
            issuancedataindexorder(account);
        }
        
        
        accountissuanceledger[account][0].debtpercentage = debtratio;
        accountissuanceledger[account][0].debtentryindex = debtentryindex;
    }

    
    function issuancedataindexorder(address account)
        private
    {
        for (uint i = fee_period_length  2; i < fee_period_length; i) {
            uint next = i + 1;
            accountissuanceledger[account][next].debtpercentage = accountissuanceledger[account][i].debtpercentage;
            accountissuanceledger[account][next].debtentryindex = accountissuanceledger[account][i].debtentryindex;
        }
    }

    
    function importissuerdata(address[] accounts, uint[] ratios, uint periodtoinsert, uint feeperiodcloseindex)
        external
        onlyowner
        onlyduringsetup
    {
        require(accounts.length == ratios.length, );

        for (uint8 i = 0; i < accounts.length; i++) {
            accountissuanceledger[accounts[i]][periodtoinsert].debtpercentage = ratios[i];
            accountissuanceledger[accounts[i]][periodtoinsert].debtentryindex = feeperiodcloseindex;
            emit issuancedebtratioentry(accounts[i], ratios[i], feeperiodcloseindex);
        }
    }

    

    modifier onlyfeepool
    {
        require(msg.sender == address(feepool), );
        _;
    }

    
    event issuancedebtratioentry(address indexed account, uint debtratio, uint feeperiodcloseindex);
}
