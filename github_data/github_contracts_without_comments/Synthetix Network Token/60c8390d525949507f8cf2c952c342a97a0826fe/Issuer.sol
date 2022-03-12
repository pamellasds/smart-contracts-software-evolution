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
import ;
import ;
import ;
import ;



contract issuer is owned, mixinresolver, mixinsystemsettings, iissuer {
    using safemath for uint;
    using safedecimalmath for uint;

    bytes32 private constant susd = ;
    bytes32 public constant contract_name = ;
    bytes32 public constant last_issue_event = ;

    
    isynth[] public availablesynths;
    mapping(bytes32 => isynth) public synths;
    mapping(address => bytes32) public synthsbyaddress;

    

    bytes32 private constant contract_synthetix = ;
    bytes32 private constant contract_exchanger = ;
    bytes32 private constant contract_exrates = ;
    bytes32 private constant contract_synthetixstate = ;
    bytes32 private constant contract_feepool = ;
    bytes32 private constant contract_delegateapprovals = ;
    bytes32 private constant contract_ethercollateral = ;
    bytes32 private constant contract_rewardescrow = ;
    bytes32 private constant contract_synthetixescrow = ;
    bytes32 private constant contract_liquidations = ;

    bytes32[24] private addressestocache = [
        contract_synthetix,
        contract_exchanger,
        contract_exrates,
        contract_synthetixstate,
        contract_feepool,
        contract_delegateapprovals,
        contract_ethercollateral,
        contract_rewardescrow,
        contract_synthetixescrow,
        contract_liquidations
    ];

    constructor(address _owner, address _resolver)
        public
        owned(_owner)
        mixinresolver(_resolver, addressestocache)
        mixinsystemsettings()
    {}

    
    function synthetix() internal view returns (isynthetix) {
        return isynthetix(requireandgetaddress(contract_synthetix, ));
    }

    function synthetixerc20() internal view returns (ierc20) {
        return ierc20(requireandgetaddress(contract_synthetix, ));
    }

    function exchanger() internal view returns (iexchanger) {
        return iexchanger(requireandgetaddress(contract_exchanger, ));
    }

    function exchangerates() internal view returns (iexchangerates) {
        return iexchangerates(requireandgetaddress(contract_exrates, ));
    }

    function synthetixstate() internal view returns (isynthetixstate) {
        return isynthetixstate(requireandgetaddress(contract_synthetixstate, ));
    }

    function feepool() internal view returns (ifeepool) {
        return ifeepool(requireandgetaddress(contract_feepool, ));
    }

    function liquidations() internal view returns (iliquidations) {
        return iliquidations(requireandgetaddress(contract_liquidations, ));
    }

    function delegateapprovals() internal view returns (idelegateapprovals) {
        return idelegateapprovals(requireandgetaddress(contract_delegateapprovals, ));
    }

    function ethercollateral() internal view returns (iethercollateral) {
        return iethercollateral(requireandgetaddress(contract_ethercollateral, ));
    }

    function rewardescrow() internal view returns (irewardescrow) {
        return irewardescrow(requireandgetaddress(contract_rewardescrow, ));
    }

    function synthetixescrow() internal view returns (ihasbalance) {
        return ihasbalance(requireandgetaddress(contract_synthetixescrow, ));
    }

    function issuanceratio() external view returns (uint) {
        return getissuanceratio();
    }

    function _availablecurrencykeyswithoptionalsnx(bool withsnx) internal view returns (bytes32[] memory) {
        bytes32[] memory currencykeys = new bytes32[](availablesynths.length + (withsnx ? 1 : 0));

        for (uint i = 0; i < availablesynths.length; i++) {
            currencykeys[i] = synthsbyaddress[address(availablesynths[i])];
        }

        if (withsnx) {
            currencykeys[availablesynths.length] = ;
        }

        return currencykeys;
    }

    function _totalissuedsynths(bytes32 currencykey, bool excludeethercollateral)
        internal
        view
        returns (uint totalissued, bool anyrateisstale)
    {
        uint total = 0;
        uint currencyrate;

        bytes32[] memory synthsandsnx = _availablecurrencykeyswithoptionalsnx(true);

        
        (uint[] memory rates, bool anyratestale) = exchangerates().ratesandstaleforcurrencies(synthsandsnx);

        
        for (uint i = 0; i < synthsandsnx.length  1; i++) {
            bytes32 synth = synthsandsnx[i];
            if (synth == currencykey) {
                currencyrate = rates[i];
            }
            uint totalsynths = ierc20(address(synths[synth])).totalsupply();

            
            if (excludeethercollateral && synth == ) {
                totalsynths = totalsynths.sub(ethercollateral().totalissuedsynths());
            }

            uint synthvalue = totalsynths.multiplydecimalround(rates[i]);
            total = total.add(synthvalue);
        }

        if (currencykey == ) {
            
            currencyrate = rates[synthsandsnx.length  1];
        } else if (currencyrate == 0) {
            
            currencyrate = exchangerates().rateforcurrency(currencykey);
        }

        return (total.dividedecimalround(currencyrate), anyratestale);
    }

    function _debtbalanceofandtotaldebt(address _issuer, bytes32 currencykey)
        internal
        view
        returns (
            uint debtbalance,
            uint totalsystemvalue,
            bool anyrateisstale
        )
    {
        isynthetixstate state = synthetixstate();

        
        uint initialdebtownership;
        uint debtentryindex;
        (initialdebtownership, debtentryindex) = state.issuancedata(_issuer);

        
        (totalsystemvalue, anyrateisstale) = _totalissuedsynths(currencykey, true);

        
        
        
        if (initialdebtownership == 0) return (0, totalsystemvalue, anyrateisstale);

        
        
        uint currentdebtownership = state
            .lastdebtledgerentry()
            .dividedecimalroundprecise(state.debtledger(debtentryindex))
            .multiplydecimalroundprecise(initialdebtownership);

        
        uint highprecisionbalance = totalsystemvalue.decimaltoprecisedecimal().multiplydecimalroundprecise(
            currentdebtownership
        );

        
        debtbalance = highprecisionbalance.precisedecimaltodecimal();
    }

    function _canburnsynths(address account) internal view returns (bool) {
        return now >= _lastissueevent(account).add(getminimumstaketime());
    }

    function _lastissueevent(address account) internal view returns (uint) {
        
        return flexiblestorage().getuintvalue(contract_name, keccak256(abi.encodepacked(last_issue_event, account)));
    }

    function _remainingissuablesynths(address _issuer)
        internal
        view
        returns (
            uint maxissuable,
            uint alreadyissued,
            uint totalsystemdebt,
            bool anyrateisstale
        )
    {
        (alreadyissued, totalsystemdebt, anyrateisstale) = _debtbalanceofandtotaldebt(_issuer, susd);
        maxissuable = _maxissuablesynths(_issuer);

        if (alreadyissued >= maxissuable) {
            maxissuable = 0;
        } else {
            maxissuable = maxissuable.sub(alreadyissued);
        }
    }

    function _maxissuablesynths(address _issuer) internal view returns (uint) {
        
        uint destinationvalue = exchangerates().effectivevalue(, _collateral(_issuer), susd);

        
        return destinationvalue.multiplydecimal(getissuanceratio());
    }

    function _collateralisationratio(address _issuer) internal view returns (uint, bool) {
        uint totalownedsynthetix = _collateral(_issuer);

        (uint debtbalance, , bool anyrateisstale) = _debtbalanceofandtotaldebt(_issuer, );

        
        if (totalownedsynthetix == 0) return (0, anyrateisstale);

        return (debtbalance.dividedecimalround(totalownedsynthetix), anyrateisstale);
    }

    function _collateral(address account) internal view returns (uint) {
        uint balance = synthetixerc20().balanceof(account);

        if (address(synthetixescrow()) != address(0)) {
            balance = balance.add(synthetixescrow().balanceof(account));
        }

        if (address(rewardescrow()) != address(0)) {
            balance = balance.add(rewardescrow().balanceof(account));
        }

        return balance;
    }

    

    function minimumstaketime() external view returns (uint) {
        return getminimumstaketime();
    }

    function canburnsynths(address account) external view returns (bool) {
        return _canburnsynths(account);
    }

    function availablecurrencykeys() external view returns (bytes32[] memory) {
        return _availablecurrencykeyswithoptionalsnx(false);
    }

    function availablesynthcount() external view returns (uint) {
        return availablesynths.length;
    }

    function anysynthorsnxrateisstale() external view returns (bool anyratestale) {
        bytes32[] memory currencykeyswithsnx = _availablecurrencykeyswithoptionalsnx(true);

        (, anyratestale) = exchangerates().ratesandstaleforcurrencies(currencykeyswithsnx);
    }

    function totalissuedsynths(bytes32 currencykey, bool excludeethercollateral) external view returns (uint totalissued) {
        (totalissued, ) = _totalissuedsynths(currencykey, excludeethercollateral);
    }

    function lastissueevent(address account) external view returns (uint) {
        return _lastissueevent(account);
    }

    function collateralisationratio(address _issuer) external view returns (uint cratio) {
        (cratio, ) = _collateralisationratio(_issuer);
    }

    function collateralisationratioandanyratesstale(address _issuer)
        external
        view
        returns (uint cratio, bool anyrateisstale)
    {
        return _collateralisationratio(_issuer);
    }

    function collateral(address account) external view returns (uint) {
        return _collateral(account);
    }

    function debtbalanceof(address _issuer, bytes32 currencykey) external view returns (uint debtbalance) {
        isynthetixstate state = synthetixstate();

        
        (uint initialdebtownership, ) = state.issuancedata(_issuer);

        
        if (initialdebtownership == 0) return 0;

        (debtbalance, , ) = _debtbalanceofandtotaldebt(_issuer, currencykey);
    }

    function remainingissuablesynths(address _issuer)
        external
        view
        returns (
            uint maxissuable,
            uint alreadyissued,
            uint totalsystemdebt
        )
    {
        (maxissuable, alreadyissued, totalsystemdebt, ) = _remainingissuablesynths(_issuer);
    }

    function maxissuablesynths(address _issuer) external view returns (uint) {
        return _maxissuablesynths(_issuer);
    }

    function transferablesynthetixandanyrateisstale(address account, uint balance)
        external
        view
        returns (uint transferable, bool anyrateisstale)
    {
        
        
        

        
        
        
        
        uint debtbalance;
        (debtbalance, , anyrateisstale) = _debtbalanceofandtotaldebt(account, );
        uint lockedsynthetixvalue = debtbalance.dividedecimalround(getissuanceratio());

        
        if (lockedsynthetixvalue >= balance) {
            transferable = 0;
        } else {
            transferable = balance.sub(lockedsynthetixvalue);
        }
    }

    

    function addsynth(isynth synth) external onlyowner {
        bytes32 currencykey = synth.currencykey();

        require(synths[currencykey] == isynth(0), );
        require(synthsbyaddress[address(synth)] == bytes32(0), );

        availablesynths.push(synth);
        synths[currencykey] = synth;
        synthsbyaddress[address(synth)] = currencykey;

        emit synthadded(currencykey, address(synth));
    }

    function removesynth(bytes32 currencykey) external onlyowner {
        require(address(synths[currencykey]) != address(0), );
        require(ierc20(address(synths[currencykey])).totalsupply() == 0, );
        require(currencykey != susd, );

        
        address synthtoremove = address(synths[currencykey]);

        
        for (uint i = 0; i < availablesynths.length; i++) {
            if (address(availablesynths[i]) == synthtoremove) {
                delete availablesynths[i];

                
                
                
                availablesynths[i] = availablesynths[availablesynths.length  1];

                
                availablesynths.length;

                break;
            }
        }

        
        delete synthsbyaddress[address(synths[currencykey])];
        delete synths[currencykey];

        emit synthremoved(currencykey, synthtoremove);
    }

    function issuesynthsonbehalf(
        address issueforaddress,
        address from,
        uint amount
    ) external onlysynthetix {
        require(delegateapprovals().canissuefor(issueforaddress, from), );

        (uint maxissuable, uint existingdebt, uint totalsystemdebt, bool anyrateisstale) = _remainingissuablesynths(
            issueforaddress
        );

        require(!anyrateisstale, );

        require(amount <= maxissuable, );

        _internalissuesynths(issueforaddress, amount, existingdebt, totalsystemdebt);
    }

    function issuemaxsynthsonbehalf(address issueforaddress, address from) external onlysynthetix {
        require(delegateapprovals().canissuefor(issueforaddress, from), );

        (uint maxissuable, uint existingdebt, uint totalsystemdebt, bool anyrateisstale) = _remainingissuablesynths(
            issueforaddress
        );

        require(!anyrateisstale, );

        _internalissuesynths(issueforaddress, maxissuable, existingdebt, totalsystemdebt);
    }

    function issuesynths(address from, uint amount) external onlysynthetix {
        
        (uint maxissuable, uint existingdebt, uint totalsystemdebt, bool anyrateisstale) = _remainingissuablesynths(from);

        require(!anyrateisstale, );

        require(amount <= maxissuable, );

        _internalissuesynths(from, amount, existingdebt, totalsystemdebt);
    }

    function issuemaxsynths(address from) external onlysynthetix {
        
        (uint maxissuable, uint existingdebt, uint totalsystemdebt, bool anyrateisstale) = _remainingissuablesynths(from);

        require(!anyrateisstale, );

        _internalissuesynths(from, maxissuable, existingdebt, totalsystemdebt);
    }

    function burnsynthsonbehalf(
        address burnforaddress,
        address from,
        uint amount
    ) external onlysynthetix {
        require(delegateapprovals().canburnfor(burnforaddress, from), );
        _burnsynths(burnforaddress, amount);
    }

    function burnsynths(address from, uint amount) external onlysynthetix {
        _burnsynths(from, amount);
    }

    

    function _internalissuesynths(
        address from,
        uint amount,
        uint existingdebt,
        uint totalsystemdebt
    ) internal {
        
        _addtodebtregister(from, amount, existingdebt, totalsystemdebt);

        
        _setlastissueevent(from);

        
        synths[susd].issue(from, amount);

        
        _appendaccountissuancerecord(from);
    }

    
    function _burnsynths(address from, uint amount) internal {
        require(_canburnsynths(from), );

        
        (, uint refunded, uint numentriessettled) = exchanger().settle(from, susd);

        
        (uint existingdebt, uint totalsystemvalue, bool anyrateisstale) = _debtbalanceofandtotaldebt(from, susd);

        require(!anyrateisstale, );

        require(existingdebt > 0, );

        uint debttoremoveaftersettlement = amount;

        if (numentriessettled > 0) {
            debttoremoveaftersettlement = exchanger().calculateamountaftersettlement(from, susd, amount, refunded);
        }

        uint maxissuablesynthsforaccount = _maxissuablesynths(from);

        _internalburnsynths(from, debttoremoveaftersettlement, existingdebt, totalsystemvalue, maxissuablesynthsforaccount);
    }

    function _burnsynthsforliquidation(
        address burnforaddress,
        address liquidator,
        uint amount,
        uint existingdebt,
        uint totaldebtissued
    ) internal {
        

        
        _removefromdebtregister(burnforaddress, amount, existingdebt, totaldebtissued);

        
        synths[susd].burn(liquidator, amount);

        
        _appendaccountissuancerecord(burnforaddress);
    }

    function burnsynthstotargetonbehalf(address burnforaddress, address from) external onlysynthetix {
        require(delegateapprovals().canburnfor(burnforaddress, from), );
        _burnsynthstotarget(burnforaddress);
    }

    function burnsynthstotarget(address from) external onlysynthetix {
        _burnsynthstotarget(from);
    }

    
    
    function _burnsynthstotarget(address from) internal {
        
        (uint existingdebt, uint totalsystemvalue, bool anyrateisstale) = _debtbalanceofandtotaldebt(from, susd);

        require(!anyrateisstale, );

        require(existingdebt > 0, );

        uint maxissuablesynthsforaccount = _maxissuablesynths(from);

        
        uint amounttoburntotarget = existingdebt.sub(maxissuablesynthsforaccount);

        
        _internalburnsynths(from, amounttoburntotarget, existingdebt, totalsystemvalue, maxissuablesynthsforaccount);
    }

    function _internalburnsynths(
        address from,
        uint amount,
        uint existingdebt,
        uint totalsystemvalue,
        uint maxissuablesynthsforaccount
    ) internal {
        
        
        uint amounttoremove = existingdebt < amount ? existingdebt : amount;

        
        _removefromdebtregister(from, amounttoremove, existingdebt, totalsystemvalue);

        uint amounttoburn = amounttoremove;

        
        synths[susd].burn(from, amounttoburn);

        
        _appendaccountissuancerecord(from);

        
        
        if (existingdebt.sub(amounttoburn) <= maxissuablesynthsforaccount) {
            liquidations().removeaccountinliquidation(from);
        }
    }

    function liquidatedelinquentaccount(
        address account,
        uint susdamount,
        address liquidator
    ) external onlysynthetix returns (uint totalredeemed, uint amounttoliquidate) {
        
        require(!exchanger().haswaitingperiodorsettlementowing(liquidator, susd), );
        iliquidations _liquidations = liquidations();

        
        require(_liquidations.isopenforliquidation(account), );

        
        require(ierc20(address(synths[susd])).balanceof(liquidator) >= susdamount, );

        uint liquidationpenalty = _liquidations.liquidationpenalty();

        uint collateralforaccount = _collateral(account);

        
        uint collateralvalue = exchangerates().effectivevalue(, collateralforaccount, susd);

        
        (uint debtbalance, uint totaldebtissued, bool anyrateisstale) = _debtbalanceofandtotaldebt(account, susd);

        require(!anyrateisstale, );

        uint amounttofixratio = _liquidations.calculateamounttofixcollateral(debtbalance, collateralvalue);

        
        amounttoliquidate = amounttofixratio < susdamount ? amounttofixratio : susdamount;

        
        uint snxredeemed = exchangerates().effectivevalue(susd, amounttoliquidate, );

        
        totalredeemed = snxredeemed.multiplydecimal(safedecimalmath.unit().add(liquidationpenalty));

        
        
        
        if (totalredeemed > collateralforaccount) {
            
            totalredeemed = collateralforaccount;

            
            amounttoliquidate = exchangerates().effectivevalue(
                ,
                collateralforaccount.dividedecimal(safedecimalmath.unit().add(liquidationpenalty)),
                susd
            );
        }

        
        _burnsynthsforliquidation(account, liquidator, amounttoliquidate, debtbalance, totaldebtissued);

        if (amounttoliquidate == amounttofixratio) {
            
            _liquidations.removeaccountinliquidation(account);
        }
    }

    function _setlastissueevent(address account) internal {
        
        flexiblestorage().setuintvalue(
            contract_name,
            keccak256(abi.encodepacked(last_issue_event, account)),
            block.timestamp
        );
    }

    function _appendaccountissuancerecord(address from) internal {
        uint initialdebtownership;
        uint debtentryindex;
        (initialdebtownership, debtentryindex) = synthetixstate().issuancedata(from);

        feepool().appendaccountissuancerecord(from, initialdebtownership, debtentryindex);
    }

    function _addtodebtregister(
        address from,
        uint amount,
        uint existingdebt,
        uint totaldebtissued
    ) internal {
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

    function _removefromdebtregister(
        address from,
        uint amount,
        uint existingdebt,
        uint totaldebtissued
    ) internal {
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

    

    event synthadded(bytes32 currencykey, address synth);
    event synthremoved(bytes32 currencykey, address synth);
}
