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



contract synthetix is externstatetoken, mixinresolver {
    

    
    synth[] public availablesynths;
    mapping(bytes32 => synth) public synths;
    mapping(address => bytes32) public synthsbyaddress;

    string constant token_name = ;
    string constant token_symbol = ;
    uint8 constant decimals = 18;
    bytes32 constant susd = ;

    

    bytes32 private constant contract_systemstatus = ;
    bytes32 private constant contract_exchanger = ;
    bytes32 private constant contract_ethercollateral = ;
    bytes32 private constant contract_issuer = ;
    bytes32 private constant contract_synthetixstate = ;
    bytes32 private constant contract_exrates = ;
    bytes32 private constant contract_feepool = ;
    bytes32 private constant contract_supplyschedule = ;
    bytes32 private constant contract_rewardescrow = ;
    bytes32 private constant contract_synthetixescrow = ;
    bytes32 private constant contract_rewardsdistribution = ;

    bytes32[24] private addressestocache = [
        contract_systemstatus,
        contract_exchanger,
        contract_ethercollateral,
        contract_issuer,
        contract_synthetixstate,
        contract_exrates,
        contract_feepool,
        contract_supplyschedule,
        contract_rewardescrow,
        contract_synthetixescrow,
        contract_rewardsdistribution
    ];

    

    constructor(
        address payable _proxy,
        tokenstate _tokenstate,
        address _owner,
        uint _totalsupply,
        address _resolver
    )
        public
        externstatetoken(_proxy, _tokenstate, token_name, token_symbol, _totalsupply, decimals, _owner)
        mixinresolver(_resolver, addressestocache)
    {}

    

    function systemstatus() internal view returns (isystemstatus) {
        return isystemstatus(requireandgetaddress(contract_systemstatus, ));
    }

    function exchanger() internal view returns (iexchanger) {
        return iexchanger(requireandgetaddress(contract_exchanger, ));
    }

    function ethercollateral() internal view returns (iethercollateral) {
        return iethercollateral(requireandgetaddress(contract_ethercollateral, ));
    }

    function issuer() internal view returns (iissuer) {
        return iissuer(requireandgetaddress(contract_issuer, ));
    }

    function synthetixstate() internal view returns (isynthetixstate) {
        return isynthetixstate(requireandgetaddress(contract_synthetixstate, ));
    }

    function exchangerates() internal view returns (iexchangerates) {
        return iexchangerates(requireandgetaddress(contract_exrates, ));
    }

    function feepool() internal view returns (ifeepool) {
        return ifeepool(requireandgetaddress(contract_feepool, ));
    }

    function supplyschedule() internal view returns (supplyschedule) {
        return supplyschedule(requireandgetaddress(contract_supplyschedule, ));
    }

    function rewardescrow() internal view returns (isynthetixescrow) {
        return isynthetixescrow(requireandgetaddress(contract_rewardescrow, ));
    }

    function synthetixescrow() internal view returns (isynthetixescrow) {
        return isynthetixescrow(requireandgetaddress(contract_synthetixescrow, ));
    }

    function rewardsdistribution() internal view returns (irewardsdistribution) {
        return
            irewardsdistribution(requireandgetaddress(contract_rewardsdistribution, ));
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

    
    function availablecurrencykeys() public view returns (bytes32[] memory) {
        bytes32[] memory currencykeys = new bytes32[](availablesynths.length);

        for (uint i = 0; i < availablesynths.length; i++) {
            currencykeys[i] = synthsbyaddress[address(availablesynths[i])];
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
        require(synthsbyaddress[address(synth)] == bytes32(0), );

        availablesynths.push(synth);
        synths[currencykey] = synth;
        synthsbyaddress[address(synth)] = currencykey;
    }

    
    function removesynth(bytes32 currencykey) external optionalproxy_onlyowner {
        require(address(synths[currencykey]) != address(0), );
        require(synths[currencykey].totalsupply() == 0, );
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

        
        
        
    }

    
    function transfer(address to, uint value) public optionalproxy returns (bool) {
        systemstatus().requiresystemactive();

        
        require(value <= transferablesynthetix(messagesender), );

        
        _transfer_byproxy(messagesender, to, value);

        return true;
    }

    
    function transferfrom(
        address from,
        address to,
        uint value
    ) public optionalproxy returns (bool) {
        systemstatus().requiresystemactive();

        
        require(value <= transferablesynthetix(from), );

        
        
        return _transferfrom_byproxy(messagesender, from, to, value);
    }

    function issuesynths(uint amount) external optionalproxy {
        systemstatus().requireissuanceactive();

        return issuer().issuesynths(messagesender, amount);
    }

    function issuesynthsonbehalf(address issueforaddress, uint amount) external optionalproxy {
        systemstatus().requireissuanceactive();

        return issuer().issuesynthsonbehalf(issueforaddress, messagesender, amount);
    }

    function issuemaxsynths() external optionalproxy {
        systemstatus().requireissuanceactive();

        return issuer().issuemaxsynths(messagesender);
    }

    function issuemaxsynthsonbehalf(address issueforaddress) external optionalproxy {
        systemstatus().requireissuanceactive();

        return issuer().issuemaxsynthsonbehalf(issueforaddress, messagesender);
    }

    function burnsynths(uint amount) external optionalproxy {
        systemstatus().requireissuanceactive();

        return issuer().burnsynths(messagesender, amount);
    }

    function burnsynthsonbehalf(address burnforaddress, uint amount) external optionalproxy {
        systemstatus().requireissuanceactive();

        return issuer().burnsynthsonbehalf(burnforaddress, messagesender, amount);
    }

    function burnsynthstotarget() external optionalproxy {
        systemstatus().requireissuanceactive();

        return issuer().burnsynthstotarget(messagesender);
    }

    function burnsynthstotargetonbehalf(address burnforaddress) external optionalproxy {
        systemstatus().requireissuanceactive();

        return issuer().burnsynthstotargetonbehalf(burnforaddress, messagesender);
    }

    function exchange(
        bytes32 sourcecurrencykey,
        uint sourceamount,
        bytes32 destinationcurrencykey
    ) external optionalproxy returns (uint amountreceived) {
        systemstatus().requireexchangeactive();

        systemstatus().requiresynthsactive(sourcecurrencykey, destinationcurrencykey);

        return exchanger().exchange(messagesender, sourcecurrencykey, sourceamount, destinationcurrencykey, messagesender);
    }

    function exchangeonbehalf(
        address exchangeforaddress,
        bytes32 sourcecurrencykey,
        uint sourceamount,
        bytes32 destinationcurrencykey
    ) external optionalproxy returns (uint amountreceived) {
        systemstatus().requireexchangeactive();

        systemstatus().requiresynthsactive(sourcecurrencykey, destinationcurrencykey);

        return
            exchanger().exchangeonbehalf(
                exchangeforaddress,
                messagesender,
                sourcecurrencykey,
                sourceamount,
                destinationcurrencykey
            );
    }

    function settle(bytes32 currencykey)
        external
        optionalproxy
        returns (
            uint reclaimed,
            uint refunded,
            uint numentriessettled
        )
    {
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

        
        (uint initialdebtownership, ) = state.issuancedata(_issuer);

        
        if (initialdebtownership == 0) return 0;

        (uint debtbalance, ) = debtbalanceofandtotaldebt(_issuer, currencykey);
        return debtbalance;
    }

    function debtbalanceofandtotaldebt(address _issuer, bytes32 currencykey)
        public
        view
        returns (uint debtbalance, uint totalsystemvalue)
    {
        isynthetixstate state = synthetixstate();

        
        uint initialdebtownership;
        uint debtentryindex;
        (initialdebtownership, debtentryindex) = state.issuancedata(_issuer);

        
        totalsystemvalue = totalissuedsynthsexcludeethercollateral(currencykey);

        
        if (initialdebtownership == 0) return (0, totalsystemvalue);

        
        
        uint currentdebtownership = state
            .lastdebtledgerentry()
            .dividedecimalroundprecise(state.debtledger(debtentryindex))
            .multiplydecimalroundprecise(initialdebtownership);

        
        uint highprecisionbalance = totalsystemvalue.decimaltoprecisedecimal().multiplydecimalroundprecise(
            currentdebtownership
        );

        
        debtbalance = highprecisionbalance.precisedecimaltodecimal();
    }

    
    function remainingissuablesynths(address _issuer)
        public
        view
        returns (
            
            uint maxissuable,
            uint alreadyissued,
            uint totalsystemdebt
        )
    {
        (alreadyissued, totalsystemdebt) = debtbalanceofandtotaldebt(_issuer, susd);
        maxissuable = maxissuablesynths(_issuer);

        if (alreadyissued >= maxissuable) {
            maxissuable = 0;
        } else {
            maxissuable = maxissuable.sub(alreadyissued);
        }
    }

    
    function collateral(address account) public view returns (uint) {
        uint balance = tokenstate.balanceof(account);

        if (address(synthetixescrow()) != address(0)) {
            balance = balance.add(synthetixescrow().balanceof(account));
        }

        if (address(rewardescrow()) != address(0)) {
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
        require(address(rewardsdistribution()) != address(0), );

        systemstatus().requireissuanceactive();

        supplyschedule _supplyschedule = supplyschedule();
        irewardsdistribution _rewardsdistribution = rewardsdistribution();

        uint supplytomint = _supplyschedule.mintablesupply();
        require(supplytomint > 0, );

        
        _supplyschedule.recordmintevent(supplytomint);

        
        
        uint minterreward = _supplyschedule.minterreward();
        
        uint amounttodistribute = supplytomint.sub(minterreward);

        
        tokenstate.setbalanceof(
            address(_rewardsdistribution),
            tokenstate.balanceof(address(_rewardsdistribution)).add(amounttodistribute)
        );
        emittransfer(address(this), address(_rewardsdistribution), amounttodistribute);

        
        _rewardsdistribution.distributerewards(amounttodistribute);

        
        tokenstate.setbalanceof(msg.sender, tokenstate.balanceof(msg.sender).add(minterreward));
        emittransfer(address(this), msg.sender, minterreward);

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
            addresstobytes32(account),
            0,
            0
        );
    }

    event exchangereclaim(address indexed account, bytes32 currencykey, uint amount);
    bytes32 constant exchangereclaim_sig = keccak256();

    function emitexchangereclaim(
        address account,
        bytes32 currencykey,
        uint256 amount
    ) external onlyexchanger {
        proxy._emit(abi.encode(currencykey, amount), 2, exchangereclaim_sig, addresstobytes32(account), 0, 0);
    }

    event exchangerebate(address indexed account, bytes32 currencykey, uint amount);
    bytes32 constant exchangerebate_sig = keccak256();

    function emitexchangerebate(
        address account,
        bytes32 currencykey,
        uint256 amount
    ) external onlyexchanger {
        proxy._emit(abi.encode(currencykey, amount), 2, exchangerebate_sig, addresstobytes32(account), 0, 0);
    }
}
