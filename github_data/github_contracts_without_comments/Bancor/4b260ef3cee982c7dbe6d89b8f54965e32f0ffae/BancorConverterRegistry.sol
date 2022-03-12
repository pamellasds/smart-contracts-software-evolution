pragma solidity 0.4.26;
import ;
import ;
import ;


contract bancorconverterregistry is ibancorconverterregistry, owned, utils {
    mapping (address => address[]) private tokenstoconverters;  
    mapping (address => address) private converterstotokens;    
    address[] public tokens;                                    

    struct tokeninfo {
        bool valid;
        uint256 index;
    }

    mapping(address => tokeninfo) public tokentable;

    
    event tokenaddition(address indexed _token);

    
    event tokenremoval(address indexed _token);

    
    event converteraddition(address indexed _token, address _address);

    
    event converterremoval(address indexed _token, address _address);

    
    constructor() public {
    }

    
    function tokencount() public view returns (uint256) {
        return tokens.length;
    }

    
    function convertercount(address _token) public view returns (uint256) {
        return tokenstoconverters[_token].length;
    }

    
    function converteraddress(address _token, uint32 _index) public view returns (address) {
        if (tokenstoconverters[_token].length > _index)
            return tokenstoconverters[_token][_index];

        return address(0);
    }

    
    function latestconverteraddress(address _token) public view returns (address) {
        if (tokenstoconverters[_token].length > 0)
            return tokenstoconverters[_token][tokenstoconverters[_token].length  1];

        return address(0);
    }

    
    function tokenaddress(address _converter) public view returns (address) {
        return converterstotokens[_converter];
    }

    
    function registerconverter(address _token, address _converter)
        public
        owneronly
        validaddress(_token)
        validaddress(_converter)
    {
        require(converterstotokens[_converter] == address(0));

        
        tokeninfo storage tokeninfo = tokentable[_token];
        if (tokeninfo.valid == false) {
            tokeninfo.valid = true;
            tokeninfo.index = tokens.push(_token)  1;
            emit tokenaddition(_token);
        }

        tokenstoconverters[_token].push(_converter);
        converterstotokens[_converter] = _token;

        
        emit converteraddition(_token, _converter);
    }

    
    function unregisterconverter(address _token, uint32 _index)
        public
        owneronly
        validaddress(_token)
    {
        require(_index < tokenstoconverters[_token].length);

        address converter = tokenstoconverters[_token][_index];

        
        for (uint32 i = _index + 1; i < tokenstoconverters[_token].length; i++) {
            tokenstoconverters[_token][i  1] = tokenstoconverters[_token][i];
        }

        
        tokenstoconverters[_token].length;

        
        if (tokenstoconverters[_token].length == 0) {
            tokeninfo storage tokeninfo = tokentable[_token];
            assert(tokens.length > tokeninfo.index);
            assert(_token == tokens[tokeninfo.index]);
            address lasttoken = tokens[tokens.length  1];
            tokentable[lasttoken].index = tokeninfo.index;
            tokens[tokeninfo.index] = lasttoken;
            tokens.length;
            delete tokentable[_token];
            emit tokenremoval(_token);
        }

        
        delete converterstotokens[converter];

        
        emit converterremoval(_token, converter);
    }
}
