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

    
    function isconvertervalid(ibancorconverter _converter) public view returns (bool) {
        ismarttoken token = ismarttokencontroller(_converter).token();

        
        if (token.totalsupply() == 0 || token.owner() != address(_converter))
            return false;

        
        uint reservetokencount = _converter.connectortokencount();
        for (uint i = 0; i < reservetokencount; i++) {
            ierc20token reservetoken = _converter.connectortokens(i);
            if (reservetoken.balanceof(_converter) == 0)
                return false;
        }

        return true;
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
}
