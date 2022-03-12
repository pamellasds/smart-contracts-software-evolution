
pragma solidity 0.6.12;
import ;
import ;


contract nonstandardtoken is utils {
    using safemath for uint256;

    uint256 public totalsupply;
    mapping (address => uint256) public balanceof;
    mapping (address => mapping (address => uint256)) public allowance;

    event transfer(address indexed _from, address indexed _to, uint256 _value);
    event approval(address indexed _owner, address indexed _spender, uint256 _value);

    
    constructor(uint256 _supply)
        internal
    {
        totalsupply = _supply;
        balanceof[msg.sender] = _supply;
    }

    
    function _transfer(address _to, uint256 _value)
        internal
        validaddress(_to)
    {
        balanceof[msg.sender] = balanceof[msg.sender].sub(_value);
        balanceof[_to] = balanceof[_to].add(_value);
        emit transfer(msg.sender, _to, _value);
    }

    
    function _transferfrom(address _from, address _to, uint256 _value)
        internal
        validaddress(_from)
        validaddress(_to)
    {
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        balanceof[_from] = balanceof[_from].sub(_value);
        balanceof[_to] = balanceof[_to].add(_value);
        emit transfer(_from, _to, _value);
    }

    
    function _approve(address _spender, uint256 _value)
        internal
        validaddress(_spender)
    {
        
        require(_value == 0 || allowance[msg.sender][_spender] == 0);

        allowance[msg.sender][_spender] = _value;
        emit approval(msg.sender, _spender, _value);
    }
}

contract nonstandardtokendetailed is nonstandardtoken {
    string public name;
    string public symbol;
    uint8 public decimals;

    
    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _supply)
        internal
        nonstandardtoken(_supply)
    {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }
}

contract testnonstandardtoken is nonstandardtokendetailed {
    bool public ok;

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _supply) public
        nonstandardtokendetailed(_name, _symbol, _decimals, _supply) {
        set(true);
    }

    function set(bool _ok) public {
        ok = _ok;
    }

    function approve(address _spender, uint256 _value) public {
        _approve(_spender, _value);
        require(ok);
    }

    function transfer(address _to, uint256 _value) public {
        _transfer(_to, _value);
        require(ok);
    }

    function transferfrom(address _from, address _to, uint256 _value) public {
        _transferfrom(_from, _to, _value);
        require(ok);
    }
}

contract testnonstandardtokenwithoutdecimals is nonstandardtoken {
    string public name;
    string public symbol;

    constructor(string memory _name, string memory _symbol, uint256 _supply) public
        nonstandardtoken(_supply) {
        name = _name;
        symbol = _symbol;
    }

    function approve(address _spender, uint256 _value) public {
        _approve(_spender, _value);
    }

    function transfer(address _to, uint256 _value) public {
        _transfer(_to, _value);
    }

    function transferfrom(address _from, address _to, uint256 _value) public {
        _transferfrom(_from, _to, _value);
    }
}

contract teststandardtoken is nonstandardtokendetailed {
    bool public ok;
    bool public ret;

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _supply) public
        nonstandardtokendetailed(_name, _symbol, _decimals, _supply) {
        set(true, true);
    }

    function set(bool _ok, bool _ret) public {
        ok = _ok;
        ret = _ret;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        _approve(_spender, _value);
        require(ok);
        return ret;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        _transfer(_to, _value);
        require(ok);
        return ret;
    }

    function transferfrom(address _from, address _to, uint256 _value) public returns (bool) {
        _transferfrom(_from, _to, _value);
        require(ok);
        return ret;
    }
}
