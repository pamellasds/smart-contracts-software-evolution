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



contract exchanger is owned, mixinresolver, mixinsystemsettings, iexchanger {
    using safemath for uint;
    using safedecimalmath for uint;

    struct exchangeentrysettlement {
        bytes32 src;
        uint amount;
        bytes32 dest;
        uint reclaim;
        uint rebate;
        uint srcroundidatperiodend;
        uint destroundidatperiodend;
        uint timestamp;
    }

    bytes32 private constant susd = ;

    
    uint public constant circuit_breaker_suspension_reason = 65;

    mapping(bytes32 => uint) public lastexchangerate;

    

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

    constructor(address _owner, address _resolver)
        public
        owned(_owner)
        mixinresolver(_resolver, addressestocache)
        mixinsystemsettings()
    {}

    

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

    function waitingperiodsecs() external view returns (uint) {
        return getwaitingperiodsecs();
    }

    function pricedeviationthresholdfactor() external view returns (uint) {
        return getpricedeviationthresholdfactor();
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
        (reclaimamount, rebateamount, numentries, ) = _settlementowing(account, currencykey);
    }

    
    function _settlementowing(address account, bytes32 currencykey)
        internal
        view
        returns (
            uint reclaimamount,
            uint rebateamount,
            uint numentries,
            exchangeentrysettlement[] memory
        )
    {
        
        numentries = exchangestate().getlengthofentries(account, currencykey);

        
        exchangeentrysettlement[] memory settlements = new exchangeentrysettlement[](numentries);
        for (uint i = 0; i < numentries; i++) {
            uint reclaim;
            uint rebate;
            
            iexchangestate.exchangeentry memory exchangeentry = _getexchangeentry(account, currencykey, i);

            
            (uint srcroundidatperiodend, uint destroundidatperiodend) = getroundidsatperiodend(exchangeentry);

            
            uint destinationamount = exchangerates().effectivevalueatround(
                exchangeentry.src,
                exchangeentry.amount,
                exchangeentry.dest,
                srcroundidatperiodend,
                destroundidatperiodend
            );

            
            uint amountshouldhavereceived = _getamountreceivedforexchange(destinationamount, exchangeentry.exchangefeerate);

            
            
            if (!_isdeviationabovethreshold(exchangeentry.amountreceived, amountshouldhavereceived)) {
                if (exchangeentry.amountreceived > amountshouldhavereceived) {
                    
                    reclaim = exchangeentry.amountreceived.sub(amountshouldhavereceived);
                    reclaimamount = reclaimamount.add(reclaim);
                } else if (amountshouldhavereceived > exchangeentry.amountreceived) {
                    
                    rebate = amountshouldhavereceived.sub(exchangeentry.amountreceived);
                    rebateamount = rebateamount.add(rebate);
                }
            }

            settlements[i] = exchangeentrysettlement({
                src: exchangeentry.src,
                amount: exchangeentry.amount,
                dest: exchangeentry.dest,
                reclaim: reclaim,
                rebate: rebate,
                srcroundidatperiodend: srcroundidatperiodend,
                destroundidatperiodend: destroundidatperiodend,
                timestamp: exchangeentry.timestamp
            });
        }

        return (reclaimamount, rebateamount, numentries, settlements);
    }

    function _getexchangeentry(
        address account,
        bytes32 currencykey,
        uint index
    ) internal view returns (iexchangestate.exchangeentry memory) {
        (
            bytes32 src,
            uint amount,
            bytes32 dest,
            uint amountreceived,
            uint exchangefeerate,
            uint timestamp,
            uint roundidforsrc,
            uint roundidfordest
        ) = exchangestate().getentryat(account, currencykey, index);

        return
            iexchangestate.exchangeentry({
                src: src,
                amount: amount,
                dest: dest,
                amountreceived: amountreceived,
                exchangefeerate: exchangefeerate,
                timestamp: timestamp,
                roundidforsrc: roundidforsrc,
                roundidfordest: roundidfordest
            });
    }

    function haswaitingperiodorsettlementowing(address account, bytes32 currencykey) external view returns (bool) {
        if (maxsecsleftinwaitingperiod(account, currencykey) != 0) {
            return true;
        }

        (uint reclaimamount, , , ) = _settlementowing(account, currencykey);

        return reclaimamount > 0;
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

    function issynthrateinvalid(bytes32 currencykey) external view returns (bool) {
        return _issynthrateinvalid(currencykey, exchangerates().rateforcurrency(currencykey));
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
        _ensurecanexchange(sourcecurrencykey, sourceamount, destinationcurrencykey);

        (, uint refunded, uint numentriessettled) = _internalsettle(from, sourcecurrencykey);

        uint sourceamountaftersettlement = sourceamount;

        
        if (numentriessettled > 0) {
            
            sourceamountaftersettlement = calculateamountaftersettlement(from, sourcecurrencykey, sourceamount, refunded);

            
            
            if (sourceamountaftersettlement == 0) {
                return 0;
            }
        }

        uint fee;
        uint exchangefeerate;
        uint sourcerate;
        uint destinationrate;

        (amountreceived, fee, exchangefeerate, sourcerate, destinationrate) = _getamountsforexchangeminusfees(
            sourceamountaftersettlement,
            sourcecurrencykey,
            destinationcurrencykey
        );

        
        if (_issynthrateinvalid(sourcecurrencykey, sourcerate)) {
            systemstatus().suspendsynth(sourcecurrencykey, circuit_breaker_suspension_reason);
            return 0;
        } else {
            lastexchangerate[sourcecurrencykey] = sourcerate;
        }

        if (_issynthrateinvalid(destinationcurrencykey, destinationrate)) {
            systemstatus().suspendsynth(destinationcurrencykey, circuit_breaker_suspension_reason);
            return 0;
        } else {
            lastexchangerate[destinationcurrencykey] = destinationrate;
        }

        
        

        
        issuer().synths(sourcecurrencykey).burn(from, sourceamountaftersettlement);

        
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
        returns (
            uint reclaimed,
            uint refunded,
            uint numentriessettled
        )
    {
        systemstatus().requiresynthactive(currencykey);
        return _internalsettle(from, currencykey);
    }

    function suspendsynthwithinvalidrate(bytes32 currencykey) external {
        systemstatus().requiresystemactive();
        require(issuer().synths(currencykey) != isynth(0), );
        require(_issynthrateinvalid(currencykey, exchangerates().rateforcurrency(currencykey)), );
        systemstatus().suspendsynth(currencykey, circuit_breaker_suspension_reason);
    }

    
    function setlastexchangerateforsynth(bytes32 currencykey, uint rate) external onlyexchangerates {
        require(rate > 0, );
        lastexchangerate[currencykey] = rate;
    }

    
    function _ensurecanexchange(
        bytes32 sourcecurrencykey,
        uint sourceamount,
        bytes32 destinationcurrencykey
    ) internal view {
        require(sourcecurrencykey != destinationcurrencykey, );
        require(sourceamount > 0, );

        bytes32[] memory synthkeys = new bytes32[](2);
        synthkeys[0] = sourcecurrencykey;
        synthkeys[1] = destinationcurrencykey;
        require(!exchangerates().anyrateisinvalid(synthkeys), );
    }

    function _issynthrateinvalid(bytes32 currencykey, uint currentrate) internal view returns (bool) {
        if (currentrate == 0) {
            return true;
        }

        uint lastratefromexchange = lastexchangerate[currencykey];

        if (lastratefromexchange > 0) {
            return _isdeviationabovethreshold(lastratefromexchange, currentrate);
        }

        
        (uint[] memory rates, ) = exchangerates().ratesandupdatedtimeforcurrencylastnrounds(currencykey, 4);

        
        for (uint i = 1; i < rates.length; i++) {
            
            if (rates[i] > 0 && _isdeviationabovethreshold(rates[i], currentrate)) {
                return true;
            }
        }

        return false;
    }

    function _isdeviationabovethreshold(uint base, uint comparison) internal view returns (bool) {
        if (base == 0 || comparison == 0) {
            return true;
        }

        uint factor;
        if (comparison > base) {
            factor = comparison.dividedecimal(base);
        } else {
            factor = base.dividedecimal(comparison);
        }

        return factor >= getpricedeviationthresholdfactor();
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

        (
            uint reclaimamount,
            uint rebateamount,
            uint entries,
            exchangeentrysettlement[] memory settlements
        ) = _settlementowing(from, currencykey);

        if (reclaimamount > rebateamount) {
            reclaimed = reclaimamount.sub(rebateamount);
            reclaim(from, currencykey, reclaimed);
        } else if (rebateamount > reclaimamount) {
            refunded = rebateamount.sub(reclaimamount);
            refund(from, currencykey, refunded);
        }

        
        for (uint i = 0; i < settlements.length; i++) {
            emit exchangeentrysettled(
                from,
                settlements[i].src,
                settlements[i].amount,
                settlements[i].dest,
                settlements[i].reclaim,
                settlements[i].rebate,
                settlements[i].srcroundidatperiodend,
                settlements[i].destroundidatperiodend,
                settlements[i].timestamp
            );
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
        uint _waitingperiodsecs = getwaitingperiodsecs();
        if (timestamp == 0 || now >= timestamp.add(_waitingperiodsecs)) {
            return 0;
        }

        return timestamp.add(_waitingperiodsecs).sub(now);
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
        return getexchangefeerate(destinationcurrencykey);
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
        (amountreceived, fee, exchangefeerate, , ) = _getamountsforexchangeminusfees(
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
            uint exchangefeerate,
            uint sourcerate,
            uint destinationrate
        )
    {
        uint destinationamount;
        (destinationamount, sourcerate, destinationrate) = exchangerates().effectivevalueandrates(
            sourcecurrencykey,
            sourceamount,
            destinationcurrencykey
        );
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

        emit exchangeentryappended(
            account,
            src,
            amount,
            dest,
            amountreceived,
            exchangefeerate,
            roundidforsrc,
            roundidfordest
        );
    }

    function getroundidsatperiodend(iexchangestate.exchangeentry memory exchangeentry)
        internal
        view
        returns (uint srcroundidatperiodend, uint destroundidatperiodend)
    {
        iexchangerates exrates = exchangerates();
        uint _waitingperiodsecs = getwaitingperiodsecs();

        srcroundidatperiodend = exrates.getlastroundidbeforeelapsedsecs(
            exchangeentry.src,
            exchangeentry.roundidforsrc,
            exchangeentry.timestamp,
            _waitingperiodsecs
        );
        destroundidatperiodend = exrates.getlastroundidbeforeelapsedsecs(
            exchangeentry.dest,
            exchangeentry.roundidfordest,
            exchangeentry.timestamp,
            _waitingperiodsecs
        );
    }

    

    modifier onlysynthetixorsynth() {
        isynthetix _synthetix = synthetix();
        require(
            msg.sender == address(_synthetix) || _synthetix.synthsbyaddress(msg.sender) != bytes32(0),
            
        );
        _;
    }

    modifier onlyexchangerates() {
        iexchangerates _exchangerates = exchangerates();
        require(msg.sender == address(_exchangerates), );
        _;
    }

    

    event exchangeentryappended(
        address indexed account,
        bytes32 src,
        uint256 amount,
        bytes32 dest,
        uint256 amountreceived,
        uint256 exchangefeerate,
        uint256 roundidforsrc,
        uint256 roundidfordest
    );

    event exchangeentrysettled(
        address indexed from,
        bytes32 src,
        uint256 amount,
        bytes32 dest,
        uint256 reclaim,
        uint256 rebate,
        uint256 srcroundidatperiodend,
        uint256 destroundidatperiodend,
        uint256 exchangetimestamp
    );
}
