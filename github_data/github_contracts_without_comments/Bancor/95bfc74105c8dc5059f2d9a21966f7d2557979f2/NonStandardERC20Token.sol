pragma solidity ^0.4.24;
import ;
import ;
import ;


contract nonstandarderc20token is inonstandarderc20, utils {
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
    {
        balanceof[msg.sender] = balanceof[msg.sender].sub(_value);
        balanceof[_to] = balanceof[_to].add(_value);
        emit transfer(msg.sender, _to, _value);
    }

    
    function transferfrom(address _from, address _to, uint256 _value)
        public
        validaddress(_from)
        validaddress(_to)
    {
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        balanceof[_from] = balanceof[_from].sub(_value);
        balanceof[_to] = balanceof[_to].add(_value);
        emit transfer(_from, _to, _value);
    }

    
    function approve(address _spender, uint256 _value)
        public
        validaddress(_spender)
    {
        
        require(_value == 0 || allowance[msg.sender][_spender] == 0);

        allowance[msg.sender][_spender] = _value;
        emit approval(msg.sender, _spender, _value);
    }
}
