
pragma solidity 0.6.12;
import ;
import ;


contract liquiditypoolv1converter is liquiditypoolconverter {
    iethertoken internal ethertoken = iethertoken(0xc0829421c1d260bd3cb3e0f06cfe2d52db2ce315);

    
    event pricedataupdate(
        ierc20token indexed _connectortoken,
        uint256 _tokensupply,
        uint256 _connectorbalance,
        uint32 _connectorweight
    );

    
    constructor(
        ismarttoken _token,
        icontractregistry _registry,
        uint32 _maxconversionfee
    )
        liquiditypoolconverter(_token, _registry, _maxconversionfee)
        public
    {
    }

    
    function convertertype() public pure override returns (uint16) {
        return 1;
    }

    
    function acceptanchorownership() public override owneronly {
        super.acceptanchorownership();

        emit activation(convertertype(), anchor, true);
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

        uint256 amount = ibancorformula(addressof(bancor_formula)).crossreservetargetamount(
            reservebalance(_sourcetoken),
            reserves[_sourcetoken].weight,
            reservebalance(_targettoken),
            reserves[_targettoken].weight,
            _amount
        );

        
        uint256 fee = calculatefee(amount);
        return (amount  fee, fee);
    }

    
    function doconvert(ierc20token _sourcetoken, ierc20token _targettoken, uint256 _amount, address _trader, address payable _beneficiary)
        internal
        override
        returns (uint256)
    {
        
        (uint256 amount, uint256 fee) = targetamountandfee(_sourcetoken, _targettoken, _amount);

        
        require(amount != 0, );

        
        assert(amount < reservebalance(_targettoken));

        
        if (_sourcetoken == eth_reserve_address)
            require(msg.value == _amount, );
        else
            require(msg.value == 0 && _sourcetoken.balanceof(address(this)).sub(reservebalance(_sourcetoken)) >= _amount, );

        
        syncreservebalance(_sourcetoken);
        reserves[_targettoken].balance = reserves[_targettoken].balance.sub(amount);

        
        if (_targettoken == eth_reserve_address)
            _beneficiary.transfer(amount);
        else
            safetransfer(_targettoken, _beneficiary, amount);

        
        dispatchconversionevent(_sourcetoken, _targettoken, _trader, _amount, amount, fee);

        
        dispatchtokenrateupdateevents(_sourcetoken, _targettoken);

        return amount;
    }

    
    function addliquidity(ierc20token[] memory _reservetokens, uint256[] memory _reserveamounts, uint256 _minreturn)
        public
        payable
        protected
        active
    {
        
        verifyliquidityinput(_reservetokens, _reserveamounts, _minreturn);

        
        for (uint256 i = 0; i < _reservetokens.length; i++)
            if (_reservetokens[i] == eth_reserve_address)
                require(_reserveamounts[i] == msg.value, );

        
        if (msg.value > 0) {
            require(reserves[eth_reserve_address].isset, );
        }

        
        uint256 totalsupply = ismarttoken(address(anchor)).totalsupply();

        
        uint256 amount = addliquiditytopool(_reservetokens, _reserveamounts, totalsupply);

        
        require(amount >= _minreturn, );

        
        ismarttoken(address(anchor)).issue(msg.sender, amount);
    }

    
    function removeliquidity(uint256 _amount, ierc20token[] memory _reservetokens, uint256[] memory _reserveminreturnamounts)
        public
        protected
        active
    {
        
        verifyliquidityinput(_reservetokens, _reserveminreturnamounts, _amount);

        
        uint256 totalsupply = ismarttoken(address(anchor)).totalsupply();

        
        ismarttoken(address(anchor)).destroy(msg.sender, _amount);

        
        removeliquidityfrompool(_reservetokens, _reserveminreturnamounts, totalsupply, _amount);
    }

    
    function fund(uint256 _amount) public payable protected {
        syncreservebalances();
        reserves[eth_reserve_address].balance = reserves[eth_reserve_address].balance.sub(msg.value);

        uint256 supply = ismarttoken(address(anchor)).totalsupply();
        ibancorformula formula = ibancorformula(addressof(bancor_formula));

        
        
        uint256 reservecount = reservetokens.length;
        for (uint256 i = 0; i < reservecount; i++) {
            ierc20token reservetoken = reservetokens[i];
            uint256 rsvbalance = reserves[reservetoken].balance;
            uint256 reserveamount = formula.fundcost(supply, rsvbalance, reserveratio, _amount);

            
            if (reservetoken == eth_reserve_address) {
                if (msg.value > reserveamount) {
                    msg.sender.transfer(msg.value  reserveamount);
                }
                else if (msg.value < reserveamount) {
                    require(msg.value == 0, );
                    safetransferfrom(ethertoken, msg.sender, address(this), reserveamount);
                    ethertoken.withdraw(reserveamount);
                }
            }
            else {
                safetransferfrom(reservetoken, msg.sender, address(this), reserveamount);
            }

            
            uint256 newreservebalance = rsvbalance.add(reserveamount);
            reserves[reservetoken].balance = newreservebalance;

            uint256 newpooltokensupply = supply.add(_amount);

            
            emit liquidityadded(msg.sender, reservetoken, reserveamount, newreservebalance, newpooltokensupply);

            
            dispatchpooltokenrateupdateevent(newpooltokensupply, reservetoken, newreservebalance, reserves[reservetoken].weight);
        }

        
        ismarttoken(address(anchor)).issue(msg.sender, _amount);
    }

    
    function liquidate(uint256 _amount) public protected {
        require(_amount > 0, );

        uint256 totalsupply = ismarttoken(address(anchor)).totalsupply();
        ismarttoken(address(anchor)).destroy(msg.sender, _amount);

        uint256[] memory reserveminreturnamounts = new uint256[](reservetokens.length);
        for (uint256 i = 0; i < reserveminreturnamounts.length; i++)
            reserveminreturnamounts[i] = 1;

        removeliquidityfrompool(reservetokens, reserveminreturnamounts, totalsupply, _amount);
    }

    
    function verifyliquidityinput(ierc20token[] memory _reservetokens, uint256[] memory _reserveamounts, uint256 _amount) private view {
        uint256 i;
        uint256 j;

        uint256 length = reservetokens.length;
        require(length == _reservetokens.length, );
        require(length == _reserveamounts.length, );

        for (i = 0; i < length; i++) {
            
            require(reserves[_reservetokens[i]].isset, );
            for (j = 0; j < length; j++) {
                if (reservetokens[i] == _reservetokens[j])
                    break;
            }
            
            require(j < length, );
            
            require(_reserveamounts[i] > 0, );
        }

        
        require(_amount > 0, );
    }

    
    function addliquiditytopool(ierc20token[] memory _reservetokens, uint256[] memory _reserveamounts, uint256 _totalsupply)
        private
        returns (uint256)
    {
        if (_totalsupply == 0)
            return addliquiditytoemptypool(_reservetokens, _reserveamounts);
        return addliquiditytononemptypool(_reservetokens, _reserveamounts, _totalsupply);
    }

    
    function addliquiditytoemptypool(ierc20token[] memory _reservetokens, uint256[] memory _reserveamounts)
        private
        returns (uint256)
    {
        
        uint256 amount = geometricmean(_reserveamounts);

        
        for (uint256 i = 0; i < _reservetokens.length; i++) {
            ierc20token reservetoken = _reservetokens[i];
            uint256 reserveamount = _reserveamounts[i];

            if (reservetoken != eth_reserve_address) 
                safetransferfrom(reservetoken, msg.sender, address(this), reserveamount);

            reserves[reservetoken].balance = reserveamount;

            emit liquidityadded(msg.sender, reservetoken, reserveamount, reserveamount, amount);

            
            dispatchpooltokenrateupdateevent(amount, reservetoken, reserveamount, reserves[reservetoken].weight);
        }

        return amount;
    }

    
    function addliquiditytononemptypool(ierc20token[] memory _reservetokens, uint256[] memory _reserveamounts, uint256 _totalsupply)
        private
        returns (uint256)
    {
        syncreservebalances();
        reserves[eth_reserve_address].balance = reserves[eth_reserve_address].balance.sub(msg.value);

        ibancorformula formula = ibancorformula(addressof(bancor_formula));
        uint256 amount = getminshare(formula, _totalsupply, _reservetokens, _reserveamounts);
        uint256 newpooltokensupply = _totalsupply.add(amount);

        for (uint256 i = 0; i < _reservetokens.length; i++) {
            ierc20token reservetoken = _reservetokens[i];
            uint256 rsvbalance = reserves[reservetoken].balance;
            uint256 reserveamount = formula.fundcost(_totalsupply, rsvbalance, reserveratio, amount);
            require(reserveamount > 0, );
            assert(reserveamount <= _reserveamounts[i]);

            
            if (reservetoken != eth_reserve_address) 
                safetransferfrom(reservetoken, msg.sender, address(this), reserveamount);
            else if (_reserveamounts[i] > reserveamount) 
                msg.sender.transfer(_reserveamounts[i]  reserveamount);

            uint256 newreservebalance = rsvbalance.add(reserveamount);
            reserves[reservetoken].balance = newreservebalance;

            emit liquidityadded(msg.sender, reservetoken, reserveamount, newreservebalance, newpooltokensupply);

            
            dispatchpooltokenrateupdateevent(newpooltokensupply, reservetoken, newreservebalance, reserves[reservetoken].weight);
        }

        return amount;
    }

    
    function removeliquidityfrompool(ierc20token[] memory _reservetokens, uint256[] memory _reserveminreturnamounts, uint256 _totalsupply, uint256 _amount)
        private
    {
        syncreservebalances();

        ibancorformula formula = ibancorformula(addressof(bancor_formula));
        uint256 newpooltokensupply = _totalsupply.sub(_amount);

        for (uint256 i = 0; i < _reservetokens.length; i++) {
            ierc20token reservetoken = _reservetokens[i];
            uint256 rsvbalance = reserves[reservetoken].balance;
            uint256 reserveamount = formula.liquidatereserveamount(_totalsupply, rsvbalance, reserveratio, _amount);
            require(reserveamount >= _reserveminreturnamounts[i], );

            uint256 newreservebalance = rsvbalance.sub(reserveamount);
            reserves[reservetoken].balance = newreservebalance;

            
            if (reservetoken == eth_reserve_address)
                msg.sender.transfer(reserveamount);
            else
                safetransfer(reservetoken, msg.sender, reserveamount);

            emit liquidityremoved(msg.sender, reservetoken, reserveamount, newreservebalance, newpooltokensupply);

            
            dispatchpooltokenrateupdateevent(newpooltokensupply, reservetoken, newreservebalance, reserves[reservetoken].weight);
        }
    }

    function getminshare(ibancorformula formula, uint256 _totalsupply, ierc20token[] memory _reservetokens, uint256[] memory _reserveamounts) private view returns (uint256) {
        uint256 minindex = 0;
        for (uint256 i = 1; i < _reservetokens.length; i++) {
            if (_reserveamounts[i].mul(reserves[_reservetokens[minindex]].balance) < _reserveamounts[minindex].mul(reserves[_reservetokens[i]].balance))
                minindex = i;
        }
        return formula.fundsupplyamount(_totalsupply, reserves[_reservetokens[minindex]].balance, reserveratio, _reserveamounts[minindex]);
    }

    
    function decimallength(uint256 _x) public pure returns (uint256) {
        uint256 y = 0;
        for (uint256 x = _x; x > 0; x /= 10)
            y++;
        return y;
    }

    
    function rounddiv(uint256 _n, uint256 _d) public pure returns (uint256) {
        return (_n + _d / 2) / _d;
    }

    
    function geometricmean(uint256[] memory _values) public pure returns (uint256) {
        uint256 numofdigits = 0;
        uint256 length = _values.length;
        for (uint256 i = 0; i < length; i++)
            numofdigits += decimallength(_values[i]);
        return uint256(10) ** (rounddiv(numofdigits, length)  1);
    }

     
    function dispatchtokenrateupdateevents(ierc20token _sourcetoken, ierc20token _targettoken) private {
        uint256 pooltokensupply = ismarttoken(address(anchor)).totalsupply();
        uint256 sourcereservebalance = reservebalance(_sourcetoken);
        uint256 targetreservebalance = reservebalance(_targettoken);
        uint32 sourcereserveweight = reserves[_sourcetoken].weight;
        uint32 targetreserveweight = reserves[_targettoken].weight;

        
        uint256 raten = targetreservebalance.mul(sourcereserveweight);
        uint256 rated = sourcereservebalance.mul(targetreserveweight);
        emit tokenrateupdate(_sourcetoken, _targettoken, raten, rated);

        
        dispatchpooltokenrateupdateevent(pooltokensupply, _sourcetoken, sourcereservebalance, sourcereserveweight);
        dispatchpooltokenrateupdateevent(pooltokensupply, _targettoken, targetreservebalance, targetreserveweight);

        
        emit pricedataupdate(_sourcetoken, pooltokensupply, sourcereservebalance, sourcereserveweight);
        emit pricedataupdate(_targettoken, pooltokensupply, targetreservebalance, targetreserveweight);
    }

    
    function dispatchpooltokenrateupdateevent(uint256 _pooltokensupply, ierc20token _reservetoken, uint256 _reservebalance, uint32 _reserveweight) private {
        emit tokenrateupdate(ismarttoken(address(anchor)), _reservetoken, _reservebalance.mul(ppm_resolution), _pooltokensupply.mul(_reserveweight));
    }
}
