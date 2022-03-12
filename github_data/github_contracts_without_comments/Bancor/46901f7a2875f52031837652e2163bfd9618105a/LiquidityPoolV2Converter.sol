
pragma solidity 0.6.12;
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
    mapping (ierc20token => uint256) private stakedbalances;            
    mapping (ierc20token => ismarttoken) private reservestopooltokens;  
    mapping (ismarttoken => ierc20token) private pooltokenstoreserves;  

    fraction public externalrate;           
    uint256 public externalrateupdatetime;  

    
    mapping (ierc20token => uint256) public maxstakedbalances;
    bool public maxstakedbalanceenabled = true;

    uint32 public oracledeviationfee = 10000; 

    
    event oracledeviationfeeupdate(uint32 _prevfee, uint32 _newfee);

    
    constructor(ipooltokenscontainer _pooltokenscontainer, icontractregistry _registry, uint32 _maxconversionfee)
        public liquiditypoolconverter(_pooltokenscontainer, _registry, _maxconversionfee)
    {
    }

    
    modifier validpooltoken(ismarttoken _address) {
        _validpooltoken(_address);
        _;
    }

    
    function _validpooltoken(ismarttoken _address) internal view {
        require(address(pooltokenstoreserves[_address]) != address(0), );
    }

    
    function convertertype() public pure override returns (uint16) {
        return 2;
    }

    
    function isactive() public view override returns (bool) {
        return super.isactive() && address(priceoracle) != address(0);
    }

    
    function activate(
        ierc20token _primaryreservetoken,
        ichainlinkpriceoracle _primaryreserveoracle,
        ichainlinkpriceoracle _secondaryreserveoracle)
        public
        inactive
        owneronly
        validreserve(_primaryreservetoken)
        notthis(address(_primaryreserveoracle))
        notthis(address(_secondaryreserveoracle))
        validaddress(address(_primaryreserveoracle))
        validaddress(address(_secondaryreserveoracle))
    {
        
        require(anchor.owner() == address(this), );

        
        iwhitelist oraclewhitelist = iwhitelist(addressof(chainlink_oracle_whitelist));
        require(oraclewhitelist.iswhitelisted(address(_primaryreserveoracle)) &&
                oraclewhitelist.iswhitelisted(address(_secondaryreserveoracle)), );

        
        createpooltokens();

        
        primaryreservetoken = _primaryreservetoken;
        if (_primaryreservetoken == reservetokens[0])
            secondaryreservetoken = reservetokens[1];
        else
            secondaryreservetoken = reservetokens[0];

        
        liquiditypoolv2convertercustomfactory customfactory =
            liquiditypoolv2convertercustomfactory(address(iconverterfactory(addressof(converter_factory)).customfactories(convertertype())));
        priceoracle = customfactory.createpriceoracle(
            _primaryreservetoken,
            secondaryreservetoken,
            _primaryreserveoracle,
            _secondaryreserveoracle);

        externalrate = _effectivetokensrate();
        externalrateupdatetime = time();

        
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

    
    function setoracledeviationfee(uint32 _oracledeviationfee) public owneronly {
        require(_oracledeviationfee <= ppm_resolution, );
        emit oracledeviationfeeupdate(oracledeviationfee, _oracledeviationfee);
        oracledeviationfee = _oracledeviationfee;
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

    
    function addreserve(ierc20token _token, uint32 _weight) public override owneronly {
        
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
        override
        active
        validreserve(_sourcetoken)
        validreserve(_targettoken)
        returns (uint256, uint256)
    {
        
        require(_sourcetoken != _targettoken, );

        uint32 sourcetokenweight;
        uint32 targettokenweight;

        
        if (externalrateupdatetime == time()) {
            sourcetokenweight = reserves[_sourcetoken].weight;
            targettokenweight = ppm_resolution  sourcetokenweight;
        }
        else {
            fraction memory rate = _effectivetokensrate();
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

        
        (uint256 targetamount, , uint256 fee) = targetamountandfees(_sourcetoken, _targettoken, sourcetokenweight, targettokenweight, _amount);
        return (targetamount, fee);
    }

    
    function doconvert(ierc20token _sourcetoken, ierc20token _targettoken, uint256 _amount, address _trader, address payable _beneficiary)
        internal
        override
        active
        validreserve(_sourcetoken)
        validreserve(_targettoken)
        returns (uint256)
    {
        
        if (externalrateupdatetime < time()) {
            externalrateupdatetime = time();
            externalrate = _effectivetokensrate();
            rebalance();
        }

        uint32 sourcetokenweight = reserves[_sourcetoken].weight;
        uint32 targettokenweight = ppm_resolution  sourcetokenweight;

        
        (uint256 amount, uint256 standardfee, uint256 totalfee) = targetamountandfees(_sourcetoken, _targettoken, sourcetokenweight, targettokenweight, _amount);

        
        require(amount != 0, );

        
        if (_sourcetoken == eth_reserve_address)
            require(msg.value == _amount, );
        else
            require(msg.value == 0 && _sourcetoken.balanceof(address(this)).sub(reservebalance(_sourcetoken)) >= _amount, );

        
        syncreservebalance(_sourcetoken);
        reserves[_targettoken].balance = reservebalance(_targettoken).sub(amount);

        
        stakedbalances[_targettoken] = stakedbalances[_targettoken].add(standardfee);

        
        if (_targettoken == eth_reserve_address) {
            _beneficiary.transfer(amount);
        }
        else {
            safetransfer(_targettoken, _beneficiary, amount);
        }

        
        dispatchconversionevent(_sourcetoken, _targettoken, _trader, _amount, amount, totalfee);

        
        dispatchtokenrateupdateevent(_sourcetoken, _targettoken, sourcetokenweight, targettokenweight);

        
        
        
        ismarttoken targetpooltoken = reservestopooltokens[_targettoken];
        dispatchpooltokenrateupdateevent(targetpooltoken, targetpooltoken.totalsupply(), _targettoken);

        
        return amount;
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

        
        if (_reservetoken == eth_reserve_address) {
            reserves[eth_reserve_address].balance = reserves[eth_reserve_address].balance.sub(msg.value);
        }

        
        uint256 initialstakedbalance = stakedbalances[_reservetoken];

        
        if (maxstakedbalanceenabled) {
            require(maxstakedbalances[_reservetoken] == 0 || initialstakedbalance.add(_amount) <= maxstakedbalances[_reservetoken], );
        }

        
        ismarttoken reservepooltoken = reservestopooltokens[_reservetoken];
        uint256 pooltokensupply = reservepooltoken.totalsupply();

        
        if (_reservetoken != eth_reserve_address)
            safetransferfrom(_reservetoken, msg.sender, address(this), _amount);

        
        reserves[_reservetoken].balance = reserves[_reservetoken].balance.add(_amount);
        stakedbalances[_reservetoken] = initialstakedbalance.add(_amount);

        
        
        
        uint256 pooltokenamount = 0;
        if (initialstakedbalance == 0 || pooltokensupply == 0)
            pooltokenamount = _amount;
        else
            pooltokenamount = _amount.mul(pooltokensupply).div(initialstakedbalance);
        require(pooltokenamount >= _minreturn, );

        
        ipooltokenscontainer(address(anchor)).mint(reservepooltoken, msg.sender, pooltokenamount);

        
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

        
        (uint256 reserveamount, ) = removeliquidityreturnandfee(_pooltoken, _amount);
        require(reserveamount >= _minreturn, );

        
        ierc20token reservetoken = pooltokenstoreserves[_pooltoken];

        
        ipooltokenscontainer(address(anchor)).burn(_pooltoken, msg.sender, _amount);

        
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

    
    function removeliquidityreturnandfee(ismarttoken _pooltoken, uint256 _amount) public view returns (uint256, uint256) {
        uint256 totalsupply = _pooltoken.totalsupply();
        uint256 stakedbalance = stakedbalances[pooltokenstoreserves[_pooltoken]];

        if (_amount < totalsupply) {
            uint256 x = stakedbalances[primaryreservetoken].mul(amplification_factor);
            uint256 y = amplifiedbalance(primaryreservetoken);
            (uint256 min, uint256 max) = x < y ? (x, y) : (y, x);
            uint256 amountbeforefee = _amount.mul(stakedbalance).div(totalsupply);
            uint256 amountafterfee = amountbeforefee.mul(min).div(max);
            return (amountafterfee, amountbeforefee  amountafterfee);
        }
        return (stakedbalance, 0);
    }

    
    function targetamountandfees(
        ierc20token _sourcetoken,
        ierc20token _targettoken,
        uint32 _sourceweight,
        uint32 _targetweight,
        uint256 _amount)
        private
        view
        returns (uint256, uint256, uint256)
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

        uint256 standardfee = calculatefee(targetamount);
        uint256 totalfee = targetamount.mul(oracledeviationfee).div(ppm_resolution).add(standardfee);

        
        return (targetamount.sub(totalfee), standardfee, totalfee);
    }

    
    function createpooltokens() internal {
        ipooltokenscontainer container = ipooltokenscontainer(address(anchor));
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

    
    function _effectivetokensrate() private view returns (fraction memory) {
        (uint256 latestraten, uint256 latestrated) = priceoracle.latestrate(primaryreservetoken, secondaryreservetoken);
        return fraction({ n: latestraten, d: latestrated });
    }

    
    function rebalance() private {
        (reserves[primaryreservetoken].weight, reserves[secondaryreservetoken].weight) = effectivereserveweights(externalrate);
    }

    
    function amplifiedbalance(ierc20token _reservetoken) internal view returns (uint256) {
        return stakedbalances[_reservetoken].mul(amplification_factor  1).add(reserves[_reservetoken].balance);
    }

    
    function effectivereserveweights(fraction memory _rate) private view returns (uint32, uint32) {
        
        uint256 primarystakedbalance = stakedbalances[primaryreservetoken];

        
        uint256 primarybalance = amplifiedbalance(primaryreservetoken);
        uint256 secondarybalance = amplifiedbalance(secondaryreservetoken);

        
        return ibancorformula(addressof(bancor_formula)).balancedweights(
            primarystakedbalance.mul(amplification_factor),
            primarybalance,
            secondarybalance,
            _rate.n,
            _rate.d);
    }

    
    function dispatchtokenrateupdateevent(ierc20token _token1, ierc20token _token2, uint32 _token1weight, uint32 _token2weight) private {
        
        uint256 token1balance = amplifiedbalance(_token1);
        uint256 token2balance = amplifiedbalance(_token2);

        
        if (_token1weight == 0) {
            _token1weight = reserves[_token1].weight;
        }

        
        if (_token2weight == 0) {
            _token2weight = ppm_resolution  _token1weight;
        }

        emit tokenrateupdate(_token1, _token2, token2balance.mul(_token1weight), token1balance.mul(_token2weight));
    }

    
    function dispatchpooltokenrateupdateevent(ismarttoken _pooltoken, uint256 _pooltokensupply, ierc20token _reservetoken) private {
        emit tokenrateupdate(_pooltoken, _reservetoken, stakedbalances[_reservetoken], _pooltokensupply);
    }

    
    function time() internal view virtual returns (uint256) {
        return now;
    }
}
