

pragma solidity 0.4.19;

contract token {

    
    function totalsupply() constant returns (uint supply) {}

    
    
    function balanceof(address _owner) constant returns (uint balance) {}

    
    
    
    
    function transfer(address _to, uint _value) returns (bool success) {}

    
    
    
    
    
    function transferfrom(address _from, address _to, uint _value) returns (bool success) {}

    
    
    
    
    function approve(address _spender, uint _value) returns (bool success) {}

    
    
    
    function allowance(address _owner, address _spender) constant returns (uint remaining) {}

    event transfer(address indexed _from, address indexed _to, uint _value);
    event approval(address indexed _owner, address indexed _spender, uint _value);
}

contract regulartoken is token {

    function transfer(address _to, uint _value) returns (bool) {
        
        if (balances[msg.sender] >= _value && balances[_to] + _value >= balances[_to]) {
            balances[msg.sender] = _value;
            balances[_to] += _value;
            transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferfrom(address _from, address _to, uint _value) returns (bool) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value >= balances[_to]) {
            balances[_to] += _value;
            balances[_from] = _value;
            allowed[_from][msg.sender] = _value;
            transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceof(address _owner) constant returns (uint) {
        return balances[_owner];
    }

    function approve(address _spender, uint _value) returns (bool) {
        allowed[msg.sender][_spender] = _value;
        approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint) {
        return allowed[_owner][_spender];
    }

    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;
    uint public totalsupply;
}

contract unboundedregulartoken is regulartoken {

    uint constant max_uint = 2**256  1;
    
    
    
    
    
    
    function transferfrom(address _from, address _to, uint _value)
        public
        returns (bool)
    {
        uint allowance = allowed[_from][msg.sender];
        if (balances[_from] >= _value
            && allowance >= _value
            && balances[_to] + _value >= balances[_to]
        ) {
            balances[_to] += _value;
            balances[_from] = _value;
            if (allowance < max_uint) {
                allowed[_from][msg.sender] = _value;
            }
            transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }
}

contract hbtoken is unboundedregulartoken {

    uint public totalsupply = 5*10**26;
    uint8 constant public decimals = 18;
    string constant public name = ;
    string constant public symbol = ;

    function hbtoken() {
        balances[msg.sender] = totalsupply;
        transfer(address(0), msg.sender, totalsupply);
    }
}