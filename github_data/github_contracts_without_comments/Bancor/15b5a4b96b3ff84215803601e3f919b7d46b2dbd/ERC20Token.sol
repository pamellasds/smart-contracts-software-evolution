pragma solidity 0.4.26;
import ;
import ;
import ;


contract erc20token is ierc20token, utils {
    using safemath for uint256;


    string public standard = ;
    string public name = ;
    string public symbol = ;
    uint8 public decimals = 0;
    uint256 public totalsupply = 0;
    mapping (address => uint256) public balanceof;
    mapping (address => mapping (address => uint256)) public allowance;

    
    event transfer(address indexed _from, address indexed _to, uint256 _value);

    
    event approval(address indexed _owner, address indexed _spender, uint256 _value);

    
    constructor(string _name, string _symbol, uint8 _decimals) public {
        require(bytes(_name).length > 0 && bytes(_symbol).length > 0); 

        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    
    function transfer(address _to, uint256 _value)
        public
        validaddress(_to)
        returns (bool success)
    {
        balanceof[msg.sender] = balanceof[msg.sender].sub(_value);
        balanceof[_to] = balanceof[_to].add(_value);
        emit transfer(msg.sender, _to, _value);
        return true;
    }

    
    function transferfrom(address _from, address _to, uint256 _value)
        public
        validaddress(_from)
        validaddress(_to)
        returns (bool success)
    {
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        balanceof[_from] = balanceof[_from].sub(_value);
        balanceof[_to] = balanceof[_to].add(_value);
        emit transfer(_from, _to, _value);
        return true;
    }

    
    function approve(address _spender, uint256 _value)
        public
        validaddress(_spender)
        returns (bool success)
    {
        
        require(_value == 0 || allowance[msg.sender][_spender] == 0);

        allowance[msg.sender][_spender] = _value;
        emit approval(msg.sender, _spender, _value);
        return true;
    }
}
