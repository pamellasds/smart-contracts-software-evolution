

pragma solidity ^0.4.19;


import ;


contract erc20token is safedecimalmath {

    

    
    
    uint public totalsupply;
    string public name;
    string public symbol;
    mapping(address => uint) public balanceof;
    mapping(address => mapping (address => uint256)) public allowance;


    

    function erc20token(string _name, string _symbol,
                        uint initialsupply, address initialbeneficiary)
        public
    {
        name = _name;
        symbol = _symbol;
        totalsupply = initialsupply;
        balanceof[initialbeneficiary] = initialsupply;
    }


    

    function transfer(address _to, uint _value)
        public
        returns (bool)
    {
        
        transfer(msg.sender, _to, _value);

        
        if (_value == 0) {
            return true;
        }

        
        balanceof[msg.sender] = safesub(balanceof[msg.sender], _value);
        balanceof[_to] = safeadd(balanceof[_to], _value);

        return true;
    }

    function transferfrom(address _from, address _to, uint _value)
        public
        returns (bool)
    {
        
        transfer(_from, _to, _value);

        
        if (_value == 0) {
            return true;
        }

        
        balanceof[_from] = safesub(balanceof[_from], _value);
        allowance[_from][msg.sender] = safesub(allowance[_from][msg.sender], _value);
        balanceof[_to] = safeadd(balanceof[_to], _value);

        return true;
    }

    function approve(address _spender, uint _value)
        public
        returns (bool)
    {
        allowance[msg.sender][_spender] = _value;
        approval(msg.sender, _spender, _value);
        return true;
    }


    

    event transfer(address indexed _from, address indexed _to, uint _value);

    event approval(address indexed _owner, address indexed _spender, uint _value);

}
