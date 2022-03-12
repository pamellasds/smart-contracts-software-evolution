pragma solidity 0.4.25;

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



contract synthetix is externstatetoken, mixinresolver {
    

    
    synth[] public availablesynths;
    mapping(bytes32 => synth) public synths;
    mapping(address => bytes32) public synthsbyaddress;

    string constant token_name = ;
    string constant token_symbol = ;
    uint8 constant decimals = 18;
    bytes32 constant susd = ;

    

    
    constructor(address _proxy, tokenstate _tokenstate, address _owner, uint _totalsupply, address _resolver)
        public
        externstatetoken(_proxy, _tokenstate, token_name, token_symbol, _totalsupply, decimals, _owner)
        mixinresolver(_owner, _resolver)
    {}

    

    function exchanger() internal view returns (iexchanger) {
        return iexchanger(resolver.requireandgetaddress(, ));
    }

    function ethercollateral() internal view returns (iethercollateral) {
        return iethercollateral(resolver.requireandgetaddress(, ));
    }

    function issuer() internal view returns (iissuer) {
        return iissuer(resolver.requireandgetaddress(, ));
    }

    function synthetixstate() internal view returns (isynthetixstate) {
        return isynthetixstate(resolver.requireandgetaddress(, ));
    }

    function exchangerates() internal view returns (iexchangerates) {
        return iexchangerates(resolver.requireandgetaddress(, ));
    }

    function feepool() internal view returns (ifeepool) {
        return ifeepool(resolver.requireandgetaddress(, ));
    }

    function supplyschedule() internal view returns (supplyschedule) {
        return supplyschedule(resolver.requireandgetaddress(, ));
    }

    function rewardescrow() internal view returns (isynthetixescrow) {
        return isynthetixescrow(resolver.requireandgetaddress(, ));
    }

    function synthetixescrow() internal view returns (isynthetixescrow) {
        return isynthetixescrow(resolver.requireandgetaddress(, ));
    }

    function rewardsdistribution() internal view returns (irewardsdistribution) {
        return
            irewardsdistribution(
                resolver.requireandgetaddress(, )
            );
    }

    
    function _totalissuedsynths(bytes32 currencykey, bool excludeethercollateral) internal view returns (uint) {
        iexchangerates exrates = exchangerates();
        uint total = 0;
        uint currencyrate = exrates.rateforcurrency(currencykey);

        (uint[] memory rates, bool anyratestale) = exrates.ratesandstaleforcurrencies(availablecurrencykeys());
        require(!anyratestale, );

        for (uint i = 0; i < availablesynths.length; i++) {
            
            
            
            
            uint totalsynths = availablesynths[i].totalsupply();

            
            if (excludeethercollateral && availablesynths[i] == synths[]) {
                totalsynths = totalsynths.sub(ethercollateral().totalissuedsynths());
            }

            uint synthvalue = totalsynths.multiplydecimalround(rates[i]);
            total = total.add(synthvalue);
        }

        return total.dividedecimalround(currencyrate);
    }

    
    function totalissuedsynths(bytes32 currencykey) public view returns (uint) {
        return _totalissuedsynths(currencykey, false);
    }

    
    function totalissuedsynthsexcludeethercollateral(bytes32 currencykey) public view returns (uint) {
        return _totalissuedsynths(currencykey, true);
    }

    
    function availablecurrencykeys() public view returns (bytes32[]) {
        bytes32[] memory currencykeys = new bytes32[](availablesynths.length);

        for (uint i = 0; i < availablesynths.length; i++) {
            currencykeys[i] = synthsbyaddress[availablesynths[i]];
        }

        return currencykeys;
    }

    
    function availablesynthcount() public view returns (uint) {
        return availablesynths.length;
    }

    function iswaitingperiod(bytes32 currencykey) external view returns (bool) {
        return exchanger().maxsecsleftinwaitingperiod(messagesender, currencykey) > 0;
    }

    

    
    function addsynth(synth synth) external optionalproxy_onlyowner {
        bytes32 currencykey = synth.currencykey();

        require(synths[currencykey] == synth(0), );
        require(synthsbyaddress[synth] == bytes32(0), );

        availablesynths.push(synth);
        synths[currencykey] = synth;
        synthsbyaddress[synth] = currencykey;
    }

    
    function removesynth(bytes32 currencykey) external optionalproxy_onlyowner {
        require(synths[currencykey] != address(0), );
        require(synths[currencykey].totalsupply() == 0, );
        require(currencykey != susd, );

        
        address synthtoremove = synths[currencykey];

        
        for (uint i = 0; i < availablesynths.length; i++) {
            if (availablesynths[i] == synthtoremove) {
                delete availablesynths[i];

                
                
                
                availablesynths[i] = availablesynths[availablesynths.length  1];

                
                availablesynths.length;

                break;
            }
        }

        
        delete synthsbyaddress[synths[currencykey]];
        delete synths[currencykey];

        
        
        
    }

    
    function transfer(address to, uint value) public optionalproxy returns (bool) {
        
        require(value <= transferablesynthetix(messagesender), );

        
        _transfer_byproxy(messagesender, to, value);

        return true;
    }

    
    function transferfrom(address from, address to, uint value) public optionalproxy returns (bool) {
        
        require(value <= transferablesynthetix(from), );

        
        
        return _transferfrom_byproxy(messagesender, from, to, value);
    }

    function issuesynths(uint amount) external optionalproxy {
        return issuer().issuesynths(messagesender, amount);
    }

    function issuemaxsynths() external optionalproxy {
        return issuer().issuemaxsynths(messagesender);
    }

    function burnsynths(uint amount) external optionalproxy {
        return issuer().burnsynths(messagesender, amount);
    }

    function exchange(bytes32 sourcecurrencykey, uint sourceamount, bytes32 destinationcurrencykey)
        external
        optionalproxy
        returns (uint amountreceived)
    {
        return exchanger().exchange(messagesender, sourcecurrencykey, sourceamount, destinationcurrencykey, messagesender);
    }

    function settle(bytes32 currencykey) external optionalproxy returns (uint reclaimed, uint refunded) {
        return exchanger().settle(messagesender, currencykey);
    }

    

    
    function maxissuablesynths(address _issuer)
        public
        view
        returns (
            
            uint
        )
    {
        
        uint destinationvalue = exchangerates().effectivevalue(, collateral(_issuer), susd);

        
        return destinationvalue.multiplydecimal(synthetixstate().issuanceratio());
    }

    
    function collateralisationratio(address _issuer) public view returns (uint) {
        uint totalownedsynthetix = collateral(_issuer);
        if (totalownedsynthetix == 0) return 0;

        uint debtbalance = debtbalanceof(_issuer, );
        return debtbalance.dividedecimalround(totalownedsynthetix);
    }

    
    function debtbalanceof(address _issuer, bytes32 currencykey)
        public
        view
        returns (
            
            uint
        )
    {
        isynthetixstate state = synthetixstate();

        
        uint initialdebtownership;
        uint debtentryindex;
        (initialdebtownership, debtentryindex) = state.issuancedata(_issuer);

        
        if (initialdebtownership == 0) return 0;

        
        
        uint currentdebtownership = state
            .lastdebtledgerentry()
            .dividedecimalroundprecise(state.debtledger(debtentryindex))
            .multiplydecimalroundprecise(initialdebtownership);

        
        uint totalsystemvalue = totalissuedsynthsexcludeethercollateral(currencykey);

        
        uint highprecisionbalance = totalsystemvalue.decimaltoprecisedecimal().multiplydecimalroundprecise(
            currentdebtownership
        );

        
        return highprecisionbalance.precisedecimaltodecimal();
    }

    
    function remainingissuablesynths(address _issuer)
        public
        view
        returns (
            
            uint,
            uint
        )
    {
        uint alreadyissued = debtbalanceof(_issuer, susd);
        uint maxissuable = maxissuablesynths(_issuer);

        if (alreadyissued >= maxissuable) {
            maxissuable = 0;
        } else {
            maxissuable = maxissuable.sub(alreadyissued);
        }
        return (maxissuable, alreadyissued);
    }

    
    function collateral(address account) public view returns (uint) {
        uint balance = tokenstate.balanceof(account);

        if (synthetixescrow() != address(0)) {
            balance = balance.add(synthetixescrow().balanceof(account));
        }

        if (rewardescrow() != address(0)) {
            balance = balance.add(rewardescrow().balanceof(account));
        }

        return balance;
    }

    
    function transferablesynthetix(address account)
        public
        view
        ratenotstale() 
        returns (uint)
    {
        
        
        
        uint balance = tokenstate.balanceof(account);

        
        
        
        
        uint lockedsynthetixvalue = debtbalanceof(account, ).dividedecimalround(synthetixstate().issuanceratio());

        
        if (lockedsynthetixvalue >= balance) {
            return 0;
        } else {
            return balance.sub(lockedsynthetixvalue);
        }
    }

    
    function mint() external returns (bool) {
        require(rewardsdistribution() != address(0), );

        supplyschedule _supplyschedule = supplyschedule();
        irewardsdistribution _rewardsdistribution = rewardsdistribution();

        uint supplytomint = _supplyschedule.mintablesupply();
        require(supplytomint > 0, );

        
        _supplyschedule.recordmintevent(supplytomint);

        
        
        uint minterreward = _supplyschedule.minterreward();
        
        uint amounttodistribute = supplytomint.sub(minterreward);

        
        tokenstate.setbalanceof(_rewardsdistribution, tokenstate.balanceof(_rewardsdistribution).add(amounttodistribute));
        emittransfer(this, _rewardsdistribution, amounttodistribute);

        
        _rewardsdistribution.distributerewards(amounttodistribute);

        
        tokenstate.setbalanceof(msg.sender, tokenstate.balanceof(msg.sender).add(minterreward));
        emittransfer(this, msg.sender, minterreward);

        totalsupply = totalsupply.add(supplytomint);

        return true;
    }

    

    modifier ratenotstale(bytes32 currencykey) {
        require(!exchangerates().rateisstale(currencykey), );
        _;
    }

    modifier onlyexchanger() {
        require(msg.sender == address(exchanger()), );
        _;
    }

    
    
    event synthexchange(
        address indexed account,
        bytes32 fromcurrencykey,
        uint256 fromamount,
        bytes32 tocurrencykey,
        uint256 toamount,
        address toaddress
    );
    bytes32 constant synthexchange_sig = keccak256();

    function emitsynthexchange(
        address account,
        bytes32 fromcurrencykey,
        uint256 fromamount,
        bytes32 tocurrencykey,
        uint256 toamount,
        address toaddress
    ) external onlyexchanger {
        proxy._emit(
            abi.encode(fromcurrencykey, fromamount, tocurrencykey, toamount, toaddress),
            2,
            synthexchange_sig,
            bytes32(account),
            0,
            0
        );
    }

    event exchangereclaim(address indexed account, bytes32 currencykey, uint amount);
    bytes32 constant exchangereclaim_sig = keccak256();

    function emitexchangereclaim(address account, bytes32 currencykey, uint256 amount) external onlyexchanger {
        proxy._emit(abi.encode(currencykey, amount), 2, exchangereclaim_sig, bytes32(account), 0, 0);
    }

    event exchangerebate(address indexed account, bytes32 currencykey, uint amount);
    bytes32 constant exchangerebate_sig = keccak256();

    function emitexchangerebate(address account, bytes32 currencykey, uint256 amount) external onlyexchanger {
        proxy._emit(abi.encode(currencykey, amount), 2, exchangerebate_sig, bytes32(account), 0, 0);
    }
    
}
