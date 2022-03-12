
pragma solidity 0.6.12;
import ;
import ;
import ;


contract erc20token is ierc20token, utils {
    using safemath for uint256;


    string public override name;
    string public override symbol;
    uint8 public override decimals;
    uint256 public override totalsupply;
    mapping (address => uint256) public override balanceof;
    mapping (address => mapping (address => uint256)) public override allowance;

    
    event transfer(address indexed _from, address indexed _to, uint256 _value);

    
    event approval(address indexed _owner, address indexed _spender, uint256 _value);

    
    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalsupply) public {
        
        require(bytes(_name).length > 0, );
        require(bytes(_symbol).length > 0, );

        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalsupply = _totalsupply;
        balanceof[msg.sender] = _totalsupply;
    }

    
    function transfer(address _to, uint256 _value)
        public
        virtual
        override
        validaddress(_to)
        returns (bool)
    {
        balanceof[msg.sender] = balanceof[msg.sender].sub(_value);
        balanceof[_to] = balanceof[_to].add(_value);
        emit transfer(msg.sender, _to, _value);
        return true;
    }

    
    function transferfrom(address _from, address _to, uint256 _value)
        public
        virtual
        override
        validaddress(_from)
        validaddress(_to)
        returns (bool)
    {
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        balanceof[_from] = balanceof[_from].sub(_value);
        balanceof[_to] = balanceof[_to].add(_value);
        emit transfer(_from, _to, _value);
        return true;
    }

    
    function approve(address _spender, uint256 _value)
        public
        virtual
        override
        validaddress(_spender)
        returns (bool)
    {
        allowance[msg.sender][_spender] = _value;
        emit approval(msg.sender, _spender, _value);
        return true;
    }
}
