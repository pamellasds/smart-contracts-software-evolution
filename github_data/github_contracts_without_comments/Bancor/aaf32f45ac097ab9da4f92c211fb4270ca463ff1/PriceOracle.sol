pragma solidity 0.4.26;
import ;
import ;
import ;


contract priceoracle is ipriceoracle, utils {
    ierc20token public tokena;                  
    ierc20token public tokenb;                  
    ichainlinkpriceoracle public tokenaoracle;  
    ichainlinkpriceoracle public tokenboracle;  
    mapping (address => ichainlinkpriceoracle) public tokenstooracles;  

    
    constructor(ierc20token _tokena, ierc20token _tokenb, ichainlinkpriceoracle _tokenaoracle, ichainlinkpriceoracle _tokenboracle)
        public
        validaddress(_tokena)
        validaddress(_tokenb)
        validaddress(_tokenaoracle)
        validaddress(_tokenboracle)
    {
        
        _tokenaoracle.latestanswer();
        _tokenboracle.latestanswer();
        _tokenaoracle.latesttimestamp();
        _tokenboracle.latesttimestamp();

        tokena = _tokena;
        tokenb = _tokenb;
        tokenaoracle = _tokenaoracle;
        tokenboracle = _tokenboracle;
        tokenstooracles[_tokena] = _tokenaoracle;
        tokenstooracles[_tokenb] = _tokenboracle;
    }

    
    modifier supportedtoken(ierc20token _token) {
        _supportedtoken(_token);
        _;
    }

    
    function _supportedtoken(ierc20token _token) internal view {
        require(tokenstooracles[_token] != address(0), );
    }

    
    function latestrate(ierc20token _tokena, ierc20token _tokenb)
        public
        view
        supportedtoken(_tokena)
        supportedtoken(_tokenb)
        returns (uint256, uint256)
    {
        return (uint256(tokenstooracles[_tokena].latestanswer()), uint256(tokenstooracles[_tokenb].latestanswer()));
    }

    
    function lastupdatetime() public view returns (uint256) {
        
        uint256 timestampa = tokenaoracle.latesttimestamp();
        uint256 timestampb = tokenboracle.latesttimestamp();

        return  timestampa < timestampb ? timestampa : timestampb;
    }

    
    function latestrateandupdatetime(ierc20token _tokena, ierc20token _tokenb) public view returns (uint256, uint256, uint256) {
        (uint256 numerator, uint256 denominator) = latestrate(_tokena, _tokenb);

        return (numerator, denominator, lastupdatetime());
    }
}
