pragma solidity 0.4.26;
import ;
import ;
import ;
import ;
import ;


contract liquiditypoolv2converter is liquiditypoolconverter {
    uint8 internal constant amplification_factor = 20;  

    struct fraction {
        uint256 n;  
        uint256 d;  
    }

    ipriceoracle public priceoracle;                                
    ierc20token public primaryreservetoken;                         
    ierc20token public secondaryreservetoken;                       
    mapping (address => uint256) private stakedbalances;            
    mapping (address => ismarttoken) private reservestopooltokens;  
    mapping (address => ierc20token) private pooltokenstoreserves;  

    
    uint256 private constant rate_propagation_period = 10 minutes;

    fraction public referencerate;              
    uint256 public referencerateupdatetime;     

    fraction public lastconversionrate;         

    
    mapping (address => uint256) public maxstakedbalances;
    bool public maxstakedbalanceenabled = true;

    
    constructor(ipooltokenscontainer _pooltokenscontainer, icontractregistry _registry, uint32 _maxconversionfee)
        public liquiditypoolconverter(_pooltokenscontainer, _registry, _maxconversionfee)
    {
    }

    
    modifier validpooltoken(ismarttoken _address) {
        _validpooltoken(_address);
        _;
    }

    
    function _validpooltoken(ismarttoken _address) internal view {
        require(pooltokenstoreserves[_address] != address(0), );
    }

    
    function convertertype() public pure returns (uint16) {
        return 2;
    }

    
    function isactive() public view returns (bool) {
        return super.isactive() && priceoracle != address(0);
    }

    
    function activate(ierc20token _primaryreservetoken, ichainlinkpriceoracle _primaryreserveoracle, ichainlinkpriceoracle _secondaryreserveoracle)
        public
        inactive
        owneronly
        validreserve(_primaryreservetoken)
        notthis(_primaryreserveoracle)
        notthis(_secondaryreserveoracle)
        validaddress(_primaryreserveoracle)
        validaddress(_secondaryreserveoracle)
    {
        
        require(anchor.owner() == address(this), );

        
        iwhitelist oraclewhitelist = iwhitelist(addressof(chainlink_oracle_whitelist));
        require(oraclewhitelist.iswhitelisted(_primaryreserveoracle), );
        require(oraclewhitelist.iswhitelisted(_secondaryreserveoracle), );

        
        createpooltokens();

        
        primaryreservetoken = _primaryreservetoken;
        if (_primaryreservetoken == reservetokens[0])
            secondaryreservetoken = reservetokens[1];
        else
            secondaryreservetoken = reservetokens[0];

        
        liquiditypoolv2convertercustomfactory customfactory =
            liquiditypoolv2convertercustomfactory(iconverterfactory(addressof(converter_factory)).customfactories(convertertype()));
        priceoracle = customfactory.createpriceoracle(_primaryreservetoken, secondaryreservetoken, _primaryreserveoracle, _secondaryreserveoracle);

        (referencerate.n, referencerate.d) = priceoracle.latestrate(primaryreservetoken, secondaryreservetoken);
        lastconversionrate = referencerate;

        referencerateupdatetime = time();

        
        uint256 primaryreservestakedbalance = reservestakedbalance(primaryreservetoken);
        uint256 primaryreservebalance = reservebalance(primaryreservetoken);
        uint256 secondaryreservebalance = reservebalance(secondaryreservetoken);

        if (primaryreservestakedbalance == primaryreservebalance) {
            if (primaryreservestakedbalance > 0 || secondaryreservebalance > 0) {
                rebalance();
            }
        }
        else if (primaryreservestakedbalance > 0 && primaryreservebalance > 0 && secondaryreservebalance > 0) {
            rebalance();
        }

        emit activation(convertertype(), anchor, true);
    }

    
    function reservestakedbalance(ierc20token _reservetoken)
        public
        view
        validreserve(_reservetoken)
        returns (uint256)
    {
        return stakedbalances[_reservetoken];
    }

    
    function reserveamplifiedbalance(ierc20token _reservetoken)
        public
        view
        validreserve(_reservetoken)
        returns (uint256)
    {
        return stakedbalances[_reservetoken].mul(amplification_factor  1).add(reservebalance(_reservetoken));
    }

    
    function setreservestakedbalance(ierc20token _reservetoken, uint256 _balance)
        public
        owneronly
        only(converter_upgrader)
        validreserve(_reservetoken)
    {
        stakedbalances[_reservetoken] = _balance;
    }

    
    function setmaxstakedbalances(uint256 _reserve1maxstakedbalance, uint256 _reserve2maxstakedbalance) public owneronly {
        maxstakedbalances[reservetokens[0]] = _reserve1maxstakedbalance;
        maxstakedbalances[reservetokens[1]] = _reserve2maxstakedbalance;
    }

    
    function disablemaxstakedbalances() public owneronly {
        maxstakedbalanceenabled = false;
    }

    
    function pooltoken(ierc20token _reservetoken) public view returns (ismarttoken) {
        return reservestopooltokens[_reservetoken];
    }

    
    function liquidationlimit(ismarttoken _pooltoken) public view returns (uint256) {
        
        uint256 pooltokensupply = _pooltoken.totalsupply();

        
        ierc20token reservetoken = pooltokenstoreserves[_pooltoken];
        uint256 balance = reservebalance(reservetoken);
        uint256 stakedbalance = stakedbalances[reservetoken];

        
        return balance.mul(pooltokensupply).div(stakedbalance);
    }

    
    function addreserve(ierc20token _token, uint32 _weight) public {
        
        require(reservetokencount() < 2, );
        super.addreserve(_token, _weight);
    }

    
    function effectivetokensrate() public view returns (uint256, uint256) {
        fraction memory rate = _effectivetokensrate();
        return (rate.n, rate.d);
    }

    
    function effectivereserveweights() public view returns (uint256, uint256) {
        fraction memory rate = _effectivetokensrate();
        (uint32 primaryreserveweight, uint32 secondaryreserveweight) = effectivereserveweights(rate);

        if (primaryreservetoken == reservetokens[0]) {
            return (primaryreserveweight, secondaryreserveweight);
        }

        return (secondaryreserveweight, primaryreserveweight);
    }

    
    function targetamountandfee(ierc20token _sourcetoken, ierc20token _targettoken, uint256 _amount)
        public
        view
        active
        returns (uint256, uint256)
    {
        
        
        _validreserve(_sourcetoken);
        _validreserve(_targettoken);
        require(_sourcetoken != _targettoken, );

        
        uint32 sourcetokenweight;
        uint32 targettokenweight;

        
        
        fraction memory rate;
        if (referencerateupdatetime == time()) {
            rate = referencerate;
            sourcetokenweight = reserves[_sourcetoken].weight;
            targettokenweight = reserves[_targettoken].weight;
        }
        else {
            
            rate = _effectivetokensrate();
            (uint32 primaryreserveweight, uint32 secondaryreserveweight) = effectivereserveweights(rate);

            if (_sourcetoken == primaryreservetoken) {
                sourcetokenweight = primaryreserveweight;
                targettokenweight = secondaryreserveweight;
            }
            else {
                sourcetokenweight = secondaryreserveweight;
                targettokenweight = primaryreserveweight;
            }
        }

        
        (uint256 targetamount, , uint256 fee) = targetamountandfees(_sourcetoken, _targettoken, sourcetokenweight, targettokenweight, rate, _amount);
        return (targetamount, fee);
    }

    
    function doconvert(ierc20token _sourcetoken, ierc20token _targettoken, uint256 _amount, address _trader, address _beneficiary)
        internal
        active
        validreserve(_sourcetoken)
        validreserve(_targettoken)
        returns (uint256)
    {
        
        (uint256 amount, uint256 fee) = doconvert(_sourcetoken, _targettoken, _amount);

        
        if (_targettoken == eth_reserve_address) {
            _beneficiary.transfer(amount);
        }
        else {
            safetransfer(_targettoken, _beneficiary, amount);
        }

        
        dispatchconversionevent(_sourcetoken, _targettoken, _trader, _amount, amount, fee);

        
        dispatchrateevents(_sourcetoken, _targettoken, reserves[_sourcetoken].weight, reserves[_targettoken].weight);

        
        return amount;
    }

    
    function doconvert(ierc20token _sourcetoken, ierc20token _targettoken, uint256 _amount) private returns (uint256, uint256) {
        
        (bool rateupdated, fraction memory rate) = handleratechange();

        
        (uint256 amount, uint256 normalfee, uint256 adjustedfee) = targetamountandfees(_sourcetoken, _targettoken, 0, 0, rate, _amount);

        
        require(amount != 0, );

        
        uint256 targetreservebalance = reservebalance(_targettoken);
        require(amount < targetreservebalance, );

        
        if (_sourcetoken == eth_reserve_address)
            require(msg.value == _amount, );
        else
            require(msg.value == 0 && _sourcetoken.balanceof(this).sub(reservebalance(_sourcetoken)) >= _amount, );

        
        syncreservebalance(_sourcetoken);
        reserves[_targettoken].balance = targetreservebalance.sub(amount);

        
        stakedbalances[_targettoken] = stakedbalances[_targettoken].add(normalfee);

        
        if (rateupdated) {
            lastconversionrate = tokensrate(primaryreservetoken, secondaryreservetoken, 0, 0);
        }

        return (amount, adjustedfee);
    }

    
    function addliquidity(ierc20token _reservetoken, uint256 _amount, uint256 _minreturn)
        public
        payable
        protected
        active
        validreserve(_reservetoken)
        greaterthanzero(_amount)
        greaterthanzero(_minreturn)
        returns (uint256)
    {
        
        require(_reservetoken == eth_reserve_address ? msg.value == _amount : msg.value == 0, );

        
        syncreservebalances();

        
        if (_reservetoken == eth_reserve_address)
            reserves[eth_reserve_address].balance = reserves[eth_reserve_address].balance.sub(msg.value);

        
        uint256 initialstakedbalance = stakedbalances[_reservetoken];

        
        if (maxstakedbalanceenabled) {
            require(maxstakedbalances[_reservetoken] == 0 || initialstakedbalance.add(_amount) <= maxstakedbalances[_reservetoken], );
        }

        
        ismarttoken reservepooltoken = reservestopooltokens[_reservetoken];
        uint256 pooltokensupply = reservepooltoken.totalsupply();

        
        if (_reservetoken != eth_reserve_address)
            safetransferfrom(_reservetoken, msg.sender, this, _amount);

        
        reserves[_reservetoken].balance = reserves[_reservetoken].balance.add(_amount);
        stakedbalances[_reservetoken] = initialstakedbalance.add(_amount);

        
        
        
        uint256 pooltokenamount = 0;
        if (initialstakedbalance == 0 || pooltokensupply == 0)
            pooltokenamount = _amount;
        else
            pooltokenamount = _amount.mul(pooltokensupply).div(initialstakedbalance);
        require(pooltokenamount >= _minreturn, );

        
        ipooltokenscontainer(anchor).mint(reservepooltoken, msg.sender, pooltokenamount);

        
        rebalance();

        
        emit liquidityadded(msg.sender, _reservetoken, _amount, initialstakedbalance.add(_amount), pooltokensupply.add(pooltokenamount));

        
        dispatchpooltokenrateupdateevent(reservepooltoken, pooltokensupply.add(pooltokenamount), _reservetoken);

        
        dispatchtokenrateupdateevent(reservetokens[0], reservetokens[1], 0, 0);

        
        return pooltokenamount;
    }

    
    function removeliquidity(ismarttoken _pooltoken, uint256 _amount, uint256 _minreturn)
        public
        protected
        active
        validpooltoken(_pooltoken)
        greaterthanzero(_amount)
        greaterthanzero(_minreturn)
        returns (uint256)
    {
        
        syncreservebalances();

        
        uint256 initialpoolsupply = _pooltoken.totalsupply();

        
        uint256 reserveamount = removeliquidityreturn(_pooltoken, _amount);
        require(reserveamount >= _minreturn, );

        
        ierc20token reservetoken = pooltokenstoreserves[_pooltoken];

        
        ipooltokenscontainer(anchor).burn(_pooltoken, msg.sender, _amount);

        
        reserves[reservetoken].balance = reserves[reservetoken].balance.sub(reserveamount);
        uint256 newstakedbalance = stakedbalances[reservetoken].sub(reserveamount);
        stakedbalances[reservetoken] = newstakedbalance;

        
        if (reservetoken == eth_reserve_address)
            msg.sender.transfer(reserveamount);
        else
            safetransfer(reservetoken, msg.sender, reserveamount);

        
        rebalance();

        uint256 newpooltokensupply = initialpoolsupply.sub(_amount);

        
        emit liquidityremoved(msg.sender, reservetoken, reserveamount, newstakedbalance, newpooltokensupply);

        
        dispatchpooltokenrateupdateevent(_pooltoken, newpooltokensupply, reservetoken);

        
        dispatchtokenrateupdateevent(reservetokens[0], reservetokens[1], 0, 0);

        
        return reserveamount;
    }

    
    function removeliquidityreturn(ismarttoken _pooltoken, uint256 _amount)
        public
        view
        returns (uint256)
    {
        uint256 totalsupply = _pooltoken.totalsupply();
        uint256 stakedbalance = stakedbalances[pooltokenstoreserves[_pooltoken]];

        if (_amount < totalsupply) {
            uint256 x = stakedbalances[primaryreservetoken].mul(amplification_factor);
            uint256 y = reserveamplifiedbalance(primaryreservetoken);
            (uint256 min, uint256 max) = x < y ? (x, y) : (y, x);
            return _amount.mul(stakedbalance).div(totalsupply).mul(min).div(max);
        }
        return stakedbalance;
    }

    
    function targetamountandfees(
        ierc20token _sourcetoken,
        ierc20token _targettoken,
        uint32 _sourceweight,
        uint32 _targetweight,
        fraction memory _rate,
        uint256 _amount)
        private
        view
        returns (uint256 targetamount, uint256 normalfee, uint256 adjustedfee)
    {
        if (_sourceweight == 0)
            _sourceweight = reserves[_sourcetoken].weight;
        if (_targetweight == 0)
            _targetweight = reserves[_targettoken].weight;

        
        uint256 sourcebalance = reserveamplifiedbalance(_sourcetoken);
        uint256 targetbalance = reserveamplifiedbalance(_targettoken);

        
        targetamount = ibancorformula(addressof(bancor_formula)).crossreservetargetamount(
            sourcebalance,
            _sourceweight,
            targetbalance,
            _targetweight,
            _amount
        );

        
        normalfee = super.calculatefee(targetamount);
        adjustedfee = calculatefee(_targettoken, _sourceweight, _targetweight, _rate, targetamount);
        targetamount = adjustedfee;
    }

    
    function calculatefee(
        ierc20token _targettoken,
        uint32 _sourceweight,
        uint32 _targetweight,
        fraction memory _rate,
        uint256 _targetamount)
        internal view returns (uint256)
    {
        
        if (_targettoken == primaryreservetoken) {
            return super.calculatefee(_targetamount);
        }

        
        uint256 fee = calculateadjustedfee(
            stakedbalances[primaryreservetoken],
            stakedbalances[secondaryreservetoken],
            _sourceweight,
            _targetweight,
            _rate.n,
            _rate.d,
            conversionfee);

        
        return _targetamount.mul(fee).div(conversion_fee_resolution);
    }

    
    function calculateadjustedfee(
        uint256 _primaryreservestaked,
        uint256 _secondaryreservestaked,
        uint256 _primaryreserveweight,
        uint256 _secondaryreserveweight,
        uint256 _primaryreserverate,
        uint256 _secondaryreserverate,
        uint256 _conversionfee)
        internal
        pure
        returns (uint256)
    {
        uint256 x = _primaryreservestaked.mul(_primaryreserverate).mul(_secondaryreserveweight);
        uint256 y = _secondaryreservestaked.mul(_secondaryreserverate).mul(_primaryreserveweight);

        if (x.mul(amplification_factor) >= y.mul(amplification_factor + 1))
            return _conversionfee / 2;

        if (x.mul(amplification_factor * 2) <= y.mul(amplification_factor * 2  1))
            return _conversionfee * 2;

        return _conversionfee.mul(y).div(x.mul(amplification_factor).sub(y.mul(amplification_factor  1)));
    }

    
    function createpooltokens() internal {
        ipooltokenscontainer container = ipooltokenscontainer(anchor);
        if (container.pooltokens().length != 0) {
            return;
        }

        uint256 reservecount = reservetokens.length;
        for (uint256 i = 0; i < reservecount; i++) {
            ismarttoken reservepooltoken = container.createtoken();

            
            reservestopooltokens[reservetokens[i]] = reservepooltoken;
            pooltokenstoreserves[reservepooltoken] = reservetokens[i];
        }
    }

    
    function _effectivetokensrate() private view returns (fraction memory) {
        
        (uint256 externalraten, uint256 externalrated, uint256 updatetime) = priceoracle.latestrateandupdatetime(primaryreservetoken, secondaryreservetoken);

        
        if (updatetime >= referencerateupdatetime) {
            return fraction({ n: externalraten, d: externalrated });
        }

        
        uint256 timeelapsed = time()  referencerateupdatetime;

        
        if (timeelapsed == 0) {
            return referencerate;
        }

        
        

        
        if (timeelapsed >= rate_propagation_period) {
            return lastconversionrate;
        }

        
        fraction memory ref = referencerate;
        fraction memory last = lastconversionrate;

        uint256 x = ref.d.mul(last.n);
        uint256 y = ref.n.mul(last.d);

        
        uint256 newraten = y.mul(rate_propagation_period  timeelapsed).add(x.mul(timeelapsed));
        uint256 newrated = ref.d.mul(last.d).mul(rate_propagation_period);

        return reducerate(newraten, newrated);
    }

    
    function handleratechange() private returns (bool, fraction memory) {
        uint256 currenttime = time();

        
        if (referencerateupdatetime == currenttime) {
            return (false, referencerate);
        }

        
        fraction memory newrate = _effectivetokensrate();

        
        fraction memory ref = referencerate;
        if (newrate.n == ref.n && newrate.d == ref.d) {
            return (false, newrate);
        }

        referencerate = newrate;
        referencerateupdatetime = currenttime;

        rebalance();

        return (true, newrate);
    }

    
    function rebalance() private {
        
        (uint32 primaryreserveweight, uint32 secondaryreserveweight) = effectivereserveweights(referencerate);

        
        reserves[primaryreservetoken].weight = primaryreserveweight;
        reserves[secondaryreservetoken].weight = secondaryreserveweight;
    }

    
    function effectivereserveweights(fraction memory _rate) private view returns (uint32, uint32) {
        
        uint256 primarystakedbalance = stakedbalances[primaryreservetoken];

        
        uint256 primarybalance = reserveamplifiedbalance(primaryreservetoken);
        uint256 secondarybalance = reserveamplifiedbalance(secondaryreservetoken);

        
        return ibancorformula(addressof(bancor_formula)).balancedweights(
            primarystakedbalance.mul(amplification_factor),
            primarybalance,
            secondarybalance,
            _rate.n,
            _rate.d);
    }

    
    function tokensrate(ierc20token _token1, ierc20token _token2, uint32 _token1weight, uint32 _token2weight) private view returns (fraction memory) {
        
        uint256 token1balance = reserveamplifiedbalance(_token1);
        uint256 token2balance = reserveamplifiedbalance(_token2);

        
        if (_token1weight == 0) {
            _token1weight = reserves[_token1].weight;
        }

        if (_token2weight == 0) {
            _token2weight = reserves[_token2].weight;
        }

        return fraction({ n: token2balance.mul(_token1weight), d: token1balance.mul(_token2weight) });
    }

    
    function dispatchrateevents(ierc20token _sourcetoken, ierc20token _targettoken, uint32 _sourceweight, uint32 _targetweight) private {
        dispatchtokenrateupdateevent(_sourcetoken, _targettoken, _sourceweight, _targetweight);

        
        
        
        ismarttoken targetpooltoken = pooltoken(_targettoken);
        uint256 targetpooltokensupply = targetpooltoken.totalsupply();
        dispatchpooltokenrateupdateevent(targetpooltoken, targetpooltokensupply, _targettoken);
    }

    
    function dispatchtokenrateupdateevent(ierc20token _token1, ierc20token _token2, uint32 _token1weight, uint32 _token2weight) private {
        
        fraction memory rate = tokensrate(_token1, _token2, _token1weight, _token2weight);

        emit tokenrateupdate(_token1, _token2, rate.n, rate.d);
    }

    
    function dispatchpooltokenrateupdateevent(ismarttoken _pooltoken, uint256 _pooltokensupply, ierc20token _reservetoken) private {
        emit tokenrateupdate(_pooltoken, _reservetoken, stakedbalances[_reservetoken], _pooltokensupply);
    }

    
    function time() internal view returns (uint256) {
        return now;
    }

    uint256 private constant max_rate_factor_lower_bound = 1e30;
    uint256 private constant max_rate_factor_upper_bound = uint256(1) / max_rate_factor_lower_bound;

    
    function reducerate(uint256 _n, uint256 _d) internal pure returns (fraction memory) {
        if (_n >= _d) {
            return reducefactors(_n, _d);
        }

        fraction memory rate = reducefactors(_d, _n);
        return fraction({ n: rate.d, d: rate.n });
    }

    
    function reducefactors(uint256 _max, uint256 _min) internal pure returns (fraction memory) {
        if (_min > max_rate_factor_upper_bound) {
            return fraction({
                n: max_rate_factor_lower_bound,
                d: _min / (_max / max_rate_factor_lower_bound)
            });
        }

        if (_max > max_rate_factor_lower_bound) {
            return fraction({
                n: max_rate_factor_lower_bound,
                d: _min * max_rate_factor_lower_bound / _max
            });
        }

        return fraction({ n: _max, d: _min });
    }
}
