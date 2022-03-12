pragma solidity 0.4.26;
import ;
import ;
import ;
import ;
import ;


contract liquiditypoolv2converter is liquiditypoolconverter {
    uint8 internal constant amplification_factor = 20;  
    uint32 internal constant high_fee_upper_bound = 997500; 
    uint256 internal constant max_rate_factor_lower_bound = 1e30;

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

    uint256 public externalratepropagationtime = 1 hours;  
    uint256 public prevconversiontime;  

    
    uint32 public lowfeefactor = 200000;
    uint32 public highfeefactor = 800000;

    
    mapping (address => uint256) public maxstakedbalances;
    bool public maxstakedbalanceenabled = true;

     
    event externalratepropagationtimeupdate(uint256 _prevpropagationtime, uint256 _newpropagationtime);

    
    event feefactorsupdate(uint256 _prevlowfactor, uint256 _newlowfactor, uint256 _prevhighfactor, uint256 _newhighfactor);

    
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

    
    function amplificationfactor() public pure returns (uint8) {
        return amplification_factor;
    }

    
    function activate(
        ierc20token _primaryreservetoken,
        ichainlinkpriceoracle _primaryreserveoracle,
        ichainlinkpriceoracle _secondaryreserveoracle)
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
        require(oraclewhitelist.iswhitelisted(_primaryreserveoracle) &&
                oraclewhitelist.iswhitelisted(_secondaryreserveoracle), );

        
        createpooltokens();

        
        primaryreservetoken = _primaryreservetoken;
        if (_primaryreservetoken == reservetokens[0])
            secondaryreservetoken = reservetokens[1];
        else
            secondaryreservetoken = reservetokens[0];

        
        liquiditypoolv2convertercustomfactory customfactory =
            liquiditypoolv2convertercustomfactory(iconverterfactory(addressof(converter_factory)).customfactories(convertertype()));
        priceoracle = customfactory.createpriceoracle(
            _primaryreservetoken,
            secondaryreservetoken,
            _primaryreserveoracle,
            _secondaryreserveoracle);

        
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
        return amplifiedbalance(_reservetoken);
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
        fraction memory rate = ratefromprimaryweight(effectiveprimaryweight());
        return (rate.n, rate.d);
    }

    
    function effectivereserveweights() public view returns (uint256, uint256) {
        uint32 primaryreserveweight = effectiveprimaryweight();
        if (primaryreservetoken == reservetokens[0]) {
            return (primaryreserveweight, inverseweight(primaryreserveweight));
        }

        return (inverseweight(primaryreserveweight), primaryreserveweight);
    }

    
    function setexternalratepropagationtime(uint256 _propagationtime) public owneronly {
        emit externalratepropagationtimeupdate(externalratepropagationtime, _propagationtime);
        externalratepropagationtime = _propagationtime;
    }

    
    function setfeefactors(uint32 _lowfactor, uint32 _highfactor) public owneronly {
        require(_lowfactor <= ppm_resolution, );
        require(_highfactor <= ppm_resolution, );

        emit feefactorsupdate(lowfeefactor, _lowfactor, highfeefactor, _highfactor);

        lowfeefactor = _lowfactor;
        highfeefactor = _highfactor;
    }

    
    function targetamountandfee(ierc20token _sourcetoken, ierc20token _targettoken, uint256 _amount)
        public
        view
        active
        validreserve(_sourcetoken)
        validreserve(_targettoken)
        returns (uint256, uint256)
    {
        
        require(_sourcetoken != _targettoken, );

        
        fraction memory externalrate;
        uint256 externalrateupdatetime;
        (externalrate.n, externalrate.d, externalrateupdatetime) =
            priceoracle.latestrateandupdatetime(primaryreservetoken, secondaryreservetoken);

        
        (uint32 sourcetokenweight, uint32 externalsourcetokenweight) = effectiveandexternalprimaryweight(externalrate, externalrateupdatetime);
        if (_targettoken == primaryreservetoken) {
            sourcetokenweight = inverseweight(sourcetokenweight);
            externalsourcetokenweight = inverseweight(externalsourcetokenweight);
        }

        
        return targetamountandfee(
            _sourcetoken, _targettoken,
            sourcetokenweight, inverseweight(sourcetokenweight),
            externalrate, inverseweight(externalsourcetokenweight),
            _amount);
    }

    
    function doconvert(ierc20token _sourcetoken, ierc20token _targettoken, uint256 _amount, address _trader, address _beneficiary)
        internal
        active
        validreserve(_sourcetoken)
        validreserve(_targettoken)
        returns (uint256)
    {
        
        (uint256 amount, uint256 fee) = doconvert(_sourcetoken, _targettoken, _amount);

        
        prevconversiontime = time();

        
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
        
        fraction memory externalrate;
        uint256 externalrateupdatetime;
        (externalrate.n, externalrate.d, externalrateupdatetime) = priceoracle.latestrateandupdatetime(primaryreservetoken, secondaryreservetoken);

        
        (uint256 targetamount, uint256 fee) = prepareconversion(_sourcetoken, _targettoken, _amount, externalrate, externalrateupdatetime);

        
        require(targetamount != 0, );

        
        uint256 targetreservebalance = reserves[_targettoken].balance;
        require(targetamount < targetreservebalance, );

        
        if (_sourcetoken == eth_reserve_address)
            require(msg.value == _amount, );
        else
            require(msg.value == 0 && _sourcetoken.balanceof(this).sub(reserves[_sourcetoken].balance) >= _amount, );

        
        syncreservebalance(_sourcetoken);
        reserves[_targettoken].balance = targetreservebalance.sub(targetamount);

        
        stakedbalances[_targettoken] = stakedbalances[_targettoken].add(calculatedeficit(externalrate) == 0 ? fee : fee / 2);

        
        return (targetamount, fee);
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

        
        fraction memory rate = rebalancerate();

        
        reserves[_reservetoken].balance = reserves[_reservetoken].balance.add(_amount);
        stakedbalances[_reservetoken] = initialstakedbalance.add(_amount);

        
        
        
        uint256 pooltokenamount = 0;
        if (initialstakedbalance == 0 || pooltokensupply == 0)
            pooltokenamount = _amount;
        else
            pooltokenamount = _amount.mul(pooltokensupply).div(initialstakedbalance);
        require(pooltokenamount >= _minreturn, );

        
        ipooltokenscontainer(anchor).mint(reservepooltoken, msg.sender, pooltokenamount);

        
        rebalance(rate);

        
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

        
        (uint256 reserveamount, ) = removeliquidityreturnandfee(_pooltoken, _amount);
        require(reserveamount >= _minreturn, );

        
        ierc20token reservetoken = pooltokenstoreserves[_pooltoken];

        
        ipooltokenscontainer(anchor).burn(_pooltoken, msg.sender, _amount);

        
        fraction memory rate = rebalancerate();

        
        reserves[reservetoken].balance = reserves[reservetoken].balance.sub(reserveamount);
        uint256 newstakedbalance = stakedbalances[reservetoken].sub(reserveamount);
        stakedbalances[reservetoken] = newstakedbalance;

        
        if (reservetoken == eth_reserve_address)
            msg.sender.transfer(reserveamount);
        else
            safetransfer(reservetoken, msg.sender, reserveamount);

        
        rebalance(rate);

        uint256 newpooltokensupply = initialpoolsupply.sub(_amount);

        
        emit liquidityremoved(msg.sender, reservetoken, reserveamount, newstakedbalance, newpooltokensupply);

        
        dispatchpooltokenrateupdateevent(_pooltoken, newpooltokensupply, reservetoken);

        
        dispatchtokenrateupdateevent(reservetokens[0], reservetokens[1], 0, 0);

        
        return reserveamount;
    }

    
    function removeliquidityreturnandfee(ismarttoken _pooltoken, uint256 _amount) public view returns (uint256, uint256) {
        uint256 totalsupply = _pooltoken.totalsupply();
        uint256 stakedbalance = stakedbalances[pooltokenstoreserves[_pooltoken]];

        if (_amount < totalsupply) {
            (uint256 min, uint256 max) = tokensrateaccuracy();
            uint256 amountbeforefee = _amount.mul(stakedbalance).div(totalsupply);
            uint256 amountafterfee = amountbeforefee.mul(min).div(max);
            return (amountafterfee, amountbeforefee  amountafterfee);
        }
        return (stakedbalance, 0);
    }

    
    function tokensrateaccuracy() internal view returns (uint256, uint256) {
        uint32 weight = reserves[primaryreservetoken].weight;
        fraction memory poolrate = tokensrate(primaryreservetoken, secondaryreservetoken, weight, inverseweight(weight));
        (uint256 n, uint256 d) = effectivetokensrate();
        (uint256 x, uint256 y) = reducedratio(poolrate.n.mul(d), poolrate.d.mul(n), max_rate_factor_lower_bound);
        return x < y ? (x, y) : (y, x);
    }

    
    function targetamountandfee(
        ierc20token _sourcetoken,
        ierc20token _targettoken,
        uint32 _sourceweight,
        uint32 _targetweight,
        fraction memory _externalrate,
        uint32 _targetexternalweight,
        uint256 _amount)
        private
        view
        returns (uint256, uint256)
    {
        
        uint256 sourcebalance = amplifiedbalance(_sourcetoken);
        uint256 targetbalance = amplifiedbalance(_targettoken);

        
        uint256 targetamount = ibancorformula(addressof(bancor_formula)).crossreservetargetamount(
            sourcebalance,
            _sourceweight,
            targetbalance,
            _targetweight,
            _amount
        );

        
        
        require(targetamount <= reserves[_targettoken].balance, );

        
        uint256 fee = calculatefee(_sourcetoken, _targettoken, _sourceweight, _targetweight, _externalrate, _targetexternalweight, targetamount);
        return (targetamount  fee, fee);
    }

    
    function calculatefee(
        ierc20token _sourcetoken,
        ierc20token _targettoken,
        uint32 _sourceweight,
        uint32 _targetweight,
        fraction memory _externalrate,
        uint32 _targetexternalweight,
        uint256 _targetamount)
        internal view returns (uint256)
    {
        
        fraction memory targetexternalrate;
        if (_targettoken == primaryreservetoken) {
            (targetexternalrate.n, targetexternalrate.d) = (_externalrate.n, _externalrate.d);
        }
        else {
            (targetexternalrate.n, targetexternalrate.d) = (_externalrate.d, _externalrate.n);
        }

        
        fraction memory currentrate = tokensrate(_targettoken, _sourcetoken, _targetweight, _sourceweight);
        if (comparerates(currentrate, targetexternalrate) < 0) {
            uint256 lo = currentrate.n.mul(targetexternalrate.d);
            uint256 hi = targetexternalrate.n.mul(currentrate.d);
            (lo, hi) = reducedratio(hi  lo, hi, max_rate_factor_lower_bound);

            
            uint32 feefactor;
            if (uint256(_targetweight).mul(ppm_resolution) < uint256(_targetexternalweight).mul(high_fee_upper_bound)) {
                feefactor = highfeefactor;
            }
            else {
                feefactor = lowfeefactor;
            }

            return _targetamount.mul(lo).mul(feefactor).div(hi.mul(ppm_resolution));
        }

        return 0;
    }

    
    function calculatedeficit(fraction memory _externalrate) internal view returns (uint256) {
        ierc20token primaryreservetokenlocal = primaryreservetoken; 
        ierc20token secondaryreservetokenlocal = secondaryreservetoken; 

        
        uint256 primarybalanceinsecondary = reserves[primaryreservetokenlocal].balance.mul(_externalrate.n).div(_externalrate.d);
        uint256 primarystakedinsecondary = stakedbalances[primaryreservetokenlocal].mul(_externalrate.n).div(_externalrate.d);

        
        uint256 totalbalance = primarybalanceinsecondary.add(reserves[secondaryreservetokenlocal].balance);
        uint256 totalstaked = primarystakedinsecondary.add(stakedbalances[secondaryreservetokenlocal]);
        if (totalbalance < totalstaked) {
            return totalstaked  totalbalance;
        }

        return 0;
    }

    
    function prepareconversion(
        ierc20token _sourcetoken,
        ierc20token _targettoken,
        uint256 _amount,
        fraction memory _externalrate,
        uint256 _externalrateupdatetime)
        internal
        returns (uint256, uint256)
    {
        
        (uint32 effectivesourcereserveweight, uint32 externalsourcereserveweight) =
            effectiveandexternalprimaryweight(_externalrate, _externalrateupdatetime);
        if (_targettoken == primaryreservetoken) {
            effectivesourcereserveweight = inverseweight(effectivesourcereserveweight);
            externalsourcereserveweight = inverseweight(externalsourcereserveweight);
        }

        
        if (reserves[_sourcetoken].weight != effectivesourcereserveweight) {
            
            reserves[_sourcetoken].weight = effectivesourcereserveweight;
            reserves[_targettoken].weight = inverseweight(effectivesourcereserveweight);
        }

        
        return targetamountandfee(
            _sourcetoken, _targettoken,
            effectivesourcereserveweight, inverseweight(effectivesourcereserveweight),
            _externalrate, inverseweight(externalsourcereserveweight),
            _amount);
    }

    
    function createpooltokens() internal {
        ipooltokenscontainer container = ipooltokenscontainer(anchor);
        ismarttoken[] memory pooltokens = container.pooltokens();
        bool initialsetup = pooltokens.length == 0;

        uint256 reservecount = reservetokens.length;
        for (uint256 i = 0; i < reservecount; i++) {
            ismarttoken reservepooltoken;
            if (initialsetup) {
                reservepooltoken = container.createtoken();
            }
            else {
                reservepooltoken = pooltokens[i];
            }

            
            reservestopooltokens[reservetokens[i]] = reservepooltoken;
            pooltokenstoreserves[reservepooltoken] = reservetokens[i];
        }
    }

    
    function effectiveprimaryweight() internal view returns (uint32) {
        
        fraction memory externalrate;
        uint256 externalrateupdatetime;
        (externalrate.n, externalrate.d, externalrateupdatetime) = priceoracle.latestrateandupdatetime(primaryreservetoken, secondaryreservetoken);
        (uint32 effectiveweight,) = effectiveandexternalprimaryweight(externalrate, externalrateupdatetime);
        return effectiveweight;
    }

    
    function effectiveandexternalprimaryweight(fraction memory _externalrate, uint256 _externalrateupdatetime)
        internal
        view
        returns
        (uint32, uint32)
    {
        
        uint32 externalprimaryreserveweight = primaryweightfromrate(_externalrate);

        
        ierc20token primaryreservetokenlocal = primaryreservetoken; 
        uint32 primaryreserveweight = reserves[primaryreservetokenlocal].weight;

        
        if (primaryreserveweight == externalprimaryreserveweight) {
            return (primaryreserveweight, externalprimaryreserveweight);
        }

        
        uint256 referencetime = prevconversiontime;
        if (referencetime < _externalrateupdatetime) {
            referencetime = _externalrateupdatetime;
        }

        
        uint256 currenttime = time();
        if (referencetime > currenttime) {
            referencetime = currenttime;
        }

        
        uint256 elapsedtime = currenttime  referencetime;
        if (elapsedtime == 0) {
            return (primaryreserveweight, externalprimaryreserveweight);
        }

        
        
        fraction memory poolrate = tokensrate(
            primaryreservetokenlocal,
            secondaryreservetoken,
            primaryreserveweight,
            inverseweight(primaryreserveweight));

        bool updateweights = false;
        if (primaryreserveweight < externalprimaryreserveweight) {
            updateweights = comparerates(poolrate, _externalrate) < 0;
        }
        else {
            updateweights = comparerates(poolrate, _externalrate) > 0;
        }

        if (!updateweights) {
            return (primaryreserveweight, externalprimaryreserveweight);
        }

        
        
        if (elapsedtime >= externalratepropagationtime) {
            return (externalprimaryreserveweight, externalprimaryreserveweight);
        }

        
        primaryreserveweight = uint32(weightedaverageintegers(
            primaryreserveweight, externalprimaryreserveweight,
            elapsedtime, externalratepropagationtime));
        return (primaryreserveweight, externalprimaryreserveweight);
    }

    
    function rebalancerate() private view returns (fraction memory) {
        
        if (reserves[primaryreservetoken].balance == 0 || reserves[secondaryreservetoken].balance == 0) {
            fraction memory externalrate;
            (externalrate.n, externalrate.d) = priceoracle.latestrate(primaryreservetoken, secondaryreservetoken);
            return externalrate;
        }

        
        return tokensrate(primaryreservetoken, secondaryreservetoken, 0, 0);
    }

    
    function rebalance() private {
        
        fraction memory externalrate;
        (externalrate.n, externalrate.d) = priceoracle.latestrate(primaryreservetoken, secondaryreservetoken);

        
        rebalance(externalrate);
    }

    
    function rebalance(fraction memory _rate) private {
        
        uint256 a = amplifiedbalance(primaryreservetoken).mul(_rate.n);
        uint256 b = amplifiedbalance(secondaryreservetoken).mul(_rate.d);
        (uint256 x, uint256 y) = normalizedratio(a, b, ppm_resolution);

        
        reserves[primaryreservetoken].weight = uint32(x);
        reserves[secondaryreservetoken].weight = uint32(y);
    }

    
    function amplifiedbalance(ierc20token _reservetoken) internal view returns (uint256) {
        return stakedbalances[_reservetoken].mul(amplification_factor  1).add(reserves[_reservetoken].balance);
    }

    
    function primaryweightfromrate(fraction memory _rate) private view returns (uint32) {
        uint256 a = stakedbalances[primaryreservetoken].mul(_rate.n);
        uint256 b = stakedbalances[secondaryreservetoken].mul(_rate.d);
        (uint256 x,) = normalizedratio(a, b, ppm_resolution);
        return uint32(x);
    }

    
    function ratefromprimaryweight(uint32 _primaryreserveweight) private view returns (fraction memory) {
        uint256 n = stakedbalances[secondaryreservetoken].mul(_primaryreserveweight);
        uint256 d = stakedbalances[primaryreservetoken].mul(inverseweight(_primaryreserveweight));
        (n, d) = reducedratio(n, d, max_rate_factor_lower_bound);
        return fraction(n, d);
    }

    
    function tokensrate(ierc20token _token1, ierc20token _token2, uint32 _token1weight, uint32 _token2weight) private view returns (fraction memory) {
        if (_token1weight == 0) {
            _token1weight = reserves[_token1].weight;
        }

        if (_token2weight == 0) {
            _token2weight = inverseweight(_token1weight);
        }

        uint256 n = amplifiedbalance(_token2).mul(_token1weight);
        uint256 d = amplifiedbalance(_token1).mul(_token2weight);
        (n, d) = reducedratio(n, d, max_rate_factor_lower_bound);
        return fraction(n, d);
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

    

    
    function inverseweight(uint32 _weight) internal pure returns (uint32) {
        return ppm_resolution  _weight;
    }

    
    function time() internal view returns (uint256) {
        return now;
    }

    
    function normalizedratio(uint256 _a, uint256 _b, uint256 _scale) internal pure returns (uint256, uint256) {
        if (_a == _b)
            return (_scale / 2, _scale / 2);
        if (_a < _b)
            return accurateratio(_a, _b, _scale);
        (uint256 y, uint256 x) = accurateratio(_b, _a, _scale);
        return (x, y);
    }

    
    function accurateratio(uint256 _a, uint256 _b, uint256 _scale) internal pure returns (uint256, uint256) {
        uint256 maxval = uint256(1) / _scale;
        if (_a > maxval) {
            uint256 c = _a / (maxval + 1) + 1;
            _a /= c;
            _b /= c;
        }
        uint256 x = rounddiv(_a * _scale, _a.add(_b));
        uint256 y = _scale  x;
        return (x, y);
    }

    
    function reducedratio(uint256 _n, uint256 _d, uint256 _max) internal pure returns (uint256, uint256) {
        if (_n > _max || _d > _max)
            return normalizedratio(_n, _d, _max);
        return (_n, _d);
    }

    
    function rounddiv(uint256 _n, uint256 _d) internal pure returns (uint256) {
        return _n / _d + _n % _d / (_d  _d / 2);
    }

    
    function weightedaverageintegers(uint256 _x, uint256 _y, uint256 _n, uint256 _d) internal pure returns (uint256) {
        return _x.mul(_d).add(_y.mul(_n)).sub(_x.mul(_n)).div(_d);
    }

    
    function comparerates(fraction memory _rate1, fraction memory _rate2) internal pure returns (int8) {
        uint256 x = _rate1.n.mul(_rate2.d);
        uint256 y = _rate2.n.mul(_rate1.d);

        if (x < y)
            return 1;

        if (x > y)
            return 1;

        return 0;
    }
}
