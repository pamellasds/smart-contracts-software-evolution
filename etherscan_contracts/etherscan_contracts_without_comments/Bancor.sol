

pragma solidity ^0.4.11;


contract safemath {
    
    function safemath() {
    }

    
    function safeadd(uint256 _x, uint256 _y) internal returns (uint256) {
        uint256 z = _x + _y;
        assert(z >= _x);
        return z;
    }

    
    function safesub(uint256 _x, uint256 _y) internal returns (uint256) {
        assert(_x >= _y);
        return _x  _y;
    }

    
    function safemul(uint256 _x, uint256 _y) internal returns (uint256) {
        uint256 z = _x * _y;
        assert(_x == 0 || z / _x == _y);
        return z;
    }
} 


contract iowned {
    
    function owner() public constant returns (address owner) { owner; }

    function transferownership(address _newowner) public;
    function acceptownership() public;
}


contract owned is iowned {
    address public owner;
    address public newowner;

    event ownerupdate(address _prevowner, address _newowner);

    
    function owned() {
        owner = msg.sender;
    }

    
    modifier owneronly {
        assert(msg.sender == owner);
        _;
    }

    
    function transferownership(address _newowner) public owneronly {
        require(_newowner != owner);
        newowner = _newowner;
    }

    
    function acceptownership() public {
        require(msg.sender == newowner);
        ownerupdate(owner, newowner);
        owner = newowner;
        newowner = 0x0;
    }
}


contract itokenholder is iowned {
    function withdrawtokens(ierc20token _token, address _to, uint256 _amount) public;
}


contract tokenholder is itokenholder, owned {
    
    function tokenholder() {
    }

    
    modifier validaddress(address _address) {
        require(_address != 0x0);
        _;
    }

    
    modifier notthis(address _address) {
        require(_address != address(this));
        _;
    }

    
    function withdrawtokens(ierc20token _token, address _to, uint256 _amount)
        public
        owneronly
        validaddress(_token)
        validaddress(_to)
        notthis(_to)
    {
        assert(_token.transfer(_to, _amount));
    }
}


contract ierc20token {
    
    function name() public constant returns (string name) { name; }
    function symbol() public constant returns (string symbol) { symbol; }
    function decimals() public constant returns (uint8 decimals) { decimals; }
    function totalsupply() public constant returns (uint256 totalsupply) { totalsupply; }
    function balanceof(address _owner) public constant returns (uint256 balance) { _owner; balance; }
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) { _owner; _spender; remaining; }

    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferfrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
}


contract erc20token is ierc20token, safemath {
    string public standard = ;
    string public name = ;
    string public symbol = ;
    uint8 public decimals = 0;
    uint256 public totalsupply = 0;
    mapping (address => uint256) public balanceof;
    mapping (address => mapping (address => uint256)) public allowance;

    event transfer(address indexed _from, address indexed _to, uint256 _value);
    event approval(address indexed _owner, address indexed _spender, uint256 _value);

    
    function erc20token(string _name, string _symbol, uint8 _decimals) {
        require(bytes(_name).length > 0 && bytes(_symbol).length > 0); 

        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    
    modifier validaddress(address _address) {
        require(_address != 0x0);
        _;
    }

    
    function transfer(address _to, uint256 _value)
        public
        validaddress(_to)
        returns (bool success)
    {
        balanceof[msg.sender] = safesub(balanceof[msg.sender], _value);
        balanceof[_to] = safeadd(balanceof[_to], _value);
        transfer(msg.sender, _to, _value);
        return true;
    }

    
    function transferfrom(address _from, address _to, uint256 _value)
        public
        validaddress(_from)
        validaddress(_to)
        returns (bool success)
    {
        allowance[_from][msg.sender] = safesub(allowance[_from][msg.sender], _value);
        balanceof[_from] = safesub(balanceof[_from], _value);
        balanceof[_to] = safeadd(balanceof[_to], _value);
        transfer(_from, _to, _value);
        return true;
    }

    
    function approve(address _spender, uint256 _value)
        public
        validaddress(_spender)
        returns (bool success)
    {
        
        require(_value == 0 || allowance[msg.sender][_spender] == 0);

        allowance[msg.sender][_spender] = _value;
        approval(msg.sender, _spender, _value);
        return true;
    }
}


contract ismarttoken is itokenholder, ierc20token {
    function disabletransfers(bool _disable) public;
    function issue(address _to, uint256 _amount) public;
    function destroy(address _from, uint256 _amount) public;
}


contract smarttoken is ismarttoken, erc20token, owned, tokenholder {
    string public version = ;

    bool public transfersenabled = true;    

    
    event newsmarttoken(address _token);
    
    event issuance(uint256 _amount);
    
    event destruction(uint256 _amount);

    
    function smarttoken(string _name, string _symbol, uint8 _decimals)
        erc20token(_name, _symbol, _decimals)
    {
        require(bytes(_symbol).length <= 6); 
        newsmarttoken(address(this));
    }

    
    modifier transfersallowed {
        assert(transfersenabled);
        _;
    }

    
    function disabletransfers(bool _disable) public owneronly {
        transfersenabled = !_disable;
    }

    
    function issue(address _to, uint256 _amount)
        public
        owneronly
        validaddress(_to)
        notthis(_to)
    {
        totalsupply = safeadd(totalsupply, _amount);
        balanceof[_to] = safeadd(balanceof[_to], _amount);

        issuance(_amount);
        transfer(this, _to, _amount);
    }

    
    function destroy(address _from, uint256 _amount)
        public
        owneronly
    {
        balanceof[_from] = safesub(balanceof[_from], _amount);
        totalsupply = safesub(totalsupply, _amount);

        transfer(_from, this, _amount);
        destruction(_amount);
    }

    

    
    function transfer(address _to, uint256 _value) public transfersallowed returns (bool success) {
        assert(super.transfer(_to, _value));

        
        if (_to == address(this)) {
            balanceof[_to] = _value;
            totalsupply = _value;
            destruction(_value);
        }

        return true;
    }

    
    function transferfrom(address _from, address _to, uint256 _value) public transfersallowed returns (bool success) {
        assert(super.transferfrom(_from, _to, _value));

        
        if (_to == address(this)) {
            balanceof[_to] = _value;
            totalsupply = _value;
            destruction(_value);
        }

        return true;
    }
}