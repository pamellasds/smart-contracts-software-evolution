pragma solidity ^0.4.21;
import ;
import ;
import ;


contract bancorconverterfactory is ibancorconverterfactory {
    
    event newconverter(address indexed _converter, address indexed _owner);

    
    function bancorconverterfactory() public {
    }

    
    function createconverter(
        ismarttoken _token,
        icontractregistry _registry,
        ibancorconverterextensions _extensions,
        uint32 _maxconversionfee,
        ierc20token _connectortoken,
        uint32 _connectorweight
    ) public returns(address converteraddress) {
        bancorconverter converter = new bancorconverter(
            _token,
            _registry,
            _extensions,
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
