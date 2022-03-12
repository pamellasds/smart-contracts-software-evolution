pragma solidity ^0.4.24;
import ;
import ;


contract bancorconverterregistry is owned, utils {
    mapping (address => bool) private tokensregistered;         
    mapping (address => address[]) private tokenstoconverters;  
    mapping (address => address) private converterstotokens;    
    address[] public tokens;                                    

    
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
        if (_index >= tokenstoconverters[_token].length)
            return address(0);

        return tokenstoconverters[_token][_index];
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

        
        if (!tokensregistered[_token]) {
            tokens.push(_token);
            tokensregistered[_token] = true;
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
        
        
        delete converterstotokens[converter];

        
        emit converterremoval(_token, converter);
    }
}
