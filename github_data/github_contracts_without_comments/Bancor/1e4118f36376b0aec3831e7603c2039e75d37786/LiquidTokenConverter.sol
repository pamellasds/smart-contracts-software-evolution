pragma solidity 0.4.26;
import ;
import ;
import ;


contract liquidtokenconverterfactory is itypedconverterfactory {
    
    function convertertype() public pure returns (uint16) {
        return 0;
    }

    
    function createconverter(iconverteranchor _anchor, icontractregistry _registry, uint32 _maxconversionfee) public returns (iconverter) {
        converterbase converter = new liquidtokenconverter(ismarttoken(_anchor), _registry, _maxconversionfee);
        converter.transferownership(msg.sender);
        return converter;
    }
}


contract liquidtokenconverter is converterbase {
    
    constructor(
        ismarttoken _token,
        icontractregistry _registry,
        uint32 _maxconversionfee
    )
        converterbase(_token, _registry, _maxconversionfee)
        public
    {
    }

    
    function convertertype() public pure returns (uint16) {
        return 0;
    }

    
    function acceptanchorownership() public owneronly {
        super.acceptanchorownership();

        emit activation(anchor, true);
    }

    
    function addreserve(ierc20token _token, uint32 _weight) public {
        
        require(reservetokencount() == 0, );
        super.addreserve(_token, _weight);
    }

    
    function rateandfee(ierc20token _sourcetoken, ierc20token _targettoken, uint256 _amount) public view returns (uint256, uint256) {
        if (_targettoken == ismarttoken(anchor) && reserves[_sourcetoken].isset)
            return purchaserate(_amount);
        if (_sourcetoken == ismarttoken(anchor) && reserves[_targettoken].isset)
            return salerate(_amount);

        
        revert();
    }

    
    function doconvert(ierc20token _sourcetoken, ierc20token _targettoken, uint256 _amount, address _trader, address _beneficiary)
        internal
        returns (uint256)
    {
        uint256 rate;
        ierc20token reservetoken;

        if (_targettoken == ismarttoken(anchor) && reserves[_sourcetoken].isset) {
            reservetoken = _sourcetoken;
            rate = buy(_amount, _trader, _beneficiary);
        }
        else if (_sourcetoken == ismarttoken(anchor) && reserves[_targettoken].isset) {
            reservetoken = _targettoken;
            rate = sell(_amount, _trader, _beneficiary);
        }
        else {
            
            revert();
        }

        
        uint256 totalsupply = ismarttoken(anchor).totalsupply();
        uint32 reserveweight = reserves[reservetoken].weight;
        emit tokenrateupdate(anchor, reservetoken, reservebalance(reservetoken).mul(weight_resolution), totalsupply.mul(reserveweight));

        return rate;
    }

    
    function purchaserate(uint256 _amount)
        internal
        view
        active
        returns (uint256, uint256)
    {
        uint256 totalsupply = ismarttoken(anchor).totalsupply();

        
        if (totalsupply == 0)
            return (_amount, 0);

        ierc20token reservetoken = reservetokens[0];
        uint256 amount = ibancorformula(addressof(bancor_formula)).purchaserate(
            totalsupply,
            reservebalance(reservetoken),
            reserves[reservetoken].weight,
            _amount
        );

        
        uint256 fee = calculatefee(amount);
        return (amount  fee, fee);
    }

    
    function salerate(uint256 _amount)
        internal
        view
        active
        returns (uint256, uint256)
    {
        uint256 totalsupply = ismarttoken(anchor).totalsupply();

        ierc20token reservetoken = reservetokens[0];

        
        if (totalsupply == _amount)
            return (reservebalance(reservetoken), 0);

        uint256 amount = ibancorformula(addressof(bancor_formula)).salerate(
            totalsupply,
            reservebalance(reservetoken),
            reserves[reservetoken].weight,
            _amount
        );

        
        uint256 fee = calculatefee(amount);
        return (amount  fee, fee);
    }

    
    function buy(uint256 _amount, address _trader, address _beneficiary) internal returns (uint256) {
        
        (uint256 amount, uint256 fee) = purchaserate(_amount);

        
        require(amount != 0, );

        ierc20token reservetoken = reservetokens[0];

        
        if (reservetoken == eth_reserve_address)
            require(msg.value == _amount, );
        else
            require(msg.value == 0 && reservetoken.balanceof(this).sub(reservebalance(reservetoken)) >= _amount, );

        
        syncreservebalance(reservetoken);

        
        ismarttoken(anchor).issue(_beneficiary, amount);

        
        dispatchconversionevent(reservetoken, ismarttoken(anchor), _trader, _amount, amount, fee);

        return amount;
    }

    
    function sell(uint256 _amount, address _trader, address _beneficiary) internal returns (uint256) {
        
        require(_amount <= ismarttoken(anchor).balanceof(this), );

        
        (uint256 amount, uint256 fee) = salerate(_amount);

        
        require(amount != 0, );

        ierc20token reservetoken = reservetokens[0];

        
        uint256 tokensupply = ismarttoken(anchor).totalsupply();
        uint256 rsvbalance = reservebalance(reservetoken);
        assert(amount < rsvbalance || (amount == rsvbalance && _amount == tokensupply));

        
        ismarttoken(anchor).destroy(this, _amount);

        
        reserves[reservetoken].balance = reserves[reservetoken].balance.sub(amount);

        
        if (reservetoken == eth_reserve_address)
            _beneficiary.transfer(amount);
        else
            safetransfer(reservetoken, _beneficiary, amount);

        
        dispatchconversionevent(ismarttoken(anchor), reservetoken, _trader, _amount, amount, fee);

        return amount;
    }
}
