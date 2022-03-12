

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


contract synthetix is externstatetoken {

    

    
    synth[] public availablesynths;
    mapping(bytes32 => synth) public synths;

    ifeepool public feepool;
    isynthetixescrow public escrow;
    isynthetixescrow public rewardescrow;
    exchangerates public exchangerates;
    synthetixstate public synthetixstate;
    supplyschedule public supplyschedule;
    irewardsdistribution public rewardsdistribution;

    bool private protectioncircuit = false;

    string constant token_name = ;
    string constant token_symbol = ;
    uint8 constant decimals = 18;
    bool public exchangeenabled = true;
    uint public gaspricelimit;

    address public gaslimitoracle;
    

    
    constructor(address _proxy, tokenstate _tokenstate, synthetixstate _synthetixstate,
        address _owner, exchangerates _exchangerates, ifeepool _feepool, supplyschedule _supplyschedule,
        isynthetixescrow _rewardescrow, isynthetixescrow _escrow, irewardsdistribution _rewardsdistribution, uint _totalsupply
    )
        externstatetoken(_proxy, _tokenstate, token_name, token_symbol, _totalsupply, decimals, _owner)
        public
    {
        synthetixstate = _synthetixstate;
        exchangerates = _exchangerates;
        feepool = _feepool;
        supplyschedule = _supplyschedule;
        rewardescrow = _rewardescrow;
        escrow = _escrow;
        rewardsdistribution = _rewardsdistribution;
    }
    

    function setfeepool(ifeepool _feepool)
        external
        optionalproxy_onlyowner
    {
        feepool = _feepool;
    }

    function setexchangerates(exchangerates _exchangerates)
        external
        optionalproxy_onlyowner
    {
        exchangerates = _exchangerates;
    }

    function setprotectioncircuit(bool _protectioncircuitisactivated)
        external
        onlyoracle
    {
        protectioncircuit = _protectioncircuitisactivated;
    }

    function setexchangeenabled(bool _exchangeenabled)
        external
        optionalproxy_onlyowner
    {
        exchangeenabled = _exchangeenabled;
    }

    function setgaslimitoracle(address _gaslimitoracle)
        external
        optionalproxy_onlyowner
    {
        gaslimitoracle = _gaslimitoracle;
    }

    function setgaspricelimit(uint _gaspricelimit)
        external
    {
        require(msg.sender == gaslimitoracle, );
        require(_gaspricelimit > 0, );
        gaspricelimit = _gaspricelimit;
    }

    
    function addsynth(synth synth)
        external
        optionalproxy_onlyowner
    {
        bytes32 currencykey = synth.currencykey();

        require(synths[currencykey] == synth(0), );

        availablesynths.push(synth);
        synths[currencykey] = synth;
    }

    
    function removesynth(bytes32 currencykey)
        external
        optionalproxy_onlyowner
    {
        require(synths[currencykey] != address(0), );
        require(synths[currencykey].totalsupply() == 0, );
        require(currencykey != , );

        
        address synthtoremove = synths[currencykey];

        
        for (uint8 i = 0; i < availablesynths.length; i++) {
            if (availablesynths[i] == synthtoremove) {
                delete availablesynths[i];

                
                
                
                availablesynths[i] = availablesynths[availablesynths.length  1];

                
                availablesynths.length;

                break;
            }
        }

        
        delete synths[currencykey];

        
        
        
    }

    

    
    function effectivevalue(bytes32 sourcecurrencykey, uint sourceamount, bytes32 destinationcurrencykey)
        public
        view
        returns (uint)
    {
        return exchangerates.effectivevalue(sourcecurrencykey, sourceamount, destinationcurrencykey);
    }

    
    function totalissuedsynths(bytes32 currencykey)
        public
        view
        returns (uint)
    {
        uint total = 0;
        uint currencyrate = exchangerates.rateforcurrency(currencykey);

        require(!exchangerates.anyrateisstale(availablecurrencykeys()), );

        for (uint8 i = 0; i < availablesynths.length; i++) {
            
            
            
            
            uint synthvalue = availablesynths[i].totalsupply()
                .multiplydecimalround(exchangerates.rateforcurrency(availablesynths[i].currencykey()))
                .dividedecimalround(currencyrate);
            total = total.add(synthvalue);
        }

        return total;
    }

    
    function availablecurrencykeys()
        public
        view
        returns (bytes32[])
    {
        bytes32[] memory currencykeys = new bytes32[](availablesynths.length);

        for (uint8 i = 0; i < availablesynths.length; i++) {
            currencykeys[i] = availablesynths[i].currencykey();
        }

        return currencykeys;
    }

    
    function availablesynthcount()
        public
        view
        returns (uint)
    {
        return availablesynths.length;
    }

    
    function feerateforexchange(bytes32 sourcecurrencykey, bytes32 destinationcurrencykey)
        public
        view
        returns (uint)
    {
        
        uint exchangefeerate = feepool.exchangefeerate();

        uint multiplier = 1;

        
        
        if (
            (sourcecurrencykey[0] == 0x73 && sourcecurrencykey !=  && destinationcurrencykey[0] == 0x69) ||
            (sourcecurrencykey[0] == 0x69 && destinationcurrencykey !=  && destinationcurrencykey[0] == 0x73)
        ) {
            
            multiplier = 2;
        }

        return exchangefeerate.mul(multiplier);
    }
    

    
    function transfer(address to, uint value)
        public
        returns (bool)
    {
        bytes memory empty;
        return transfer(to, value, empty);
    }

    
    function transfer(address to, uint value, bytes data)
        public
        optionalproxy
        returns (bool)
    {
        
        require(value <= transferablesynthetix(messagesender), );

        
        _transfer_byproxy(messagesender, to, value, data);

        return true;
    }

    
    function transferfrom(address from, address to, uint value)
        public
        returns (bool)
    {
        bytes memory empty;
        return transferfrom(from, to, value, empty);
    }

    
    function transferfrom(address from, address to, uint value, bytes data)
        public
        optionalproxy
        returns (bool)
    {
        
        require(value <= transferablesynthetix(from), );

        
        
        _transferfrom_byproxy(messagesender, from, to, value, data);

        return true;
    }

    
    function exchange(bytes32 sourcecurrencykey, uint sourceamount, bytes32 destinationcurrencykey, address destinationaddress)
        external
        optionalproxy
        
        returns (bool)
    {
        require(sourcecurrencykey != destinationcurrencykey, );
        require(sourceamount > 0, );

        
        validategasprice(tx.gasprice);

        
        if (protectioncircuit) {
            synths[sourcecurrencykey].burn(messagesender, sourceamount);
            return true;
        } else {
            
            return _internalexchange(
                messagesender,
                sourcecurrencykey,
                sourceamount,
                destinationcurrencykey,
                messagesender,
                true 
            );
        }
    }

    
    function validategasprice(uint _givengasprice)
        public
        view
    {
        require(_givengasprice <= gaspricelimit, );
    }

    
    function synthinitiatedexchange(
        address from,
        bytes32 sourcecurrencykey,
        uint sourceamount,
        bytes32 destinationcurrencykey,
        address destinationaddress
    )
        external
        returns (bool)
    {
        _onlysynth();
        require(sourcecurrencykey != destinationcurrencykey, );
        require(sourceamount > 0, );

        
        return _internalexchange(
            from,
            sourcecurrencykey,
            sourceamount,
            destinationcurrencykey,
            destinationaddress,
            false
        );
    }

    
    function _internalexchange(
        address from,
        bytes32 sourcecurrencykey,
        uint sourceamount,
        bytes32 destinationcurrencykey,
        address destinationaddress,
        bool chargefee
    )
        internal
        notfeeaddress(from)
        returns (bool)
    {
        require(exchangeenabled, );

        
        

        
        synths[sourcecurrencykey].burn(from, sourceamount);

        
        uint destinationamount = effectivevalue(sourcecurrencykey, sourceamount, destinationcurrencykey);

        
        uint amountreceived = destinationamount;
        uint fee = 0;

        if (chargefee) {
            
            uint exchangefeerate = feerateforexchange(sourcecurrencykey, destinationcurrencykey);

            amountreceived = destinationamount.multiplydecimal(safedecimalmath.unit().sub(exchangefeerate));

            fee = destinationamount.sub(amountreceived);
        }

        
        synths[destinationcurrencykey].issue(destinationaddress, amountreceived);

        
        if (fee > 0) {
            uint xdrfeeamount = effectivevalue(destinationcurrencykey, fee, );
            synths[].issue(feepool.fee_address(), xdrfeeamount);
            
            feepool.feepaid(, xdrfeeamount);
        }

        

        
        synths[destinationcurrencykey].triggertokenfallbackifneeded(from, destinationaddress, amountreceived);

        
        emitsynthexchange(from, sourcecurrencykey, sourceamount, destinationcurrencykey, amountreceived, destinationaddress);

        return true;
    }

    
    function _addtodebtregister(bytes32 currencykey, uint amount)
        internal
    {
        
        uint xdrvalue = effectivevalue(currencykey, amount, );

        
        uint totaldebtissued = totalissuedsynths();

        
        uint newtotaldebtissued = xdrvalue.add(totaldebtissued);

        
        uint debtpercentage = xdrvalue.dividedecimalroundprecise(newtotaldebtissued);

        
        
        
        
        uint delta = safedecimalmath.preciseunit().sub(debtpercentage);

        
        uint existingdebt = debtbalanceof(messagesender, );

        
        if (existingdebt > 0) {
            debtpercentage = xdrvalue.add(existingdebt).dividedecimalroundprecise(newtotaldebtissued);
        }

        
        if (!synthetixstate.hasissued(messagesender)) {
            synthetixstate.incrementtotalissuercount();
        }

        
        synthetixstate.setcurrentissuancedata(messagesender, debtpercentage);

        
        
        if (synthetixstate.debtledgerlength() > 0) {
            synthetixstate.appenddebtledgervalue(
                synthetixstate.lastdebtledgerentry().multiplydecimalroundprecise(delta)
            );
        } else {
            synthetixstate.appenddebtledgervalue(safedecimalmath.preciseunit());
        }
    }

    
    function issuesynths(bytes32 currencykey, uint amount)
        public
        optionalproxy
        
    {
        require(amount <= remainingissuablesynths(messagesender, currencykey), );

        
        _addtodebtregister(currencykey, amount);

        
        synths[currencykey].issue(messagesender, amount);

        
        _appendaccountissuancerecord();
    }

    
    function issuemaxsynths(bytes32 currencykey)
        external
        optionalproxy
    {
        
        uint maxissuable = remainingissuablesynths(messagesender, currencykey);

        
        issuesynths(currencykey, maxissuable);
    }

    
    function burnsynths(bytes32 currencykey, uint amount)
        external
        optionalproxy
        
    {
        
        uint debttoremove = effectivevalue(currencykey, amount, );
        uint debt = debtbalanceof(messagesender, );
        uint debtincurrencykey = debtbalanceof(messagesender, currencykey);

        require(debt > 0, );

        
        
        uint amounttoremove = debt < debttoremove ? debt : debttoremove;

        
        _removefromdebtregister(amounttoremove);

        uint amounttoburn = debtincurrencykey < amount ? debtincurrencykey : amount;

        
        synths[currencykey].burn(messagesender, amounttoburn);

        
        _appendaccountissuancerecord();
    }

    
    function _appendaccountissuancerecord()
        internal
    {
        uint initialdebtownership;
        uint debtentryindex;
        (initialdebtownership, debtentryindex) = synthetixstate.issuancedata(messagesender);

        feepool.appendaccountissuancerecord(
            messagesender,
            initialdebtownership,
            debtentryindex
        );
    }

    
    function _removefromdebtregister(uint amount)
        internal
    {
        uint debttoremove = amount;

        
        uint existingdebt = debtbalanceof(messagesender, );

        
        uint totaldebtissued = totalissuedsynths();

        
        uint newtotaldebtissued = totaldebtissued.sub(debttoremove);

        uint delta;

        
        
        if (newtotaldebtissued > 0) {

            
            uint debtpercentage = debttoremove.dividedecimalroundprecise(newtotaldebtissued);

            
            
            
            delta = safedecimalmath.preciseunit().add(debtpercentage);
        } else {
            delta = 0;
        }

        
        if (debttoremove == existingdebt) {
            synthetixstate.setcurrentissuancedata(messagesender, 0);
            synthetixstate.decrementtotalissuercount();
        } else {
            
            uint newdebt = existingdebt.sub(debttoremove);
            uint newdebtpercentage = newdebt.dividedecimalroundprecise(newtotaldebtissued);

            
            synthetixstate.setcurrentissuancedata(messagesender, newdebtpercentage);
        }

        
        synthetixstate.appenddebtledgervalue(
            synthetixstate.lastdebtledgerentry().multiplydecimalroundprecise(delta)
        );
    }

    

    
    function maxissuablesynths(address issuer, bytes32 currencykey)
        public
        view
        
        returns (uint)
    {
        
        uint destinationvalue = effectivevalue(, collateral(issuer), currencykey);

        
        return destinationvalue.multiplydecimal(synthetixstate.issuanceratio());
    }

    
    function collateralisationratio(address issuer)
        public
        view
        returns (uint)
    {
        uint totalownedsynthetix = collateral(issuer);
        if (totalownedsynthetix == 0) return 0;

        uint debtbalance = debtbalanceof(issuer, );
        return debtbalance.dividedecimalround(totalownedsynthetix);
    }

    
    function debtbalanceof(address issuer, bytes32 currencykey)
        public
        view
        
        returns (uint)
    {
        
        uint initialdebtownership;
        uint debtentryindex;
        (initialdebtownership, debtentryindex) = synthetixstate.issuancedata(issuer);

        
        if (initialdebtownership == 0) return 0;

        
        
        uint currentdebtownership = synthetixstate.lastdebtledgerentry()
            .dividedecimalroundprecise(synthetixstate.debtledger(debtentryindex))
            .multiplydecimalroundprecise(initialdebtownership);

        
        uint totalsystemvalue = totalissuedsynths(currencykey);

        
        uint highprecisionbalance = totalsystemvalue.decimaltoprecisedecimal()
            .multiplydecimalroundprecise(currentdebtownership);

        return highprecisionbalance.precisedecimaltodecimal();
    }

    
    function remainingissuablesynths(address issuer, bytes32 currencykey)
        public
        view
        
        returns (uint)
    {
        uint alreadyissued = debtbalanceof(issuer, currencykey);
        uint max = maxissuablesynths(issuer, currencykey);

        if (alreadyissued >= max) {
            return 0;
        } else {
            return max.sub(alreadyissued);
        }
    }

    
    function collateral(address account)
        public
        view
        returns (uint)
    {
        uint balance = tokenstate.balanceof(account);

        if (escrow != address(0)) {
            balance = balance.add(escrow.balanceof(account));
        }

        if (rewardescrow != address(0)) {
            balance = balance.add(rewardescrow.balanceof(account));
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

        
        
        
        
        uint lockedsynthetixvalue = debtbalanceof(account, ).dividedecimalround(synthetixstate.issuanceratio());

        
        if (lockedsynthetixvalue >= balance) {
            return 0;
        } else {
            return balance.sub(lockedsynthetixvalue);
        }
    }

    
    function mint()
        external
        returns (bool)
    {
        require(rewardsdistribution != address(0), );

        uint supplytomint = supplyschedule.mintablesupply();
        require(supplytomint > 0, );

        supplyschedule.updatemintvalues();

        
        
        uint minterreward = supplyschedule.minterreward();
        
        uint amounttodistribute = supplytomint.sub(minterreward);

        
        tokenstate.setbalanceof(rewardsdistribution, tokenstate.balanceof(rewardsdistribution).add(amounttodistribute));
        emittransfer(this, rewardsdistribution, amounttodistribute);

        
        rewardsdistribution.distributerewards(amounttodistribute);

        
        tokenstate.setbalanceof(msg.sender, tokenstate.balanceof(msg.sender).add(minterreward));
        emittransfer(this, msg.sender, minterreward);

        totalsupply = totalsupply.add(supplytomint);

        return true;
    }

    

    modifier ratenotstale(bytes32 currencykey) {
        require(!exchangerates.rateisstale(currencykey), );
        _;
    }

    modifier notfeeaddress(address account) {
        require(account != feepool.fee_address(), );
        _;
    }

    
    function _onlysynth()
        internal
        view
        optionalproxy
    {
        bool issynth = false;

        
        for (uint8 i = 0; i < availablesynths.length; i++) {
            if (availablesynths[i] == messagesender) {
                issynth = true;
                break;
            }
        }

        require(issynth, );
    }

    modifier onlyoracle
    {
        require(msg.sender == exchangerates.oracle(), );
        _;
    }

    
    
    event synthexchange(address indexed account, bytes32 fromcurrencykey, uint256 fromamount, bytes32 tocurrencykey,  uint256 toamount, address toaddress);
    bytes32 constant synthexchange_sig = keccak256();
    function emitsynthexchange(address account, bytes32 fromcurrencykey, uint256 fromamount, bytes32 tocurrencykey, uint256 toamount, address toaddress) internal {
        proxy._emit(abi.encode(fromcurrencykey, fromamount, tocurrencykey, toamount, toaddress), 2, synthexchange_sig, bytes32(account), 0, 0);
    }
    
}
