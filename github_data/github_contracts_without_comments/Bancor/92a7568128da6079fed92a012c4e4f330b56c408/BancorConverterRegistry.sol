pragma solidity 0.4.26;
import ;
import ;
import ;
import ;
import ;


contract bancorconverterregistry is ibancorconverterregistry, contractregistryclient {
    
    event smarttokenadded(address indexed _smarttoken);

    
    event smarttokenremoved(address indexed _smarttoken);

    
    event liquiditypooladded(address indexed _liquiditypool);

    
    event liquiditypoolremoved(address indexed _liquiditypool);

    
    event convertibletokenadded(address indexed _convertibletoken, address indexed _smarttoken);

    
    event convertibletokenremoved(address indexed _convertibletoken, address indexed _smarttoken);

    
    constructor(icontractregistry _registry) contractregistryclient(_registry) public {
    }

    
    function addconverter(ibancorconverter _converter) external {
        
        require(isconvertervalid(_converter));

        ibancorconverterregistrydata converterregistrydata = ibancorconverterregistrydata(addressof(bancor_converter_registry_data));
        ismarttoken token = ismarttokencontroller(_converter).token();
        uint reservetokencount = _converter.connectortokencount();

        
        addsmarttoken(converterregistrydata, token);
        if (reservetokencount > 1)
            addliquiditypool(converterregistrydata, token);
        else
            addconvertibletoken(converterregistrydata, token, token);

        
        for (uint i = 0; i < reservetokencount; i++)
            addconvertibletoken(converterregistrydata, _converter.connectortokens(i), token);
    }

    
    function removeconverter(ibancorconverter _converter) external {
      
        require(msg.sender == owner || !isconvertervalid(_converter));

        ibancorconverterregistrydata converterregistrydata = ibancorconverterregistrydata(addressof(bancor_converter_registry_data));
        ismarttoken token = ismarttokencontroller(_converter).token();
        uint reservetokencount = _converter.connectortokencount();

        
        removesmarttoken(converterregistrydata, token);
        if (reservetokencount > 1)
            removeliquiditypool(converterregistrydata, token);
        else
            removeconvertibletoken(converterregistrydata, token, token);

        
        for (uint i = 0; i < reservetokencount; i++)
            removeconvertibletoken(converterregistrydata, _converter.connectortokens(i), token);
    }

    
    function getsmarttokencount() external view returns (uint) {
        return ibancorconverterregistrydata(addressof(bancor_converter_registry_data)).getsmarttokencount();
    }

    
    function getsmarttokens() external view returns (address[]) {
        return ibancorconverterregistrydata(addressof(bancor_converter_registry_data)).getsmarttokens();
    }

    
    function getsmarttoken(uint _index) external view returns (address) {
        return ibancorconverterregistrydata(addressof(bancor_converter_registry_data)).getsmarttoken(_index);
    }

    
    function issmarttoken(address _value) external view returns (bool) {
        return ibancorconverterregistrydata(addressof(bancor_converter_registry_data)).issmarttoken(_value);
    }

    
    function getliquiditypoolcount() external view returns (uint) {
        return ibancorconverterregistrydata(addressof(bancor_converter_registry_data)).getliquiditypoolcount();
    }

    
    function getliquiditypools() external view returns (address[]) {
        return ibancorconverterregistrydata(addressof(bancor_converter_registry_data)).getliquiditypools();
    }

    
    function getliquiditypool(uint _index) external view returns (address) {
        return ibancorconverterregistrydata(addressof(bancor_converter_registry_data)).getliquiditypool(_index);
    }

    
    function isliquiditypool(address _value) external view returns (bool) {
        return ibancorconverterregistrydata(addressof(bancor_converter_registry_data)).isliquiditypool(_value);
    }

    
    function getconvertibletokencount() external view returns (uint) {
        return ibancorconverterregistrydata(addressof(bancor_converter_registry_data)).getconvertibletokencount();
    }

    
    function getconvertibletokens() external view returns (address[]) {
        return ibancorconverterregistrydata(addressof(bancor_converter_registry_data)).getconvertibletokens();
    }

    
    function getconvertibletoken(uint _index) external view returns (address) {
        return ibancorconverterregistrydata(addressof(bancor_converter_registry_data)).getconvertibletoken(_index);
    }

    
    function isconvertibletoken(address _value) external view returns (bool) {
        return ibancorconverterregistrydata(addressof(bancor_converter_registry_data)).isconvertibletoken(_value);
    }

    
    function getconvertibletokensmarttokencount(address _convertibletoken) external view returns (uint) {
        return ibancorconverterregistrydata(addressof(bancor_converter_registry_data)).getconvertibletokensmarttokencount(_convertibletoken);
    }

    
    function getconvertibletokensmarttokens(address _convertibletoken) external view returns (address[]) {
        return ibancorconverterregistrydata(addressof(bancor_converter_registry_data)).getconvertibletokensmarttokens(_convertibletoken);
    }

    
    function getconvertibletokensmarttoken(address _convertibletoken, uint _index) external view returns (address) {
        return ibancorconverterregistrydata(addressof(bancor_converter_registry_data)).getconvertibletokensmarttoken(_convertibletoken, _index);
    }

    
    function isconvertibletokensmarttoken(address _convertibletoken, address _value) external view returns (bool) {
        return ibancorconverterregistrydata(addressof(bancor_converter_registry_data)).isconvertibletokensmarttoken(_convertibletoken, _value);
    }

    
    function getconvertersbysmarttokens(address[] _smarttokens) external view returns (address[]) {
        address[] memory converters = new address[](_smarttokens.length);

        for (uint i = 0; i < _smarttokens.length; i++)
            converters[i] = ismarttoken(_smarttokens[i]).owner();

        return converters;
    }

    
    function isconvertervalid(ibancorconverter _converter) public view returns (bool) {
        ismarttoken token = ismarttokencontroller(_converter).token();

        
        if (token.totalsupply() == 0 || token.owner() != address(_converter) || !_converter.conversionsenabled())
            return false;

        uint reservetokencount = _converter.connectortokencount();
        address[] memory reservetokens = new address[](reservetokencount);
        uint[] memory reserveratios = new uint[](reservetokencount);

        
        for (uint i = 0; i < reservetokencount; i++) {
            ierc20token reservetoken = _converter.connectortokens(i);
            if (reservetoken.balanceof(_converter) == 0)
                return false;
            reservetokens[i] = reservetoken;
            reserveratios[i] = connectors(_converter, reservetoken);
        }

        return getliquiditypoolbyreserveconfig(reservetokens, reserveratios) == ibancorconverter(0);
    }

    
    function getliquiditypoolbyreserveconfig(address[] memory _reservetokens, uint[] memory _reserveratios) public view returns (ibancorconverter) {
        
        if (_reservetokens.length == _reserveratios.length && _reservetokens.length > 1) {

            
            address[] memory convertibletokensmarttokens = getleastfrequenttokensmarttokens(_reservetokens);
            for (uint i = 0; i < convertibletokensmarttokens.length; i++) {
                ismarttoken smarttoken = ismarttoken(convertibletokensmarttokens[i]);
                ibancorconverter converter = ibancorconverter(smarttoken.owner());

                
                uint reservetokencount = converter.connectortokencount();
                if (reservetokencount == _reservetokens.length) {
                    bool identical = true;
                    for (uint j = 0; j < reservetokencount; j++) {
                        ierc20token reservetoken = converter.connectortokens(j);
                        if (reservetoken != _reservetokens[j]) {
                            identical = false;
                            break;
                        }
                        uint256 ratio = connectors(converter, reservetoken);
                        if (ratio != _reserveratios[j]) {
                            identical = false;
                            break;
                        }
                    }
                    if (identical)
                        return converter;
                }
            }
        }

        return ibancorconverter(0);
    }

    
    function addsmarttoken(ibancorconverterregistrydata _converterregistrydata, address _smarttoken) internal {
        _converterregistrydata.addsmarttoken(_smarttoken);
        emit smarttokenadded(_smarttoken);
    }

    
    function removesmarttoken(ibancorconverterregistrydata _converterregistrydata, address _smarttoken) internal {
        _converterregistrydata.removesmarttoken(_smarttoken);
        emit smarttokenremoved(_smarttoken);
    }

    
    function addliquiditypool(ibancorconverterregistrydata _converterregistrydata, address _liquiditypool) internal {
        _converterregistrydata.addliquiditypool(_liquiditypool);
        emit liquiditypooladded(_liquiditypool);
    }

    
    function removeliquiditypool(ibancorconverterregistrydata _converterregistrydata, address _liquiditypool) internal {
        _converterregistrydata.removeliquiditypool(_liquiditypool);
        emit liquiditypoolremoved(_liquiditypool);
    }

    
    function addconvertibletoken(ibancorconverterregistrydata _converterregistrydata, address _convertibletoken, address _smarttoken) internal {
        _converterregistrydata.addconvertibletoken(_convertibletoken, _smarttoken);
        emit convertibletokenadded(_convertibletoken, _smarttoken);
    }

    
    function removeconvertibletoken(ibancorconverterregistrydata _converterregistrydata, address _convertibletoken, address _smarttoken) internal {
        _converterregistrydata.removeconvertibletoken(_convertibletoken, _smarttoken);
        emit convertibletokenremoved(_convertibletoken, _smarttoken);
    }

    function getleastfrequenttokensmarttokens(address[] memory _tokens) private view returns (address[] memory) {
        ibancorconverterregistrydata bancorconverterregistrydata = ibancorconverterregistrydata(addressof(bancor_converter_registry_data));

        
        uint minsmarttokencount = bancorconverterregistrydata.getconvertibletokensmarttokencount(_tokens[0]);
        address[] memory smarttokens = bancorconverterregistrydata.getconvertibletokensmarttokens(_tokens[0]);
        for (uint i = 1; i < _tokens.length; i++) {
            uint convertibletokensmarttokencount = bancorconverterregistrydata.getconvertibletokensmarttokencount(_tokens[i]);
            if (minsmarttokencount > convertibletokensmarttokencount) {
                minsmarttokencount = convertibletokensmarttokencount;
                smarttokens = bancorconverterregistrydata.getconvertibletokensmarttokens(_tokens[i]);
            }
        }
        return smarttokens;
    }

    bytes4 private constant connectors_func_selector = bytes4(uint256(keccak256() >> (256  4 * 8)));

    function connectors(address _dest, address _address) private view returns (uint256) {
        uint256[2] memory ret;
        bytes memory data = abi.encodewithselector(connectors_func_selector, _address);

        assembly {
            let success := staticcall(
                gas,           
                _dest,         
                add(data, 32), 
                mload(data),   
                ret,           
                64             
            )
            if iszero(success) {
                revert(0, 0)
            }
        }

        return ret[1];
    }
}
