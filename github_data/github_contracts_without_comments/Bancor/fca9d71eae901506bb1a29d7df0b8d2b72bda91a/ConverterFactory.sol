pragma solidity 0.4.26;
import ;
import ;
import ;
import ;
import ;
import ;
import ;
import ;


contract converterfactory is iconverterfactory, owned {
    
    event newconverter(address indexed _converter, address indexed _owner);

    mapping (uint16 => itypedconverterfactory) public converterfactories;
    mapping (uint16 => itypedconverteranchorfactory) public anchorfactories;
    mapping (uint16 => itypedconvertercustomfactory) public customfactories;

    
    function registertypedconverterfactory(itypedconverterfactory _factory) public owneronly {
        converterfactories[_factory.convertertype()] = _factory;
    }

    
    function registertypedconverteranchorfactory(itypedconverteranchorfactory _factory) public owneronly {
        anchorfactories[_factory.convertertype()] = _factory;
    }

    
    function registertypedconvertercustomfactory(itypedconvertercustomfactory _factory) public owneronly {
        customfactories[_factory.convertertype()] = _factory;
    }

    
    function createanchor(uint16 _convertertype, string _name, string _symbol, uint8 _decimals) public returns (iconverteranchor) {
        iconverteranchor anchor;
        itypedconverteranchorfactory factory = anchorfactories[_convertertype];

        if (factory == address(0)) {
            
            anchor = new smarttoken(_name, _symbol, _decimals);
        }
        else {
            
            anchor = factory.createanchor(_name, _symbol, _decimals);
            anchor.acceptownership();
        }

        anchor.transferownership(msg.sender);
        return anchor;
    }

    
    function createconverter(uint16 _type, iconverteranchor _anchor, icontractregistry _registry, uint32 _maxconversionfee) public returns (iconverter) {
        iconverter converter = converterfactories[_type].createconverter(_anchor, _registry, _maxconversionfee);
        converter.acceptownership();
        converter.transferownership(msg.sender);

        emit newconverter(converter, msg.sender);
        return converter;
    }
}
