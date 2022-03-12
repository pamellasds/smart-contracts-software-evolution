pragma solidity 0.4.26;
import ;
import ;
import ;
import ;
import ;
import ;


contract converterregistry is iconverterregistry, contractregistryclient, tokenhandler {
    address private constant eth_reserve_address = 0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee;

    
    event converteranchoradded(address indexed _anchor);

    
    event converteranchorremoved(address indexed _anchor);

    
    event liquiditypooladded(address indexed _liquiditypool);

    
    event liquiditypoolremoved(address indexed _liquiditypool);

    
    event convertibletokenadded(address indexed _convertibletoken, address indexed _smarttoken);

    
    event convertibletokenremoved(address indexed _convertibletoken, address indexed _smarttoken);

    
    event smarttokenadded(address indexed _smarttoken);

    
    event smarttokenremoved(address indexed _smarttoken);

    
    constructor(icontractregistry _registry) contractregistryclient(_registry) public {
    }

    
    function newconverter(
        uint16 _type,
        string _name,
        string _symbol,
        uint8 _decimals,
        uint32 _maxconversionfee,
        ierc20token[] memory _reservetokens,
        uint32[] memory _reserveweights
    )
    public returns (iconverter)
    {
        uint256 length = _reservetokens.length;
        require(length == _reserveweights.length, );
        require(getliquiditypoolbyconfig(_type, _reservetokens, _reserveweights) == iconverteranchor(0), );

        iconverterfactory factory = iconverterfactory(addressof(converter_factory));
        iconverteranchor anchor = iconverteranchor(factory.createanchor(_type, _name, _symbol, _decimals));
        iconverter converter = iconverter(factory.createconverter(_type, anchor, registry, _maxconversionfee));

        anchor.acceptownership();
        converter.acceptownership();

        for (uint256 i = 0; i < length; i++)
            converter.addreserve(_reservetokens[i], _reserveweights[i]);

        anchor.transferownership(converter);
        converter.acceptanchorownership();
        converter.transferownership(msg.sender);

        addconverterinternal(converter);
        return converter;
    }

    
    function addconverter(iconverter _converter) public owneronly {
        require(isconvertervalid(_converter), );
        addconverterinternal(_converter);
    }

    
    function removeconverter(iconverter _converter) public {
        require(msg.sender == owner || !isconvertervalid(_converter), );
        removeconverterinternal(_converter);
    }

    
    function getanchorcount() public view returns (uint256) {
        return iconverterregistrydata(addressof(converter_registry_data)).getsmarttokencount();
    }

    
    function getanchors() public view returns (address[]) {
        return iconverterregistrydata(addressof(converter_registry_data)).getsmarttokens();
    }

    
    function getanchor(uint256 _index) public view returns (address) {
        return iconverterregistrydata(addressof(converter_registry_data)).getsmarttoken(_index);
    }

    
    function isanchor(address _value) public view returns (bool) {
        return iconverterregistrydata(addressof(converter_registry_data)).issmarttoken(_value);
    }

    
    function getliquiditypoolcount() public view returns (uint256) {
        return iconverterregistrydata(addressof(converter_registry_data)).getliquiditypoolcount();
    }

    
    function getliquiditypools() public view returns (address[]) {
        return iconverterregistrydata(addressof(converter_registry_data)).getliquiditypools();
    }

    
    function getliquiditypool(uint256 _index) public view returns (address) {
        return iconverterregistrydata(addressof(converter_registry_data)).getliquiditypool(_index);
    }

    
    function isliquiditypool(address _value) public view returns (bool) {
        return iconverterregistrydata(addressof(converter_registry_data)).isliquiditypool(_value);
    }

    
    function getconvertibletokencount() public view returns (uint256) {
        return iconverterregistrydata(addressof(converter_registry_data)).getconvertibletokencount();
    }

    
    function getconvertibletokens() public view returns (address[]) {
        return iconverterregistrydata(addressof(converter_registry_data)).getconvertibletokens();
    }

    
    function getconvertibletoken(uint256 _index) public view returns (address) {
        return iconverterregistrydata(addressof(converter_registry_data)).getconvertibletoken(_index);
    }

    
    function isconvertibletoken(address _value) public view returns (bool) {
        return iconverterregistrydata(addressof(converter_registry_data)).isconvertibletoken(_value);
    }

    
    function getconvertibletokenanchorcount(address _convertibletoken) public view returns (uint256) {
        return iconverterregistrydata(addressof(converter_registry_data)).getconvertibletokensmarttokencount(_convertibletoken);
    }

    
    function getconvertibletokenanchors(address _convertibletoken) public view returns (address[]) {
        return iconverterregistrydata(addressof(converter_registry_data)).getconvertibletokensmarttokens(_convertibletoken);
    }

    
    function getconvertibletokenanchor(address _convertibletoken, uint256 _index) public view returns (address) {
        return iconverterregistrydata(addressof(converter_registry_data)).getconvertibletokensmarttoken(_convertibletoken, _index);
    }

    
    function isconvertibletokenanchor(address _convertibletoken, address _value) public view returns (bool) {
        return iconverterregistrydata(addressof(converter_registry_data)).isconvertibletokensmarttoken(_convertibletoken, _value);
    }

    
    function getconvertersbyanchors(address[] _anchors) public view returns (address[]) {
        address[] memory converters = new address[](_anchors.length);

        for (uint256 i = 0; i < _anchors.length; i++)
            converters[i] = iconverteranchor(_anchors[i]).owner();

        return converters;
    }

    
    function isconvertervalid(iconverter _converter) public view returns (bool) {
        
        return _converter.token().owner() == address(_converter);
    }

    
    function issimilarliquiditypoolregistered(iconverter _converter) public view returns (bool) {
        uint256 reservetokencount = _converter.connectortokencount();
        ierc20token[] memory reservetokens = new ierc20token[](reservetokencount);
        uint32[] memory reserveweights = new uint32[](reservetokencount);

        
        for (uint256 i = 0; i < reservetokencount; i++) {
            ierc20token reservetoken = _converter.connectortokens(i);
            reservetokens[i] = reservetoken;
            reserveweights[i] = getreserveweight(_converter, reservetoken);
        }

        
        return getliquiditypoolbyconfig(_converter.convertertype(), reservetokens, reserveweights) != iconverteranchor(0);
    }

    
    function getliquiditypoolbyconfig(uint16 _type, ierc20token[] memory _reservetokens, uint32[] memory _reserveweights) public view returns (iconverteranchor) {
        
        if (_reservetokens.length == _reserveweights.length && _reservetokens.length > 1) {
            
            address[] memory convertibletokenanchors = getleastfrequenttokenanchors(_reservetokens);
            
            for (uint256 i = 0; i < convertibletokenanchors.length; i++) {
                iconverteranchor anchor = iconverteranchor(convertibletokenanchors[i]);
                iconverter converter = iconverter(anchor.owner());
                if (isconverterreserveconfigequal(converter, _type, _reservetokens, _reserveweights))
                    return anchor;
            }
        }

        return iconverteranchor(0);
    }

    
    function addanchor(iconverterregistrydata _converterregistrydata, address _anchor) internal {
        _converterregistrydata.addsmarttoken(_anchor);
        emit converteranchoradded(_anchor);
        emit smarttokenadded(_anchor);
    }

    
    function removeanchor(iconverterregistrydata _converterregistrydata, address _anchor) internal {
        _converterregistrydata.removesmarttoken(_anchor);
        emit converteranchorremoved(_anchor);
        emit smarttokenremoved(_anchor);
    }

    
    function addliquiditypool(iconverterregistrydata _converterregistrydata, address _liquiditypool) internal {
        _converterregistrydata.addliquiditypool(_liquiditypool);
        emit liquiditypooladded(_liquiditypool);
    }

    
    function removeliquiditypool(iconverterregistrydata _converterregistrydata, address _liquiditypool) internal {
        _converterregistrydata.removeliquiditypool(_liquiditypool);
        emit liquiditypoolremoved(_liquiditypool);
    }

    
    function addconvertibletoken(iconverterregistrydata _converterregistrydata, address _convertibletoken, address _anchor) internal {
        _converterregistrydata.addconvertibletoken(_convertibletoken, _anchor);
        emit convertibletokenadded(_convertibletoken, _anchor);
    }

    
    function removeconvertibletoken(iconverterregistrydata _converterregistrydata, address _convertibletoken, address _anchor) internal {
        _converterregistrydata.removeconvertibletoken(_convertibletoken, _anchor);
        emit convertibletokenremoved(_convertibletoken, _anchor);
    }

    function addconverterinternal(iconverter _converter) private {
        iconverterregistrydata converterregistrydata = iconverterregistrydata(addressof(converter_registry_data));
        iconverteranchor anchor = iconverter(_converter).token();
        uint256 reservetokencount = _converter.connectortokencount();

        
        addanchor(converterregistrydata, anchor);
        if (reservetokencount > 1)
            addliquiditypool(converterregistrydata, anchor);
        else
            addconvertibletoken(converterregistrydata, anchor, anchor);

        
        for (uint256 i = 0; i < reservetokencount; i++)
            addconvertibletoken(converterregistrydata, _converter.connectortokens(i), anchor);
    }

    function removeconverterinternal(iconverter _converter) private {
        iconverterregistrydata converterregistrydata = iconverterregistrydata(addressof(converter_registry_data));
        iconverteranchor anchor = iconverter(_converter).token();
        uint256 reservetokencount = _converter.connectortokencount();

        
        removeanchor(converterregistrydata, anchor);
        if (reservetokencount > 1)
            removeliquiditypool(converterregistrydata, anchor);
        else
            removeconvertibletoken(converterregistrydata, anchor, anchor);

        
        for (uint256 i = 0; i < reservetokencount; i++)
            removeconvertibletoken(converterregistrydata, _converter.connectortokens(i), anchor);
    }

    function getleastfrequenttokenanchors(ierc20token[] memory _reservetokens) private view returns (address[] memory) {
        iconverterregistrydata converterregistrydata = iconverterregistrydata(addressof(converter_registry_data));
        uint256 minanchorcount = converterregistrydata.getconvertibletokensmarttokencount(_reservetokens[0]);
        uint256 index = 0;

        
        for (uint256 i = 1; i < _reservetokens.length; i++) {
            uint256 convertibletokenanchorcount = converterregistrydata.getconvertibletokensmarttokencount(_reservetokens[i]);
            if (minanchorcount > convertibletokenanchorcount) {
                minanchorcount = convertibletokenanchorcount;
                index = i;
            }
        }

        return converterregistrydata.getconvertibletokensmarttokens(_reservetokens[index]);
    }

    function isconverterreserveconfigequal(iconverter _converter, uint16 _type, ierc20token[] memory _reservetokens, uint32[] memory _reserveweights) private view returns (bool) {
        if (_type != _converter.convertertype())
            return false;

        if (_reservetokens.length != _converter.connectortokencount())
            return false;

        for (uint256 i = 0; i < _reservetokens.length; i++) {
            if (_reserveweights[i] != getreserveweight(_converter, _reservetokens[i]))
                return false;
        }

        return true;
    }

    bytes4 private constant connectors_func_selector = bytes4(keccak256());

    
    
    
    function getreserveweight(address _converter, address _reservetoken) private view returns (uint32) {
        uint256[2] memory ret;
        bytes memory data = abi.encodewithselector(connectors_func_selector, _reservetoken);

        assembly {
            let success := staticcall(
                gas,           
                _converter,    
                add(data, 32), 
                mload(data),   
                ret,           
                64             
            )
            if iszero(success) {
                revert(0, 0)
            }
        }

        return uint32(ret[1]);
    }

    
    function getsmarttokencount() public view returns (uint256) {
        return getanchorcount();
    }

    
    function getsmarttokens() public view returns (address[]) {
        return getanchors();
    }

    
    function getsmarttoken(uint256 _index) public view returns (address) {
        return getanchor(_index);
    }

    
    function issmarttoken(address _value) public view returns (bool) {
        return isanchor(_value);
    }

    
    function getconvertibletokensmarttokencount(address _convertibletoken) public view returns (uint256) {
        return getconvertibletokenanchorcount(_convertibletoken);
    }

    
    function getconvertibletokensmarttokens(address _convertibletoken) public view returns (address[]) {
        return getconvertibletokenanchors(_convertibletoken);
    }

    
    function getconvertibletokensmarttoken(address _convertibletoken, uint256 _index) public view returns (address) {
        return getconvertibletokenanchor(_convertibletoken, _index);
    }

    
    function isconvertibletokensmarttoken(address _convertibletoken, address _value) public view returns (bool) {
        return isconvertibletokenanchor(_convertibletoken, _value);
    }

    
    function getconvertersbysmarttokens(address[] _smarttokens) public view returns (address[]) {
        return getconvertersbyanchors(_smarttokens);
    }

    
    function getliquiditypoolbyreserveconfig(ierc20token[] memory _reservetokens, uint32[] memory _reserveweights) public view returns (iconverteranchor) {
        return getliquiditypoolbyconfig(1, _reservetokens, _reserveweights);
    }
}
