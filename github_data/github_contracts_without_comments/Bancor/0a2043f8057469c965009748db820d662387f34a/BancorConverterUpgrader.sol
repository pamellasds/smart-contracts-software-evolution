pragma solidity 0.4.26;
import ;
import ;
import ;
import ;
import ;
import ;
import ;


contract ibancorconverterextended is ibancorconverter, iowned {
    function token() public view returns (ismarttoken) {this;}
    function maxconversionfee() public view returns (uint32) {this;}
    function conversionfee() public view returns (uint32) {this;}
    function connectortokencount() public view returns (uint16);
    function reservetokencount() public view returns (uint16);
    function connectortokens(uint256 _index) public view returns (ierc20token) {_index; this;}
    function reservetokens(uint256 _index) public view returns (ierc20token) {_index; this;}
    function setconversionwhitelist(iwhitelist _whitelist) public;
    function transfertokenownership(address _newowner) public;
    function withdrawtokens(ierc20token _token, address _to, uint256 _amount) public;
    function accepttokenownership() public;
    function setconversionfee(uint32 _conversionfee) public;
    function addconnector(ierc20token _token, uint32 _weight, bool _enablevirtualbalance) public;
    function updateconnector(ierc20token _connectortoken, uint32 _weight, bool _enablevirtualbalance, uint256 _virtualbalance) public;
}


contract bancorconverterupgrader is ibancorconverterupgrader, contractregistryclient, featureids {
    string public version = ;

    
    event converterowned(address indexed _converter, address indexed _owner);

    
    event converterupgrade(address indexed _oldconverter, address indexed _newconverter);

    
    constructor(icontractregistry _registry) contractregistryclient(_registry) public {
    }

    
    function upgrade(bytes32 _version) public {
        upgradeold(ibancorconverter(msg.sender), _version);
    }

    
    function upgrade(uint16 _version) public {
        upgradeold(ibancorconverter(msg.sender), bytes32(_version));
    }

    
    function upgradeold(ibancorconverter _converter, bytes32 _version) public {
        _version;
        ibancorconverterextended converter = ibancorconverterextended(_converter);
        address prevowner = converter.owner();
        acceptconverterownership(converter);
        ibancorconverterextended newconverter = createconverter(converter);
        copyconnectors(converter, newconverter);
        copyconversionfee(converter, newconverter);
        transferconnectorsbalances(converter, newconverter);                
        ismarttoken token = converter.token();

        if (token.owner() == address(converter)) {
            converter.transfertokenownership(newconverter);
            newconverter.accepttokenownership();
        }

        converter.transferownership(prevowner);
        newconverter.transferownership(prevowner);

        emit converterupgrade(address(converter), address(newconverter));
    }

    
    function acceptconverterownership(ibancorconverterextended _oldconverter) private {
        _oldconverter.acceptownership();
        emit converterowned(_oldconverter, this);
    }

    
    function createconverter(ibancorconverterextended _oldconverter) private returns(ibancorconverterextended) {
        iwhitelist whitelist;
        ismarttoken token = _oldconverter.token();
        uint32 maxconversionfee = _oldconverter.maxconversionfee();

        ibancorconverterfactory converterfactory = ibancorconverterfactory(addressof(bancor_converter_factory));
        address converteraddress = converterfactory.createconverter(
            token,
            registry,
            maxconversionfee,
            ierc20token(address(0)),
            0
        );

        ibancorconverterextended converter = ibancorconverterextended(converteraddress);
        converter.acceptownership();

        
        icontractfeatures features = icontractfeatures(addressof(contract_features));

        if (features.issupported(_oldconverter, featureids.converter_conversion_whitelist)) {
            whitelist = _oldconverter.conversionwhitelist();
            if (whitelist != address(0))
                converter.setconversionwhitelist(whitelist);
        }

        return converter;
    }

    
    function copyconnectors(ibancorconverterextended _oldconverter, ibancorconverterextended _newconverter)
        private
    {
        uint256 virtualbalance;
        uint32 weight;
        bool isvirtualbalanceenabled;
        uint16 connectortokencount = _oldconverter.connectortokencount();

        for (uint16 i = 0; i < connectortokencount; i++) {
            address connectoraddress = _oldconverter.connectortokens(i);
            (virtualbalance, weight, isvirtualbalanceenabled, , ) = _oldconverter.connectors(connectoraddress);

            ierc20token connectortoken = ierc20token(connectoraddress);
            _newconverter.addconnector(connectortoken, weight, isvirtualbalanceenabled);

            if (isvirtualbalanceenabled)
                _newconverter.updateconnector(connectortoken, weight, isvirtualbalanceenabled, virtualbalance);
        }
    }

    
    function copyconversionfee(ibancorconverterextended _oldconverter, ibancorconverterextended _newconverter) private {
        uint32 conversionfee = _oldconverter.conversionfee();
        _newconverter.setconversionfee(conversionfee);
    }

    
    function transferconnectorsbalances(ibancorconverterextended _oldconverter, ibancorconverterextended _newconverter)
        private
    {
        uint256 connectorbalance;
        uint16 connectortokencount = _oldconverter.connectortokencount();

        for (uint16 i = 0; i < connectortokencount; i++) {
            address connectoraddress = _oldconverter.connectortokens(i);
            ierc20token connector = ierc20token(connectoraddress);
            connectorbalance = connector.balanceof(_oldconverter);
            _oldconverter.withdrawtokens(connector, address(_newconverter), connectorbalance);
        }
    }
}
