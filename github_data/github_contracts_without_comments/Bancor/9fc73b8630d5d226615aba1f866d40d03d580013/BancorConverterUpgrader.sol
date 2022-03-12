pragma solidity ^0.4.21;
import ;
import ;
import ;


contract ibancorconverter is iowned {
    function token() public view returns (ismarttoken) {}
    function conversionwhitelist() public view returns (iwhitelist) {}
    function extensions() public view returns (ibancorconverterextensions) {}
    function quickbuypath(uint256 _index) public view returns (ierc20token) { _index; }
    function maxconversionfee() public view returns (uint32) {}
    function conversionfee() public view returns (uint32) {}
    function connectortokencount() public view returns (uint16);
    function reservetokencount() public view returns (uint16);
    function connectortokens(uint256 _index) public view returns (ierc20token) { _index; }
    function reservetokens(uint256 _index) public view returns (ierc20token) { _index; }
    function setconversionwhitelist() public view returns (iwhitelist) {}
    function setextensions(ibancorconverterextensions _extensions) public view;
    function getquickbuypathlength() public view returns (uint256);
    function transfertokenownership(address _newowner) public view;
    function withdrawtokens(ierc20token _token, address _to, uint256 _amount) public view;
    function accepttokenownership() public view;
    function transfermanagement(address _newmanager) public view;
    function acceptmanagement() public;
    function setconversionfee(uint32 _conversionfee) public view;
    function setquickbuypath(ierc20token[] _path) public view;
    function addconnector(ierc20token _token, uint32 _weight, bool _enablevirtualbalance) public view;
    function getconnectorbalance(ierc20token _connectortoken) public view returns (uint256);
    function getreservebalance(ierc20token _reservetoken) public view returns (uint256);
    function connectors(address _address) public view returns (
        uint256 virtualbalance, 
        uint32 weight, 
        bool isvirtualbalanceenabled, 
        bool ispurchaseenabled, 
        bool isset
    );
    function reserves(address _address) public view returns (
        uint256 virtualbalance, 
        uint32 weight, 
        bool isvirtualbalanceenabled, 
        bool ispurchaseenabled, 
        bool isset
    );
}


contract bancorconverterupgrader is owned {
    ibancorconverterfactory public bancorconverterfactory;  

    
    event converterowned(address indexed _converter, address indexed _owner);
    
    event converterupgrade(address indexed _oldconverter, address indexed _newconverter);

    
    function bancorconverterupgrader(ibancorconverterfactory _bancorconverterfactory)
        public
    {
        bancorconverterfactory = _bancorconverterfactory;
    }

    
    function setbancorconverterfactory(ibancorconverterfactory _bancorconverterfactory) public owneronly
    {
        bancorconverterfactory = _bancorconverterfactory;
    }

    
    function upgrade(ibancorconverter _oldconverter, bytes32 _version) public {
        bool formerversions = false;
        if (_version == )
            formerversions = true;
        acceptconverterownership(_oldconverter);
        ibancorconverter newconverter = createconverter(_oldconverter, _version);
        copyconnectors(_oldconverter, newconverter, formerversions);
        copyconversionfee(_oldconverter, newconverter);
        copyquickbuypath(_oldconverter, newconverter);
        transferconnectorsbalances(_oldconverter, newconverter, formerversions);
        _oldconverter.transfertokenownership(newconverter);
        newconverter.accepttokenownership();
        _oldconverter.transferownership(msg.sender);
        newconverter.transferownership(msg.sender);
        newconverter.transfermanagement(msg.sender);

        emit converterupgrade(address(_oldconverter), address(newconverter));
    }

    
    function acceptconverterownership(ibancorconverter _oldconverter) private {
        require(msg.sender == _oldconverter.owner());
        _oldconverter.acceptownership();
        emit converterowned(_oldconverter, this);
    }

    
    function createconverter(ibancorconverter _oldconverter, bytes32 _version) private returns(ibancorconverter) {
        ismarttoken token = _oldconverter.token();
        ibancorconverterextensions extensions = _oldconverter.extensions();
        uint32 maxconversionfee = _oldconverter.maxconversionfee();

        address converteradderess  = bancorconverterfactory.createconverter(
            token,
            icontractfeatures(address(0)),
            extensions,
            maxconversionfee,
            ierc20token(address(0)),
            0
        );

        ibancorconverter converter = ibancorconverter(converteradderess);
        converter.acceptownership();
        converter.acceptmanagement();
        return converter;
    }

    
    function copyconnectors(ibancorconverter _oldconverter, ibancorconverter _newconverter, bool _islegacyversion)
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
        }
    }

    
    function copyconversionfee(ibancorconverter _oldconverter, ibancorconverter _newconverter) private {
        uint32 conversionfee = _oldconverter.conversionfee();
        _newconverter.setconversionfee(conversionfee);
    }

    
    function copyquickbuypath(ibancorconverter _oldconverter, ibancorconverter _newconverter) private {
        uint256 quickbuypathlength = _oldconverter.getquickbuypathlength();
        if (quickbuypathlength <= 0)
            return;

        ierc20token[] memory path = new ierc20token[](quickbuypathlength);
        for (uint256 i = 0; i < quickbuypathlength; i++) {
            path[i] = _oldconverter.quickbuypath(i);
        }

        _newconverter.setquickbuypath(path);
    }

    
    function transferconnectorsbalances(ibancorconverter _oldconverter, ibancorconverter _newconverter, bool _islegacyversion)
        private
    {
        uint256 connectorbalance;
        uint16 connectortokencount = _islegacyversion ? _oldconverter.reservetokencount() : _oldconverter.connectortokencount();

        for (uint16 i = 0; i < connectortokencount; i++) {
            address connectoraddress = _islegacyversion ? _oldconverter.reservetokens(i) : _oldconverter.connectortokens(i);
            ierc20token connector = ierc20token(connectoraddress);
            connectorbalance = _islegacyversion ? _oldconverter.getreservebalance(connector) : _oldconverter.getconnectorbalance(connector);
            _oldconverter.withdrawtokens(connector, address(_newconverter), connectorbalance);
        }
    }

    
    function readconnector(ibancorconverter _converter, address _address, bool _islegacyversion) 
        private
        view
        returns(uint256 virtualbalance, uint32 weight, bool isvirtualbalanceenabled, bool ispurchaseenabled, bool isset)
    {
        return _islegacyversion ? _converter.reserves(_address) : _converter.connectors(_address);
    }
}