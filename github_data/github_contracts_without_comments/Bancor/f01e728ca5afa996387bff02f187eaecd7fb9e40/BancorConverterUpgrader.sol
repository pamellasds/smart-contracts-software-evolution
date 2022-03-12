pragma solidity ^0.4.23;
import ;
import ;
import ;
import ;
import ;
import ;
import ;
import ;
import ;


contract ibancorconverterextended is ibancorconverter, iowned {
    function token() public view returns (ismarttoken) {}
    function quickbuypath(uint256 _index) public view returns (ierc20token) { _index; }
    function maxconversionfee() public view returns (uint32) {}
    function conversionfee() public view returns (uint32) {}
    function connectortokencount() public view returns (uint16);
    function reservetokencount() public view returns (uint16);
    function connectortokens(uint256 _index) public view returns (ierc20token) { _index; }
    function reservetokens(uint256 _index) public view returns (ierc20token) { _index; }
    function setconversionwhitelist(iwhitelist _whitelist) public;
    function getquickbuypathlength() public view returns (uint256);
    function transfertokenownership(address _newowner) public;
    function withdrawtokens(ierc20token _token, address _to, uint256 _amount) public;
    function accepttokenownership() public;
    function transfermanagement(address _newmanager) public;
    function acceptmanagement() public;
    function setconversionfee(uint32 _conversionfee) public;
    function setquickbuypath(ierc20token[] _path) public;
    function addconnector(ierc20token _token, uint32 _weight, bool _enablevirtualbalance) public;
    function updateconnector(ierc20token _connectortoken, uint32 _weight, bool _enablevirtualbalance, uint256 _virtualbalance) public;
    function getconnectorbalance(ierc20token _connectortoken) public view returns (uint256);
    function getreservebalance(ierc20token _reservetoken) public view returns (uint256);
    function reserves(address _address) public view returns (
        uint256 virtualbalance, 
        uint32 weight, 
        bool isvirtualbalanceenabled, 
        bool ispurchaseenabled, 
        bool isset
    );
}


contract bancorconverterupgrader is ibancorconverterupgrader, owned, contractids, featureids {
    string public version = ;

    icontractregistry public registry;                      

    
    event converterowned(address indexed _converter, address indexed _owner);
    
    event converterupgrade(address indexed _oldconverter, address indexed _newconverter);

    
    constructor(icontractregistry _registry) public {
        registry = _registry;
    }

    
    function setregistry(icontractregistry _registry) public owneronly {
        registry = _registry;
    }

    
    function upgrade(bytes32 _version) public {
        upgradeold(ibancorconverter(msg.sender), _version);
    }

    
    function upgradeold(ibancorconverter _converter, bytes32 _version) public {
        bool formerversions = false;
        if (_version == )
            formerversions = true;
        ibancorconverterextended converter = ibancorconverterextended(_converter);
        address prevowner = converter.owner();
        acceptconverterownership(converter);
        ibancorconverterextended newconverter = createconverter(converter);
        copyconnectors(converter, newconverter, formerversions);
        copyconversionfee(converter, newconverter);
        copyquickbuypath(converter, newconverter);
        transferconnectorsbalances(converter, newconverter, formerversions);                
        ismarttoken token = converter.token();

        if (token.owner() == address(converter)) {
            converter.transfertokenownership(newconverter);
            newconverter.accepttokenownership();
        }

        converter.transferownership(prevowner);
        newconverter.transferownership(prevowner);
        newconverter.transfermanagement(prevowner);

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

        ibancorconverterfactory converterfactory = ibancorconverterfactory(registry.addressof(contractids.bancor_converter_factory));
        address converteraddress  = converterfactory.createconverter(
            token,
            registry,
            maxconversionfee,
            ierc20token(address(0)),
            0
        );

        ibancorconverterextended converter = ibancorconverterextended(converteraddress);
        converter.acceptownership();
        converter.acceptmanagement();

        
        icontractfeatures features = icontractfeatures(registry.addressof(contractids.contract_features));

        if (features.issupported(_oldconverter, featureids.converter_conversion_whitelist)) {
            whitelist = _oldconverter.conversionwhitelist();
            if (whitelist != address(0))
                converter.setconversionwhitelist(whitelist);
        }

        return converter;
    }

    
    function copyconnectors(ibancorconverterextended _oldconverter, ibancorconverterextended _newconverter, bool _islegacyversion)
        private
    {
        uint256 virtualbalance;
        uint32 weight;
        bool isvirtualbalanceenabled;
        bool ispurchaseenabled;
        bool isset;
        uint16 connectortokencount = _islegacyversion ? _oldconverter.reservetokencount() : _oldconverter.connectortokencount();

        for (uint16 i = 0; i < connectortokencount; i++) {
            address connectoraddress = _islegacyversion ? _oldconverter.reservetokens(i) : _oldconverter.connectortokens(i);
            (virtualbalance, weight, isvirtualbalanceenabled, ispurchaseenabled, isset) = readconnector(
                _oldconverter,
                connectoraddress,
                _islegacyversion
            );

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

    
    function copyquickbuypath(ibancorconverterextended _oldconverter, ibancorconverterextended _newconverter) private {
        uint256 quickbuypathlength = _oldconverter.getquickbuypathlength();
        if (quickbuypathlength <= 0)
            return;

        ierc20token[] memory path = new ierc20token[](quickbuypathlength);
        for (uint256 i = 0; i < quickbuypathlength; i++) {
            path[i] = _oldconverter.quickbuypath(i);
        }

        _newconverter.setquickbuypath(path);
    }

    
    function transferconnectorsbalances(ibancorconverterextended _oldconverter, ibancorconverterextended _newconverter, bool _islegacyversion)
        private
    {
        uint256 connectorbalance;
        uint16 connectortokencount = _islegacyversion ? _oldconverter.reservetokencount() : _oldconverter.connectortokencount();

        for (uint16 i = 0; i < connectortokencount; i++) {
            address connectoraddress = _islegacyversion ? _oldconverter.reservetokens(i) : _oldconverter.connectortokens(i);
            ierc20token connector = ierc20token(connectoraddress);
            connectorbalance = connector.balanceof(_oldconverter);
            _oldconverter.withdrawtokens(connector, address(_newconverter), connectorbalance);
        }
    }

    
    function readconnector(ibancorconverterextended _converter, address _address, bool _islegacyversion) 
        private
        view
        returns(uint256 virtualbalance, uint32 weight, bool isvirtualbalanceenabled, bool ispurchaseenabled, bool isset)
    {
        return _islegacyversion ? _converter.reserves(_address) : _converter.connectors(_address);
    }
}