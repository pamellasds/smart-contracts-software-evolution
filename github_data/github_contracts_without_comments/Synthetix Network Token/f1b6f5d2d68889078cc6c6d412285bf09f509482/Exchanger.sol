pragma solidity ^0.5.16;


import ;
import ;
import ;


import ;


import ;
import ;
import ;
import ;
import ;
import ;
import ;
import ;



interface isynthetixinternal {
    function emitsynthexchange(
        address account,
        bytes32 fromcurrencykey,
        uint fromamount,
        bytes32 tocurrencykey,
        uint toamount,
        address toaddress
    ) external;

    function emitexchangereclaim(
        address account,
        bytes32 currencykey,
        uint amount
    ) external;

    function emitexchangerebate(
        address account,
        bytes32 currencykey,
        uint amount
    ) external;
}



contract exchanger is owned, mixinresolver, iexchanger {
    using safemath for uint;
    using safedecimalmath for uint;

    bytes32 private constant susd = ;

    uint public waitingperiodsecs;

    

    bytes32 private constant contract_systemstatus = ;
    bytes32 private constant contract_exchangestate = ;
    bytes32 private constant contract_exrates = ;
    bytes32 private constant contract_synthetix = ;
    bytes32 private constant contract_feepool = ;
    bytes32 private constant contract_delegateapprovals = ;
    bytes32 private constant contract_issuer = ;

    bytes32[24] private addressestocache = [
        contract_systemstatus,
        contract_exchangestate,
        contract_exrates,
        contract_synthetix,
        contract_feepool,
        contract_delegateapprovals,
        contract_issuer
    ];

    constructor(address _owner, address _resolver) public owned(_owner) mixinresolver(_resolver, addressestocache) {
        waitingperiodsecs = 3 minutes;
    }

    

    function systemstatus() internal view returns (isystemstatus) {
        return isystemstatus(requireandgetaddress(contract_systemstatus, ));
    }

    function exchangestate() internal view returns (iexchangestate) {
        return iexchangestate(requireandgetaddress(contract_exchangestate, ));
    }

    function exchangerates() internal view returns (iexchangerates) {
        return iexchangerates(requireandgetaddress(contract_exrates, ));
    }

    function synthetix() internal view returns (isynthetix) {
        return isynthetix(requireandgetaddress(contract_synthetix, ));
    }

    function feepool() internal view returns (ifeepool) {
        return ifeepool(requireandgetaddress(contract_feepool, ));
    }

    function delegateapprovals() internal view returns (idelegateapprovals) {
        return idelegateapprovals(requireandgetaddress(contract_delegateapprovals, ));
    }

    function issuer() internal view returns (iissuer) {
        return iissuer(requireandgetaddress(contract_issuer, ));
    }

    function maxsecsleftinwaitingperiod(address account, bytes32 currencykey) public view returns (uint) {
        return secsleftinwaitingperiodforexchange(exchangestate().getmaxtimestamp(account, currencykey));
    }

    function settlementowing(address account, bytes32 currencykey)
        public
        view
        returns (
            uint reclaimamount,
            uint rebateamount,
            uint numentries
        )
    {
        
        numentries = exchangestate().getlengthofentries(account, currencykey);

        
        for (uint i = 0; i < numentries; i++) {
            
            (bytes32 src, uint amount, bytes32 dest, uint amountreceived, uint exchangefeerate, , , ) = exchangestate()
                .getentryat(account, currencykey, i);

            
            (uint srcroundidatperiodend, uint destroundidatperiodend) = getroundidsatperiodend(account, currencykey, i);

            
            uint destinationamount = exchangerates().effectivevalueatround(
                src,
                amount,
                dest,
                srcroundidatperiodend,
                destroundidatperiodend
            );

            
            uint amountshouldhavereceived = _getamountreceivedforexchange(destinationamount, exchangefeerate);

            if (amountreceived > amountshouldhavereceived) {
                
                reclaimamount = reclaimamount.add(amountreceived.sub(amountshouldhavereceived));
            } else if (amountshouldhavereceived > amountreceived) {
                
                rebateamount = rebateamount.add(amountshouldhavereceived.sub(amountreceived));
            }
        }

        return (reclaimamount, rebateamount, numentries);
    }

    function haswaitingperiodorsettlementowing(address account, bytes32 currencykey) external view returns (bool) {
        if (maxsecsleftinwaitingperiod(account, currencykey) != 0) {
            return true;
        }

        (uint reclaimamount, , ) = settlementowing(account, currencykey);

        return reclaimamount > 0;
    }

    

    function setwaitingperiodsecs(uint _waitingperiodsecs) external onlyowner {
        waitingperiodsecs = _waitingperiodsecs;
    }

    function calculateamountaftersettlement(
        address from,
        bytes32 currencykey,
        uint amount,
        uint refunded
    ) public view returns (uint amountaftersettlement) {
        amountaftersettlement = amount;

        
        uint balanceofsourceaftersettlement = ierc20(address(issuer().synths(currencykey))).balanceof(from);

        
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
    ) external onlysynthetixorsynth returns (uint amountreceived) {
        amountreceived = _exchange(from, sourcecurrencykey, sourceamount, destinationcurrencykey, destinationaddress);
    }

    function exchangeonbehalf(
        address exchangeforaddress,
        address from,
        bytes32 sourcecurrencykey,
        uint sourceamount,
        bytes32 destinationcurrencykey
    ) external onlysynthetixorsynth returns (uint amountreceived) {
        require(delegateapprovals().canexchangefor(exchangeforaddress, from), );
        amountreceived = _exchange(
            exchangeforaddress,
            sourcecurrencykey,
            sourceamount,
            destinationcurrencykey,
            exchangeforaddress
        );
    }

    function _exchange(
        address from,
        bytes32 sourcecurrencykey,
        uint sourceamount,
        bytes32 destinationcurrencykey,
        address destinationaddress
    ) internal returns (uint amountreceived) {
        require(sourcecurrencykey != destinationcurrencykey, );
        require(sourceamount > 0, );

        bytes32[] memory synthkeys = new bytes32[](2);
        synthkeys[0] = sourcecurrencykey;
        synthkeys[1] = destinationcurrencykey;
        require(!exchangerates().anyrateisstale(synthkeys), );

        (, uint refunded, uint numentriessettled) = _internalsettle(from, sourcecurrencykey);

        uint sourceamountaftersettlement = sourceamount;

        
        if (numentriessettled > 0) {
            
            sourceamountaftersettlement = calculateamountaftersettlement(from, sourcecurrencykey, sourceamount, refunded);

            
            
            if (sourceamountaftersettlement == 0) {
                return 0;
            }
        }

        
        

        
        issuer().synths(sourcecurrencykey).burn(from, sourceamountaftersettlement);

        uint fee;
        uint exchangefeerate;

        (amountreceived, fee, exchangefeerate) = _getamountsforexchangeminusfees(
            sourceamountaftersettlement,
            sourcecurrencykey,
            destinationcurrencykey
        );

        
        issuer().synths(destinationcurrencykey).issue(destinationaddress, amountreceived);

        
        if (fee > 0) {
            remitfee(fee, destinationcurrencykey);
        }

        

        
        isynthetixinternal(address(synthetix())).emitsynthexchange(
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
            amountreceived,
            exchangefeerate
        );
    }

    
    function settle(address from, bytes32 currencykey)
        external
        synthactive(currencykey)
        returns (
            uint reclaimed,
            uint refunded,
            uint numentriessettled
        )
    {
        return _internalsettle(from, currencykey);
    }

    
    function remitfee(uint fee, bytes32 currencykey) internal {
        
        uint usdfeeamount = exchangerates().effectivevalue(currencykey, fee, susd);
        issuer().synths(susd).issue(feepool().fee_address(), usdfeeamount);
        
        feepool().recordfeepaid(usdfeeamount);
    }

    function _internalsettle(address from, bytes32 currencykey)
        internal
        returns (
            uint reclaimed,
            uint refunded,
            uint numentriessettled
        )
    {
        require(maxsecsleftinwaitingperiod(from, currencykey) == 0, );

        (uint reclaimamount, uint rebateamount, uint entries) = settlementowing(from, currencykey);

        if (reclaimamount > rebateamount) {
            reclaimed = reclaimamount.sub(rebateamount);
            reclaim(from, currencykey, reclaimed);
        } else if (rebateamount > reclaimamount) {
            refunded = rebateamount.sub(reclaimamount);
            refund(from, currencykey, refunded);
        }

        numentriessettled = entries;

        
        exchangestate().removeentries(from, currencykey);
    }

    function reclaim(
        address from,
        bytes32 currencykey,
        uint amount
    ) internal {
        
        issuer().synths(currencykey).burn(from, amount);
        isynthetixinternal(address(synthetix())).emitexchangereclaim(from, currencykey, amount);
    }

    function refund(
        address from,
        bytes32 currencykey,
        uint amount
    ) internal {
        
        issuer().synths(currencykey).issue(from, amount);
        isynthetixinternal(address(synthetix())).emitexchangerebate(from, currencykey, amount);
    }

    function secsleftinwaitingperiodforexchange(uint timestamp) internal view returns (uint) {
        if (timestamp == 0 || now >= timestamp.add(waitingperiodsecs)) {
            return 0;
        }

        return timestamp.add(waitingperiodsecs).sub(now);
    }

    function feerateforexchange(bytes32 sourcecurrencykey, bytes32 destinationcurrencykey)
        external
        view
        returns (uint exchangefeerate)
    {
        exchangefeerate = _feerateforexchange(sourcecurrencykey, destinationcurrencykey);
    }

    function _feerateforexchange(
        bytes32, 
        bytes32 destinationcurrencykey
    ) internal view returns (uint exchangefeerate) {
        exchangefeerate = feepool().getexchangefeerateforsynth(destinationcurrencykey);
    }

    function getamountsforexchange(
        uint sourceamount,
        bytes32 sourcecurrencykey,
        bytes32 destinationcurrencykey
    )
        external
        view
        returns (
            uint amountreceived,
            uint fee,
            uint exchangefeerate
        )
    {
        (amountreceived, fee, exchangefeerate) = _getamountsforexchangeminusfees(
            sourceamount,
            sourcecurrencykey,
            destinationcurrencykey
        );
    }

    function _getamountsforexchangeminusfees(
        uint sourceamount,
        bytes32 sourcecurrencykey,
        bytes32 destinationcurrencykey
    )
        internal
        view
        returns (
            uint amountreceived,
            uint fee,
            uint exchangefeerate
        )
    {
        uint destinationamount = exchangerates().effectivevalue(sourcecurrencykey, sourceamount, destinationcurrencykey);
        exchangefeerate = _feerateforexchange(sourcecurrencykey, destinationcurrencykey);
        amountreceived = _getamountreceivedforexchange(destinationamount, exchangefeerate);
        fee = destinationamount.sub(amountreceived);
    }

    function _getamountreceivedforexchange(uint destinationamount, uint exchangefeerate)
        internal
        pure
        returns (uint amountreceived)
    {
        amountreceived = destinationamount.multiplydecimal(safedecimalmath.unit().sub(exchangefeerate));
    }

    function appendexchange(
        address account,
        bytes32 src,
        uint amount,
        bytes32 dest,
        uint amountreceived,
        uint exchangefeerate
    ) internal {
        iexchangerates exrates = exchangerates();
        uint roundidforsrc = exrates.getcurrentroundid(src);
        uint roundidfordest = exrates.getcurrentroundid(dest);
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

    function getroundidsatperiodend(
        address account,
        bytes32 currencykey,
        uint index
    ) internal view returns (uint srcroundidatperiodend, uint destroundidatperiodend) {
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

    modifier synthactive(bytes32 currencykey) {
        systemstatus().requireexchangeactive();

        systemstatus().requiresynthactive(currencykey);
        _;
    }
}
