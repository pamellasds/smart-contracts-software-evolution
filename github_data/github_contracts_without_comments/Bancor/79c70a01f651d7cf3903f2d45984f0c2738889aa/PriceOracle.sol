
pragma solidity 0.6.12;
import ;
import ;
import ;
import ;


contract priceoracle is ipriceoracle, utils {
    using safemath for uint256;

    ierc20token private constant eth_address = ierc20token(0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
    uint8 private constant eth_decimals = 18;

    ierc20token public tokena;  
    ierc20token public tokenb;  
    mapping (ierc20token => uint8) public tokendecimals;    

    ichainlinkpriceoracle public override tokenaoracle;  
    ichainlinkpriceoracle public override tokenboracle;  
    mapping (ierc20token => ichainlinkpriceoracle) public tokenstooracles;  

    
    constructor(ierc20token _tokena, ierc20token _tokenb, ichainlinkpriceoracle _tokenaoracle, ichainlinkpriceoracle _tokenboracle)
        public
        validuniqueaddresses(address(_tokena), address(_tokenb))
        validuniqueaddresses(address(_tokenaoracle), address(_tokenboracle))
    {
        tokena = _tokena;
        tokenb = _tokenb;
        tokendecimals[_tokena] = decimals(_tokena);
        tokendecimals[_tokenb] = decimals(_tokenb);

        tokenaoracle = _tokenaoracle;
        tokenboracle = _tokenboracle;
        tokenstooracles[_tokena] = _tokenaoracle;
        tokenstooracles[_tokenb] = _tokenboracle;
    }

    
    modifier validuniqueaddresses(address _address1, address _address2) {
        _validuniqueaddresses(_address1, _address2);
        _;
    }

    
    function _validuniqueaddresses(address _address1, address _address2) internal pure {
        _validaddress(_address1);
        _validaddress(_address2);
        require(_address1 != _address2, );
    }

    
    modifier supportedtokens(ierc20token _tokena, ierc20token _tokenb) {
        _supportedtokens(_tokena, _tokenb);
        _;
    }

    
    function _supportedtokens(ierc20token _tokena, ierc20token _tokenb) internal view {
        _validuniqueaddresses(address(_tokena), address(_tokenb));
        require(address(tokenstooracles[_tokena]) != address(0) && address(tokenstooracles[_tokenb]) != address(0), );
    }

    
    function latestrate(ierc20token _tokena, ierc20token _tokenb)
        public
        view
        override
        supportedtokens(_tokena, _tokenb)
        returns (uint256, uint256)
    {
        uint256 ratetokena = uint256(tokenstooracles[_tokena].latestanswer());
        uint256 ratetokenb = uint256(tokenstooracles[_tokenb].latestanswer());
        uint8 decimalstokena = tokendecimals[_tokena];
        uint8 decimalstokenb = tokendecimals[_tokenb];

        
        
        
        
        
        
        
        
        

        if (decimalstokena > decimalstokenb) {
            ratetokenb = ratetokenb.mul(uint256(10) ** (decimalstokena  decimalstokenb));
        }
        else if (decimalstokena < decimalstokenb) {
            ratetokena = ratetokena.mul(uint256(10) ** (decimalstokenb  decimalstokena));
        }

        return (ratetokena, ratetokenb);
    }

    
    function lastupdatetime()
        public
        view
        override
        returns (uint256) {
        
        uint256 timestampa = tokenaoracle.latesttimestamp();
        uint256 timestampb = tokenboracle.latesttimestamp();

        return  timestampa > timestampb ? timestampa : timestampb;
    }

    
    function latestrateandupdatetime(ierc20token _tokena, ierc20token _tokenb)
        public
        view
        override
        returns (uint256, uint256, uint256)
    {
        (uint256 numerator, uint256 denominator) = latestrate(_tokena, _tokenb);

        return (numerator, denominator, lastupdatetime());
    }

    
    function decimals(ierc20token _token) private view returns (uint8) {
        if (_token == eth_address) {
            return eth_decimals;
        }

        return _token.decimals();
    }
}
