pragma solidity ^0.4.24;
import ;
import ;
import ;


contract bancorconverterfactory is ibancorconverterfactory {
    
    event newconverter(address indexed _converter, address indexed _owner);

    
    constructor() public {
    }

    
    function createconverter(
        ismarttoken _token,
        icontractregistry _registry,
        uint32 _maxconversionfee,
        ierc20token _connectortoken,
        uint32 _connectorweight
    ) public returns(address converteraddress) {
        bancorconverter converter = new bancorconverter(
            _token,
            _registry,
            _maxconversionfee,
            _connectortoken,
            _connectorweight
        );

        converter.transferownership(msg.sender);
        converter.transfermanagement(msg.sender);

        address _converteraddress = address(converter);
        emit newconverter(_converteraddress, msg.sender);
        return _converteraddress;
    }
}
