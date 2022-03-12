

pragma solidity 0.4.25;

import ;
import ;
import ;
import ;


contract synthetixstate is state, limitedsetup {
    using safemath for uint;
    using safedecimalmath for uint;

    
    struct issuancedata {
        
        
        
        
        
        uint initialdebtownership;
        
        
        
        uint debtentryindex;
    }

    
    mapping(address => issuancedata) public issuancedata;

    
    uint public totalissuercount;

    
    uint[] public debtledger;

    
    
    uint public issuanceratio = safedecimalmath.unit() / 5;
    
    uint constant max_issuance_ratio = safedecimalmath.unit();

    
    
    mapping(address => bytes4) public preferredcurrency;

    
    constructor(address _owner, address _associatedcontract)
        state(_owner, _associatedcontract)
        limitedsetup(1 weeks)
        public
    {}

    

    
    function setcurrentissuancedata(address account, uint initialdebtownership)
        external
        onlyassociatedcontract
    {
        issuancedata[account].initialdebtownership = initialdebtownership;
        issuancedata[account].debtentryindex = debtledger.length;
    }

    
    function clearissuancedata(address account)
        external
        onlyassociatedcontract
    {
        delete issuancedata[account];
    }

    
    function incrementtotalissuercount()
        external
        onlyassociatedcontract
    {
        totalissuercount = totalissuercount.add(1);
    }

    
    function decrementtotalissuercount()
        external
        onlyassociatedcontract
    {
        totalissuercount = totalissuercount.sub(1);
    }

    
    function appenddebtledgervalue(uint value)
        external
        onlyassociatedcontract
    {
        debtledger.push(value);
    }

    
    function setpreferredcurrency(address account, bytes4 currencykey)
        external
        onlyassociatedcontract
    {
        preferredcurrency[account] = currencykey;
    }

    
    function setissuanceratio(uint _issuanceratio)
        external
        onlyowner
    {
        require(_issuanceratio <= max_issuance_ratio, );
        issuanceratio = _issuanceratio;
        emit issuanceratioupdated(_issuanceratio);
    }

    
    function importissuerdata(address[] accounts, uint[] susdamounts)
        external
        onlyowner
        onlyduringsetup
    {
        require(accounts.length == susdamounts.length, );

        for (uint8 i = 0; i < accounts.length; i++) {
            _addtodebtregister(accounts[i], susdamounts[i]);
        }
    }

    
    function _addtodebtregister(address account, uint amount)
        internal
    {
        
        
        synthetix synthetix = synthetix(associatedcontract);

        
        uint xdrvalue = synthetix.effectivevalue(, amount, );

        
        uint totaldebtissued = synthetix.totalissuedsynths();

        
        uint newtotaldebtissued = xdrvalue.add(totaldebtissued);

        
        uint debtpercentage = xdrvalue.dividedecimalroundprecise(newtotaldebtissued);

        
        
        
        
        uint delta = safedecimalmath.preciseunit().sub(debtpercentage);

        uint existingdebt = synthetix.debtbalanceof(account, );

        
        if (existingdebt > 0) {
            debtpercentage = xdrvalue.add(existingdebt).dividedecimalroundprecise(newtotaldebtissued);
        }

        
        if (issuancedata[account].initialdebtownership == 0) {
            totalissuercount = totalissuercount.add(1);
        }

        
        issuancedata[account].initialdebtownership = debtpercentage;
        issuancedata[account].debtentryindex = debtledger.length;

        
        
        if (debtledger.length > 0) {
            debtledger.push(
                debtledger[debtledger.length  1].multiplydecimalroundprecise(delta)
            );
        } else {
            debtledger.push(safedecimalmath.preciseunit());
        }
    }

    

    
    function debtledgerlength()
        external
        view
        returns (uint)
    {
        return debtledger.length;
    }

    
    function lastdebtledgerentry()
        external
        view
        returns (uint)
    {
        return debtledger[debtledger.length  1];
    }

    
    function hasissued(address account)
        external
        view
        returns (bool)
    {
        return issuancedata[account].initialdebtownership > 0;
    }

    event issuanceratioupdated(uint newratio);
}
