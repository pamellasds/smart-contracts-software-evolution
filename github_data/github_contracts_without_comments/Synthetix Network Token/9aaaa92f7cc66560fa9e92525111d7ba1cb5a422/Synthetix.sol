

pragma solidity 0.4.25;


import ;
import ;
import ;
import ;
import ;
import ;
import ;


contract synthetix is externstatetoken {

    

    
    synth[] public availablesynths;
    mapping(bytes4 => synth) public synths;

    feepool public feepool;
    synthetixescrow public escrow;
    exchangerates public exchangerates;
    synthetixstate public synthetixstate;

    uint constant synthetix_supply = 1e8 * safedecimalmath.unit();
    string constant token_name = ;
    string constant token_symbol = ;
    uint8 constant decimals = 18;

    

    
    constructor(address _proxy, tokenstate _tokenstate, synthetixstate _synthetixstate,
        address _owner, exchangerates _exchangerates, feepool _feepool
    )
        externstatetoken(_proxy, _tokenstate, token_name, token_symbol, synthetix_supply, decimals, _owner)
        public
    {
        synthetixstate = _synthetixstate;
        exchangerates = _exchangerates;
        feepool = _feepool;
    }

    

    
    function addsynth(synth synth)
        external
        optionalproxy_onlyowner
    {
        bytes4 currencykey = synth.currencykey();

        require(synths[currencykey] == synth(0), );

        availablesynths.push(synth);
        synths[currencykey] = synth;

        emitsynthadded(currencykey, synth);
    }

    
    function removesynth(bytes4 currencykey)
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

        emitsynthremoved(currencykey, synthtoremove);
    }

    
    function setescrow(synthetixescrow _escrow)
        external
        optionalproxy_onlyowner
    {
        escrow = _escrow;
        
        
        
    }

    
    function setexchangerates(exchangerates _exchangerates)
        external
        optionalproxy_onlyowner
    {
        exchangerates = _exchangerates;
        
        
        
    }

    
    function setsynthetixstate(synthetixstate _synthetixstate)
        external
        optionalproxy_onlyowner
    {
        synthetixstate = _synthetixstate;

        emitstatecontractchanged(_synthetixstate);
    }

    
    function setpreferredcurrency(bytes4 currencykey)
        external
        optionalproxy
    {
        require(currencykey == 0 || !exchangerates.rateisstale(currencykey), );

        synthetixstate.setpreferredcurrency(messagesender, currencykey);

        emitpreferredcurrencychanged(messagesender, currencykey);
    }

    

    
    function effectivevalue(bytes4 sourcecurrencykey, uint sourceamount, bytes4 destinationcurrencykey)
        public
        view
        ratenotstale(sourcecurrencykey)
        ratenotstale(destinationcurrencykey)
        returns (uint)
    {
        
        if (sourcecurrencykey == destinationcurrencykey) return sourceamount;

        
        return sourceamount.multiplydecimalround(exchangerates.rateforcurrency(sourcecurrencykey))
            .dividedecimalround(exchangerates.rateforcurrency(destinationcurrencykey));
    }

    
    function totalissuedsynths(bytes4 currencykey)
        public
        view
        ratenotstale(currencykey)
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
        internal
        view
        returns (bytes4[])
    {
        bytes4[] memory availablecurrencykeys = new bytes4[](availablesynths.length);

        for (uint8 i = 0; i < availablesynths.length; i++) {
            availablecurrencykeys[i] = availablesynths[i].currencykey();
        }

        return availablecurrencykeys;
    }

    
    function availablesynthcount()
        public
        view
        returns (uint)
    {
        return availablesynths.length;
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

    
    function exchange(bytes4 sourcecurrencykey, uint sourceamount, bytes4 destinationcurrencykey, address destinationaddress)
        external
        optionalproxy
        
        returns (bool)
    {
        require(sourcecurrencykey != destinationcurrencykey, );
        require(sourceamount > 0, );

        
        return _internalexchange(
            messagesender,
            sourcecurrencykey,
            sourceamount,
            destinationcurrencykey,
            destinationaddress == address(0) ? messagesender : destinationaddress,
            true 
        );
    }

    
    function synthinitiatedexchange(
        address from,
        bytes4 sourcecurrencykey,
        uint sourceamount,
        bytes4 destinationcurrencykey,
        address destinationaddress
    )
        external
        onlysynth
        returns (bool)
    {
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

    
    function synthinitiatedfeepayment(
        address from,
        bytes4 sourcecurrencykey,
        uint sourceamount
    )
        external
        onlysynth
        returns (bool)
    {
        
        if (sourceamount == 0) {
            return true;
        }

        require(sourceamount > 0, );

        
        bool result = _internalexchange(
            from,
            sourcecurrencykey,
            sourceamount,
            ,
            feepool.fee_address(),
            false 
        );

        
        feepool.feepaid(sourcecurrencykey, sourceamount);

        return result;
    }

    
    function _internalexchange(
        address from,
        bytes4 sourcecurrencykey,
        uint sourceamount,
        bytes4 destinationcurrencykey,
        address destinationaddress,
        bool chargefee
    )
        internal
        notfeeaddress(from)
        returns (bool)
    {
        require(destinationaddress != address(0), );
        require(destinationaddress != address(this), );
        require(destinationaddress != address(proxy), );

        
        

        
        synths[sourcecurrencykey].burn(from, sourceamount);

        
        uint destinationamount = effectivevalue(sourcecurrencykey, sourceamount, destinationcurrencykey);

        
        uint amountreceived = destinationamount;
        uint fee = 0;

        if (chargefee) {
            amountreceived = feepool.amountreceivedfromexchange(destinationamount);
            fee = destinationamount.sub(amountreceived);
        }

        
        synths[destinationcurrencykey].issue(destinationaddress, amountreceived);

        
        if (fee > 0) {
            uint xdrfeeamount = effectivevalue(destinationcurrencykey, fee, );
            synths[].issue(feepool.fee_address(), xdrfeeamount);
        }

        

        
        synths[destinationcurrencykey].triggertokenfallbackifneeded(from, destinationaddress, amountreceived);

        
        
        

        return true;
    }

    
    function _addtodebtregister(bytes4 currencykey, uint amount)
        internal
        optionalproxy
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

    
    function issuesynths(bytes4 currencykey, uint amount)
        public
        optionalproxy
        nonzeroamount(amount)
        
    {
        require(amount <= remainingissuablesynths(messagesender, currencykey), );

        
        _addtodebtregister(currencykey, amount);

        
        synths[currencykey].issue(messagesender, amount);
    }

    
    function issuemaxsynths(bytes4 currencykey)
        external
        optionalproxy
    {
        
        uint maxissuable = remainingissuablesynths(messagesender, currencykey);

        
        issuesynths(currencykey, maxissuable);
    }

    
    function burnsynths(bytes4 currencykey, uint amount)
        external
        optionalproxy
        
        
    {
        
        uint debt = debtbalanceof(messagesender, currencykey);

        require(debt > 0, );

        
        
        uint amounttoburn = debt < amount ? debt : amount;

        
        _removefromdebtregister(currencykey, amounttoburn);

        
        synths[currencykey].burn(messagesender, amounttoburn);
    }

    
    function _removefromdebtregister(bytes4 currencykey, uint amount)
        internal
    {
        
        uint debttoremove = effectivevalue(currencykey, amount, );

        
        uint existingdebt = debtbalanceof(messagesender, );

        
        uint totaldebtissued = totalissuedsynths();
        uint debtpercentage = debttoremove.dividedecimalroundprecise(totaldebtissued);

        
        
        
        uint delta = safedecimalmath.preciseunit().add(debtpercentage);

        
        if (debttoremove == existingdebt) {
            synthetixstate.clearissuancedata(messagesender);
            synthetixstate.decrementtotalissuercount();
        } else {
            
            uint newdebt = existingdebt.sub(debttoremove);
            uint newtotaldebtissued = totaldebtissued.sub(debttoremove);
            uint newdebtpercentage = newdebt.dividedecimalroundprecise(newtotaldebtissued);

            
            synthetixstate.setcurrentissuancedata(messagesender, newdebtpercentage);
        }

        
        synthetixstate.appenddebtledgervalue(
            synthetixstate.lastdebtledgerentry().multiplydecimalroundprecise(delta)
        );
    }

    

    
    function maxissuablesynths(address issuer, bytes4 currencykey)
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


    function debtbalanceof(address issuer, bytes4 currencykey)
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

    
    function remainingissuablesynths(address issuer, bytes4 currencykey)
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

    

    modifier ratenotstale(bytes4 currencykey) {
        require(!exchangerates.rateisstale(currencykey), );
        _;
    }

    modifier notfeeaddress(address account) {
        require(account != feepool.fee_address(), );
        _;
    }

    modifier onlysynth() {
        bool issynth = false;

        
        for (uint8 i = 0; i < availablesynths.length; i++) {
            if (availablesynths[i] == msg.sender) {
                issynth = true;
                break;
            }
        }

        require(issynth, );
        _;
    }

    modifier nonzeroamount(uint _amount) {
        require(_amount > 0, );
        _;
    }

    

    event preferredcurrencychanged(address indexed account, bytes4 newpreferredcurrency);
    bytes32 constant preferredcurrencychanged_sig = keccak256();
    function emitpreferredcurrencychanged(address account, bytes4 newpreferredcurrency) internal {
        proxy._emit(abi.encode(newpreferredcurrency), 2, preferredcurrencychanged_sig, bytes32(account), 0, 0);
    }

    event statecontractchanged(address statecontract);
    bytes32 constant statecontractchanged_sig = keccak256();
    function emitstatecontractchanged(address statecontract) internal {
        proxy._emit(abi.encode(statecontract), 1, statecontractchanged_sig, 0, 0, 0);
    }

    event synthadded(bytes4 currencykey, address newsynth);
    bytes32 constant synthadded_sig = keccak256();
    function emitsynthadded(bytes4 currencykey, address newsynth) internal {
        proxy._emit(abi.encode(currencykey, newsynth), 1, synthadded_sig, 0, 0, 0);
    }

    event synthremoved(bytes4 currencykey, address removedsynth);
    bytes32 constant synthremoved_sig = keccak256();
    function emitsynthremoved(bytes4 currencykey, address removedsynth) internal {
        proxy._emit(abi.encode(currencykey, removedsynth), 1, synthremoved_sig, 0, 0, 0);
    }
}
