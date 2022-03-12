pragma solidity 0.4.25;

import ;
import ;
import ;
import ;
import ;
import ;
import ;
import ;

contract exchanger is mixinresolver {
    using safemath for uint;
    using safedecimalmath for uint;

    bool public exchangeenabled;

    bytes32 private constant susd = ;

    uint public waitingperiodsecs;

    constructor(address _owner, address _resolver) public mixinresolver(_owner, _resolver) {
        exchangeenabled = true;
        waitingperiodsecs = 3 minutes;
    }

    

    function exchangestate() internal view returns (iexchangestate) {
        return iexchangestate(resolver.requireandgetaddress(, ));
    }

    function exchangerates() internal view returns (iexchangerates) {
        return iexchangerates(resolver.requireandgetaddress(, ));
    }

    function synthetix() internal view returns (isynthetix) {
        return isynthetix(resolver.requireandgetaddress(, ));
    }

    function feepool() internal view returns (ifeepool) {
        return ifeepool(resolver.requireandgetaddress(, ));
    }

    function maxsecsleftinwaitingperiod(address account, bytes32 currencykey) public view returns (uint) {
        return secsleftinwaitingperiodforexchange(exchangestate().getmaxtimestamp(account, currencykey));
    }

    
    function feerateforexchange(bytes32 sourcecurrencykey, bytes32 destinationcurrencykey) public view returns (uint) {
        
        uint exchangefeerate = feepool().exchangefeerate();

        uint multiplier = 1;

        
        
        if (
            (sourcecurrencykey[0] == 0x73 && sourcecurrencykey != susd && destinationcurrencykey[0] == 0x69) ||
            (sourcecurrencykey[0] == 0x69 && destinationcurrencykey != susd && destinationcurrencykey[0] == 0x73)
        ) {
            
            multiplier = 2;
        }

        return exchangefeerate.mul(multiplier);
    }

    function settlementowing(address account, bytes32 currencykey)
        public
        view
        returns (uint reclaimamount, uint rebateamount)
    {
        
        uint numentries = exchangestate().getlengthofentries(account, currencykey);

        
        for (uint i = 0; i < numentries; i++) {
            
            (bytes32 src, uint amount, bytes32 dest, uint amountreceived, , , , ) = exchangestate().getentryat(
                account,
                currencykey,
                i
            );

            
            (uint srcroundidatperiodend, uint destroundidatperiodend) = getroundidsatperiodend(account, currencykey, i);

            
            uint destinationamount = exchangerates().effectivevalueatround(
                src,
                amount,
                dest,
                srcroundidatperiodend,
                destroundidatperiodend
            );

            
            (uint amountshouldhavereceived, ) = calculateexchangeamountminusfees(src, dest, destinationamount);

            if (amountreceived > amountshouldhavereceived) {
                
                reclaimamount = reclaimamount.add(amountreceived.sub(amountshouldhavereceived));
            } else if (amountshouldhavereceived > amountreceived) {
                
                rebateamount = rebateamount.add(amountshouldhavereceived.sub(amountreceived));
            }
        }

        return (reclaimamount, rebateamount);
    }

    

    function setwaitingperiodsecs(uint _waitingperiodsecs) external onlyowner {
        waitingperiodsecs = _waitingperiodsecs;
    }

    function setexchangeenabled(bool _exchangeenabled) external onlyowner {
        exchangeenabled = _exchangeenabled;
    }

    function calculateamountaftersettlement(address from, bytes32 currencykey, uint amount, uint refunded)
        public
        view
        returns (uint amountaftersettlement)
    {
        amountaftersettlement = amount;

        
        uint balanceofsourceaftersettlement = synthetix().synths(currencykey).balanceof(from);

        
        if (amountaftersettlement > balanceofsourceaftersettlement) {
            
            amountaftersettlement = balanceofsourceaftersettlement;
        }

        if (refunded > 0) {
            amountaftersettlement = amountaftersettlement.add(refunded);
        }
    }

    

    function exchange(
        address from,
        bytes32 sourcecurrencykey,
        uint sourceamount,
        bytes32 destinationcurrencykey,
        address destinationaddress
    )
        external
        
        onlysynthetixorsynth
        returns (uint amountreceived)
    {
        require(sourcecurrencykey != destinationcurrencykey, );
        require(sourceamount > 0, );
        require(exchangeenabled, );

        (, uint refunded) = _internalsettle(from, sourcecurrencykey);

        isynthetix _synthetix = synthetix();
        iexchangerates _exrates = exchangerates();

        uint sourceamountaftersettlement = calculateamountaftersettlement(from, sourcecurrencykey, sourceamount, refunded);

        
        

        
        _synthetix.synths(sourcecurrencykey).burn(from, sourceamountaftersettlement);

        uint destinationamount = _exrates.effectivevalue(
            sourcecurrencykey,
            sourceamountaftersettlement,
            destinationcurrencykey
        );

        uint fee;

        (amountreceived, fee) = calculateexchangeamountminusfees(
            sourcecurrencykey,
            destinationcurrencykey,
            destinationamount
        );

        
        _synthetix.synths(destinationcurrencykey).issue(destinationaddress, amountreceived);

        
        if (fee > 0) {
            remitfee(_exrates, _synthetix, fee, destinationcurrencykey);
        }

        

        
        _synthetix.emitsynthexchange(
            from,
            sourcecurrencykey,
            sourceamountaftersettlement,
            destinationcurrencykey,
            amountreceived,
            destinationaddress
        );

        
        appendexchange(
            destinationaddress,
            sourcecurrencykey,
            sourceamountaftersettlement,
            destinationcurrencykey,
            amountreceived
        );
    }

    function settle(address from, bytes32 currencykey) external returns (uint reclaimed, uint refunded) {
        

        return _internalsettle(from, currencykey);
    }

    

    function remitfee(iexchangerates _exrates, isynthetix _synthetix, uint fee, bytes32 currencykey) internal {
        
        uint usdfeeamount = _exrates.effectivevalue(currencykey, fee, susd);
        _synthetix.synths(susd).issue(feepool().fee_address(), usdfeeamount);
        
        feepool().recordfeepaid(usdfeeamount);
    }

    function _internalsettle(address from, bytes32 currencykey) internal returns (uint reclaimed, uint refunded) {
        require(maxsecsleftinwaitingperiod(from, currencykey) == 0, );

        (uint reclaimamount, uint rebateamount) = settlementowing(from, currencykey);

        if (reclaimamount > rebateamount) {
            reclaimed = reclaimamount.sub(rebateamount);
            reclaim(from, currencykey, reclaimed);
        } else if (rebateamount > reclaimamount) {
            refunded = rebateamount.sub(reclaimamount);
            refund(from, currencykey, refunded);
        }

        
        exchangestate().removeentries(from, currencykey);
    }

    function reclaim(address from, bytes32 currencykey, uint amount) internal {
        
        synthetix().synths(currencykey).burn(from, amount);
        synthetix().emitexchangereclaim(from, currencykey, amount);
    }

    function refund(address from, bytes32 currencykey, uint amount) internal {
        
        synthetix().synths(currencykey).issue(from, amount);
        synthetix().emitexchangerebate(from, currencykey, amount);
    }

    function secsleftinwaitingperiodforexchange(uint timestamp) internal view returns (uint) {
        if (timestamp == 0 || now >= timestamp.add(waitingperiodsecs)) {
            return 0;
        }

        return timestamp.add(waitingperiodsecs).sub(now);
    }

    function calculateexchangeamountminusfees(
        bytes32 sourcecurrencykey,
        bytes32 destinationcurrencykey,
        uint destinationamount
    ) internal view returns (uint amountreceived, uint fee) {
        
        amountreceived = destinationamount;

        
        uint exchangefeerate = feerateforexchange(sourcecurrencykey, destinationcurrencykey);

        amountreceived = destinationamount.multiplydecimal(safedecimalmath.unit().sub(exchangefeerate));

        fee = destinationamount.sub(amountreceived);
    }

    function appendexchange(address account, bytes32 src, uint amount, bytes32 dest, uint amountreceived) internal {
        iexchangerates exrates = exchangerates();
        uint roundidforsrc = exrates.getcurrentroundid(src);
        uint roundidfordest = exrates.getcurrentroundid(dest);
        uint exchangefeerate = feepool().exchangefeerate();
        exchangestate().appendexchangeentry(
            account,
            src,
            amount,
            dest,
            amountreceived,
            exchangefeerate,
            now,
            roundidforsrc,
            roundidfordest
        );
    }

    function getroundidsatperiodend(address account, bytes32 currencykey, uint index)
        internal
        view
        returns (uint srcroundidatperiodend, uint destroundidatperiodend)
    {
        (bytes32 src, , bytes32 dest, , , uint timestamp, uint roundidforsrc, uint roundidfordest) = exchangestate()
            .getentryat(account, currencykey, index);

        iexchangerates exrates = exchangerates();
        srcroundidatperiodend = exrates.getlastroundidbeforeelapsedsecs(src, roundidforsrc, timestamp, waitingperiodsecs);
        destroundidatperiodend = exrates.getlastroundidbeforeelapsedsecs(dest, roundidfordest, timestamp, waitingperiodsecs);
    }

    

    modifier onlysynthetixorsynth() {
        isynthetix _synthetix = synthetix();
        require(
            msg.sender == address(_synthetix) || _synthetix.synthsbyaddress(msg.sender) != bytes32(0),
            
        );
        _;
    }
}
