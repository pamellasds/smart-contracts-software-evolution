
pragma solidity 0.6.12;
import ;
import ;


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

    
    function convertertype() public override pure returns (uint16) {
        return 0;
    }

    
    function acceptanchorownership() public override owneronly {
        super.acceptanchorownership();

        emit activation(convertertype(), anchor, true);
    }

    
    function addreserve(ierc20token _token, uint32 _weight) public override owneronly {
        
        require(reservetokencount() == 0, );
        super.addreserve(_token, _weight);
    }

    
    function targetamountandfee(ierc20token _sourcetoken, ierc20token _targettoken, uint256 _amount) public override view returns (uint256, uint256) {
        if (_targettoken == ismarttoken(address(anchor)) && reserves[_sourcetoken].isset)
            return purchasetargetamount(_amount);
        if (_sourcetoken == ismarttoken(address(anchor)) && reserves[_targettoken].isset)
            return saletargetamount(_amount);

        
        revert();
    }

    
    function doconvert(ierc20token _sourcetoken, ierc20token _targettoken, uint256 _amount, address _trader, address payable _beneficiary)
        internal
        override
        returns (uint256)
    {
        uint256 targetamount;
        ierc20token reservetoken;

        if (_targettoken == ismarttoken(address(anchor)) && reserves[_sourcetoken].isset) {
            reservetoken = _sourcetoken;
            targetamount = buy(_amount, _trader, _beneficiary);
        }
        else if (_sourcetoken == ismarttoken(address(anchor)) && reserves[_targettoken].isset) {
            reservetoken = _targettoken;
            targetamount = sell(_amount, _trader, _beneficiary);
        }
        else {
            
            revert();
        }

        
        uint256 totalsupply = ismarttoken(address(anchor)).totalsupply();
        uint32 reserveweight = reserves[reservetoken].weight;
        emit tokenrateupdate(ismarttoken(address(anchor)), reservetoken, reservebalance(reservetoken).mul(ppm_resolution), totalsupply.mul(reserveweight));

        return targetamount;
    }

    
    function purchasetargetamount(uint256 _amount)
        internal
        view
        active
        returns (uint256, uint256)
    {
        uint256 totalsupply = ismarttoken(address(anchor)).totalsupply();
        ierc20token reservetoken = reservetokens[0];

        
        if (totalsupply == 0)
            return (_amount.mul(ppm_resolution).div(reserves[reservetoken].weight), 0);

        uint256 amount = ibancorformula(addressof(bancor_formula)).purchasetargetamount(
            totalsupply,
            reservebalance(reservetoken),
            reserves[reservetoken].weight,
            _amount
        );

        
        uint256 fee = calculatefee(amount);
        return (amount  fee, fee);
    }

    
    function saletargetamount(uint256 _amount)
        internal
        view
        active
        returns (uint256, uint256)
    {
        uint256 totalsupply = ismarttoken(address(anchor)).totalsupply();

        ierc20token reservetoken = reservetokens[0];

        
        if (totalsupply == _amount)
            return (reservebalance(reservetoken), 0);

        uint256 amount = ibancorformula(addressof(bancor_formula)).saletargetamount(
            totalsupply,
            reservebalance(reservetoken),
            reserves[reservetoken].weight,
            _amount
        );

        
        uint256 fee = calculatefee(amount);
        return (amount  fee, fee);
    }

    
    function buy(uint256 _amount, address _trader, address _beneficiary) internal returns (uint256) {
        
        (uint256 amount, uint256 fee) = purchasetargetamount(_amount);

        
        require(amount != 0, );

        ierc20token reservetoken = reservetokens[0];

        
        if (reservetoken == eth_reserve_address)
            require(msg.value == _amount, );
        else
            require(msg.value == 0 && reservetoken.balanceof(address(this)).sub(reservebalance(reservetoken)) >= _amount, );

        
        syncreservebalance(reservetoken);

        
        ismarttoken(address(anchor)).issue(_beneficiary, amount);

        
        dispatchconversionevent(reservetoken, ismarttoken(address(anchor)), _trader, _amount, amount, fee);

        return amount;
    }

    
    function sell(uint256 _amount, address _trader, address payable _beneficiary) internal returns (uint256) {
        
        require(_amount <= ismarttoken(address(anchor)).balanceof(address(this)), );

        
        (uint256 amount, uint256 fee) = saletargetamount(_amount);

        
        require(amount != 0, );

        ierc20token reservetoken = reservetokens[0];

        
        uint256 tokensupply = ismarttoken(address(anchor)).totalsupply();
        uint256 rsvbalance = reservebalance(reservetoken);
        assert(amount < rsvbalance || (amount == rsvbalance && _amount == tokensupply));

        
        ismarttoken(address(anchor)).destroy(address(this), _amount);

        
        reserves[reservetoken].balance = reserves[reservetoken].balance.sub(amount);

        
        if (reservetoken == eth_reserve_address)
            _beneficiary.transfer(amount);
        else
            safetransfer(reservetoken, _beneficiary, amount);

        
        dispatchconversionevent(ismarttoken(address(anchor)), reservetoken, _trader, _amount, amount, fee);

        return amount;
    }
}
