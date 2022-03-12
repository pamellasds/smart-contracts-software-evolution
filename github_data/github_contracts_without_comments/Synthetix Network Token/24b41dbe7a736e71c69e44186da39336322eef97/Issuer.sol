pragma solidity 0.4.25;

import ;
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
    bytes32 public constant last_issue_event = ;

    uint public minimumstaketime = 8 hours; 
    
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

    function issuanceeternalstorage() internal view returns (issuanceeternalstorage) {
        return issuanceeternalstorage(resolver.requireandgetaddress(, ));
    }

    
    function lastissueevent(address account) public view returns (uint) {
        return issuanceeternalstorage().getuintvalue(keccak256(abi.encodepacked(last_issue_event, account)));
    }
    
    

    
    function setminimumstaketime(uint _seconds) external onlyowner {
        minimumstaketime = _seconds;
        emit minimumstaketimeupdated(minimumstaketime);
    }

    
    
    function _setlastissueevent(address account) internal {
        issuanceeternalstorage().setuintvalue(
            keccak256(abi.encodepacked(last_issue_event, account)),
            block.timestamp
        );
    }    
    
    function issuesynths(address from, uint amount)
        external
        onlysynthetix
    
    {
        
        (uint maxissuable, uint existingdebt, uint totalsystemdebt) = synthetix().remainingissuablesynths(from);
        require(amount <= maxissuable, );

        _internalissuesynths(from, amount, existingdebt, totalsystemdebt);
    }

    function issuemaxsynths(address from) external onlysynthetix {
        
        (uint maxissuable, uint existingdebt, uint totalsystemdebt) = synthetix().remainingissuablesynths(from);

        _internalissuesynths(from, maxissuable, existingdebt, totalsystemdebt);
    }

    function _internalissuesynths(address from, uint amount, uint existingdebt, uint totalsystemdebt)
        internal
    {
        
        _addtodebtregister(from, amount, existingdebt, totalsystemdebt);

        
        _setlastissueevent(from);

        
        synthetix().synths(susd).issue(from, amount);

        
        _appendaccountissuancerecord(from);
    }

    
    function burnsynths(address from, uint amount)
        external
        onlysynthetix
    {
        require(now >= lastissueevent(from).add(minimumstaketime), );

        
        (, uint refunded) = exchanger().settle(from, susd);

        
        (uint existingdebt, uint totalsystemvalue) = synthetix().debtbalanceofandtotaldebt(from, susd);

        require(existingdebt > 0, );

        uint debttoremoveaftersettlement = exchanger().calculateamountaftersettlement(from, susd, amount, refunded);

        _internalburnsynths(from, debttoremoveaftersettlement, existingdebt, totalsystemvalue);
    }

    
    
    function burnsynthstotarget(address from)
        external
        onlysynthetix
    {
        
        (uint existingdebt, uint totalsystemvalue) = synthetix().debtbalanceofandtotaldebt(from, susd);

        require(existingdebt > 0, );

        
        uint maxissuable = synthetix().maxissuablesynths(from);

        
        uint amounttoburntotarget = existingdebt.sub(maxissuable);

        
        _internalburnsynths(from, amounttoburntotarget, existingdebt, totalsystemvalue);
    }

    function _internalburnsynths(address from, uint amount, uint existingdebt, uint totalsystemvalue)
        internal
        
    {
        
        
        uint amounttoremove = existingdebt < amount ? existingdebt : amount;

        
        _removefromdebtregister(from, amounttoremove, existingdebt, totalsystemvalue);

        uint amounttoburn = amounttoremove;

        
        synthetix().synths(susd).burn(from, amounttoburn);

        
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

    

    event minimumstaketimeupdated(uint minimumstaketime);
}
