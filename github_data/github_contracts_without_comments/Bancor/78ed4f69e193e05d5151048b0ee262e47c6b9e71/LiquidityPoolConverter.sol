pragma solidity 0.4.26;
import ;


contract liquiditypoolconverter is converterbase {
    
    event liquidityadded(
        address indexed _provider,
        address indexed _reservetoken,
        uint256 _amount,
        uint256 _newbalance,
        uint256 _newsupply
    );

    
    event liquidityremoved(
        address indexed _provider,
        address indexed _reservetoken,
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

    
    function acceptanchorownership() public {
        
        require(reservetokencount() > 1, );
        super.acceptanchorownership();
    }
}
