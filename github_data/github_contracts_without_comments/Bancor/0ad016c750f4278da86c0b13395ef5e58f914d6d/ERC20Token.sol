pragma solidity ^0.4.10;




contract erc20token {
    string public standard = ;
    string public name = ;
    string public symbol = ;
    uint256 public totalsupply = 0;
    mapping (address => uint256) public balanceof;
    mapping (address => mapping (address => uint256)) public allowance;

    event transfer(address indexed _from, address indexed _to, uint256 _value);
    event approval(address indexed _owner, address indexed _spender, uint256 _value);

    function erc20token(string _name, string _symbol) {
        name = _name;
        symbol = _symbol;
    }

    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceof[msg.sender]); 
        assert(balanceof[_to] + _value >= balanceof[_to]); 

        balanceof[msg.sender] = _value;
        balanceof[_to] += _value;
        transfer(msg.sender, _to, _value);
        return true;
    }

    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        
        require(_value == 0 || allowance[msg.sender][_spender] == 0);

        allowance[msg.sender][_spender] = _value;
        approval(msg.sender, _spender, _value);
        return true;
    }

    
    function transferfrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceof[_from]); 
        require(_value <= allowance[_from][msg.sender]); 
        assert(balanceof[_to] + _value >= balanceof[_to]); 

        balanceof[_from] = _value;
        balanceof[_to] += _value;
        allowance[_from][msg.sender] = _value;
        transfer(_from, _to, _value);
        return true;
    }
}
