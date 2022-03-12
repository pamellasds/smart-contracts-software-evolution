pragma solidity ^0.5.16;

import ;
import ;
import ;
import ;
import ;



contract synthetixstate is owned, state, limitedsetup {
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
    
    uint public constant max_issuance_ratio = 1e18;

    
    
    mapping(address => bytes4) public preferredcurrency;

    constructor(address _owner, address _associatedcontract)
        public
        owned(_owner)
        state(_associatedcontract)
        limitedsetup(1 weeks)
    {}

    

    
    function setcurrentissuancedata(address account, uint initialdebtownership) external onlyassociatedcontract {
        issuancedata[account].initialdebtownership = initialdebtownership;
        issuancedata[account].debtentryindex = debtledger.length;
    }

    
    function clearissuancedata(address account) external onlyassociatedcontract {
        delete issuancedata[account];
    }

    
    function incrementtotalissuercount() external onlyassociatedcontract {
        totalissuercount = totalissuercount.add(1);
    }

    
    function decrementtotalissuercount() external onlyassociatedcontract {
        totalissuercount = totalissuercount.sub(1);
    }

    
    function appenddebtledgervalue(uint value) external onlyassociatedcontract {
        debtledger.push(value);
    }

    
    function setpreferredcurrency(address account, bytes4 currencykey) external onlyassociatedcontract {
        preferredcurrency[account] = currencykey;
    }

    
    function setissuanceratio(uint _issuanceratio) external onlyowner {
        require(_issuanceratio <= max_issuance_ratio, );
        issuanceratio = _issuanceratio;
        emit issuanceratioupdated(_issuanceratio);
    }

    
    
    
    
    
    

    
    
    
    

    
    
    
    
    
    
    
    
    
    

    

    
    function debtledgerlength() external view returns (uint) {
        return debtledger.length;
    }

    
    function lastdebtledgerentry() external view returns (uint) {
        return debtledger[debtledger.length  1];
    }

    
    function hasissued(address account) external view returns (bool) {
        return issuancedata[account].initialdebtownership > 0;
    }

    event issuanceratioupdated(uint newratio);
}
