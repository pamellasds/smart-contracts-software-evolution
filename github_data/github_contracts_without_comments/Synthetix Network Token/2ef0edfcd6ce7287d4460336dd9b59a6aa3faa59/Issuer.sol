pragma solidity 0.4.25;

import ;
import ;
import ;
import ;
import ;
import ;
import ;


contract issuer is mixinresolver {
    using safemath for uint;
    using safedecimalmath for uint;

    bytes32 private constant susd = ;

    constructor(address _owner, address _resolver) public mixinresolver(_owner, _resolver) {}

    
    function synthetix() internal view returns (isynthetix) {
        return isynthetix(resolver.requireandgetaddress(, ));
    }

    function exchanger() internal view returns (iexchanger) {
        return iexchanger(resolver.requireandgetaddress(, ));
    }

    function synthetixstate() internal view returns (isynthetixstate) {
        return isynthetixstate(resolver.requireandgetaddress(, ));
    }

    function feepool() internal view returns (ifeepool) {
        return ifeepool(resolver.requireandgetaddress(, ));
    }

    

    

    function issuesynths(address from, uint amount)
        external
        onlysynthetix
    
    {
        
        (uint maxissuable, uint existingdebt, uint totalsystemdebt) = synthetix().remainingissuablesynths(from);
        require(amount <= maxissuable, );

        
        _addtodebtregister(from, amount, existingdebt, totalsystemdebt);

        
        synthetix().synths(susd).issue(from, amount);

        
        _appendaccountissuancerecord(from);
    }

    function issuemaxsynths(address from) external onlysynthetix {
        
        (uint maxissuable, uint existingdebt, uint totalsystemdebt) = synthetix().remainingissuablesynths(from);

        
        _addtodebtregister(from, maxissuable, existingdebt, totalsystemdebt);

        
        synthetix().synths(susd).issue(from, maxissuable);

        
        _appendaccountissuancerecord(from);
    }

    function burnsynths(address from, uint amount)
        external
        onlysynthetix
    
    {
        isynthetix _synthetix = synthetix();
        iexchanger _exchanger = exchanger();

        
        (, uint refunded) = _exchanger.settle(from, susd);

        
        (uint existingdebt, uint totalsystemvalue) = _synthetix.debtbalanceofandtotaldebt(from, susd);

        require(existingdebt > 0, );

        uint debttoremoveaftersettlement = _exchanger.calculateamountaftersettlement(from, susd, amount, refunded);

        
        
        uint amounttoremove = existingdebt < debttoremoveaftersettlement ? existingdebt : debttoremoveaftersettlement;

        
        _removefromdebtregister(from, amounttoremove, existingdebt, totalsystemvalue);

        uint amounttoburn = amounttoremove;

        
        _synthetix.synths(susd).burn(from, amounttoburn);

        
        _appendaccountissuancerecord(from);
    }

    

    
    function _appendaccountissuancerecord(address from) internal {
        uint initialdebtownership;
        uint debtentryindex;
        (initialdebtownership, debtentryindex) = synthetixstate().issuancedata(from);

        feepool().appendaccountissuancerecord(from, initialdebtownership, debtentryindex);
    }

    
    function _addtodebtregister(address from, uint amount, uint existingdebt, uint totaldebtissued) internal {
        isynthetixstate state = synthetixstate();

        
        uint newtotaldebtissued = amount.add(totaldebtissued);

        
        uint debtpercentage = amount.dividedecimalroundprecise(newtotaldebtissued);

        
        
        
        
        uint delta = safedecimalmath.preciseunit().sub(debtpercentage);

        
        if (existingdebt > 0) {
            debtpercentage = amount.add(existingdebt).dividedecimalroundprecise(newtotaldebtissued);
        }

        
        if (existingdebt == 0) {
            state.incrementtotalissuercount();
        }

        
        state.setcurrentissuancedata(from, debtpercentage);

        
        
        if (state.debtledgerlength() > 0) {
            state.appenddebtledgervalue(state.lastdebtledgerentry().multiplydecimalroundprecise(delta));
        } else {
            state.appenddebtledgervalue(safedecimalmath.preciseunit());
        }
    }

    
    function _removefromdebtregister(address from, uint amount, uint existingdebt, uint totaldebtissued) internal {
        isynthetixstate state = synthetixstate();

        uint debttoremove = amount;

        
        uint newtotaldebtissued = totaldebtissued.sub(debttoremove);

        uint delta = 0;

        
        
        if (newtotaldebtissued > 0) {
            
            uint debtpercentage = debttoremove.dividedecimalroundprecise(newtotaldebtissued);

            
            
            
            delta = safedecimalmath.preciseunit().add(debtpercentage);
        }

        
        if (debttoremove == existingdebt) {
            state.setcurrentissuancedata(from, 0);
            state.decrementtotalissuercount();
        } else {
            
            uint newdebt = existingdebt.sub(debttoremove);
            uint newdebtpercentage = newdebt.dividedecimalroundprecise(newtotaldebtissued);

            
            state.setcurrentissuancedata(from, newdebtpercentage);
        }

        
        state.appenddebtledgervalue(state.lastdebtledgerentry().multiplydecimalroundprecise(delta));
    }

    

    modifier onlysynthetix() {
        require(msg.sender == address(synthetix()), );
        _;
    }
}
