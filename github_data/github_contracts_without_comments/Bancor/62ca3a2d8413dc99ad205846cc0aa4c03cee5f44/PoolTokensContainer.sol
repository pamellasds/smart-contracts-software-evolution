pragma solidity 0.4.26;
import ;
import ;
import ;
import ;


contract pooltokenscontainer is ipooltokenscontainer, owned, tokenholder {
    uint8 internal constant max_pool_tokens = 5;    

    string public name;                 
    string public symbol;               
    uint8 public decimals;              
    ismarttoken[] private _pooltokens;  

    
    constructor(string _name, string _symbol, uint8 _decimals) public {
         
        require(bytes(_name).length > 0, );
        require(bytes(_symbol).length > 0, );

        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    
    function pooltokens() public view returns (ismarttoken[] memory) {
        return _pooltokens;
    }

    
    function createtoken() public owneronly returns (ismarttoken) {
        
        require(_pooltokens.length < max_pool_tokens, );

        string memory poolname = concatstrdigit(name, uint8(_pooltokens.length + 1));
        string memory poolsymbol = concatstrdigit(symbol, uint8(_pooltokens.length + 1));

        smarttoken token = new smarttoken(poolname, poolsymbol, decimals);
        _pooltokens.push(token);
        return token;
    }

    
    function mint(ismarttoken _token, address _to, uint256 _amount) public owneronly {
        _token.issue(_to, _amount);
    }

    
    function burn(ismarttoken _token, address _from, uint256 _amount) public owneronly {
        _token.destroy(_from, _amount);
    }

    
    function concatstrdigit(string _str, uint8 _digit) private pure returns (string) {
        return string(abi.encodepacked(_str, uint8(bytes1()) + _digit));
    }
}
