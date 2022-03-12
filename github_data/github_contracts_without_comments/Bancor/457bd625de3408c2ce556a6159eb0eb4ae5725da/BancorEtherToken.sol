pragma solidity ^0.4.8;



contract bancorethertoken {
    string public standard = ;
    string public name = ;
    string public symbol = ;
    uint256 public totalsupply = 0;
    mapping (address => uint256) public balanceof;
    mapping (address => mapping (address => uint256)) public allowance;

    event transfer(address indexed _from, address indexed _to, uint256 _value);
    event approval(address indexed _owner, address indexed _spender, uint256 _value);

    function bancorethertoken() {
    }

    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (balanceof[msg.sender] < _value) 
            throw;
        if (balanceof[_to] + _value < balanceof[_to]) 
            throw;

        balanceof[msg.sender] = _value;
        balanceof[_to] += _value;
        transfer(msg.sender, _to, _value);
        return true;
    }

    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        
        if (_value != 0 && allowance[msg.sender][_spender] != 0)
            throw;

        allowance[msg.sender][_spender] = _value;
        approval(msg.sender, _spender, _value);
        return true;
    }

    
    function transferfrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (balanceof[_from] < _value) 
            throw;
        if (balanceof[_to] + _value < balanceof[_to]) 
            throw;
        if (_value > allowance[_from][msg.sender]) 
            throw;

        balanceof[_from] = _value;
        balanceof[_to] += _value;
        allowance[_from][msg.sender] = _value;
        transfer(_from, _to, _value);
        return true;
    }

    
    function deposit() public payable returns (bool success) {
        if (balanceof[msg.sender] + msg.value < balanceof[msg.sender]) 
            throw;

        balanceof[msg.sender] += msg.value;
        return true;
    }

    
    function withdraw(uint256 _amount) public returns (bool success) {
        if (balanceof[msg.sender] < _amount) 
            throw;

        
        balanceof[msg.sender] = _amount;
        
        if (!msg.sender.send(_amount))
            throw;

        return true;
    }

    
    function() public payable {
        if (balanceof[msg.sender] + msg.value < balanceof[msg.sender]) 
            throw;

        balanceof[msg.sender] += msg.value;
    }
}
