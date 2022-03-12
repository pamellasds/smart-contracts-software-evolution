pragma solidity ^0.4.18;

import ;


contract erc20 {

    function totalsupply() public constant returns (uint supply);
    
    function balanceof(address _owner) public constant returns (uint balance);
    
    function transfer(address _to, uint _value) public returns (bool success);
    
    function transferfrom(address _from, address _to, uint _value) public returns (bool success);
    
    function approve(address _spender, uint _value) public returns (bool success);
    
    function allowance(address _owner, address _spender) public constant returns (uint remaining);

    event transfer(address indexed _from, address indexed _to, uint _value);
    
    event approval(address indexed _owner, address indexed _spender, uint _value);
}


contract standardtoken is erc20 {

    using safemath for uint;

    uint public totalsupply;

    mapping (address => uint) balances;
    
    mapping (address => mapping (address => uint)) allowed;

    function totalsupply() public constant returns (uint) {
        return totalsupply;
    }

    function balanceof(address _owner) public constant returns (uint balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint _value) public returns (bool success) {
        require(balances[msg.sender] >= _value && _value > 0);
        
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        transfer(msg.sender, _to, _value);
        
        return true;
    }

    function transferfrom(address _from, address _to, uint _value) public returns (bool success) {
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0);
        
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        transfer(_from, _to, _value);
        
        return true;
    }

    function approve(address _spender, uint _value) public returns (bool success) {
        
        if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) {
            revert();
        }
        allowed[msg.sender][_spender] = _value;
        approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }

}

