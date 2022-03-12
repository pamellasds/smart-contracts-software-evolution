
pragma solidity 0.6.12;
import ;


abstract contract liquiditypoolconverter is converterbase {
    
    event liquidityadded(
        address indexed _provider,
        ierc20token indexed _reservetoken,
        uint256 _amount,
        uint256 _newbalance,
        uint256 _newsupply
    );

    
    event liquidityremoved(
        address indexed _provider,
        ierc20token indexed _reservetoken,
        uint256 _amount,
        uint256 _newbalance,
        uint256 _newsupply
    );

    
    constructor(
        iconverteranchor _anchor,
        icontractregistry _registry,
        uint32 _maxconversionfee
    )
        converterbase(_anchor, _registry, _maxconversionfee)
        internal
    {
    }

    
    function acceptanchorownership() public virtual override {
        
        require(reservetokencount() > 1, );
        super.acceptanchorownership();
    }
}
