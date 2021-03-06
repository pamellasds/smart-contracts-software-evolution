

pragma solidity ^0.4.18;



library safemath {
  function mul(uint a, uint b) internal pure returns (uint) {
    if (a == 0) {
      return 0;
    }
    uint c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint a, uint b) internal pure returns (uint) {
    
    uint c = a / b;
    
    return c;
  }

  function sub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a  b;
  }

  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }
}

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

contract controlled {

    address public controller;

    function controlled() public {
        controller = msg.sender;
    }

    function changecontroller(address _newcontroller) public only_controller {
        controller = _newcontroller;
    }
    
    function getcontroller() constant public returns (address) {
        return controller;
    }

    modifier only_controller { 
        require(msg.sender == controller);
        _; 
    }

}


contract thetatoken is standardtoken, controlled {
    
    using safemath for uint;

    string public constant name = ;

    string public constant symbol = ;

    uint8 public constant decimals = 18;

    
    uint unlocktime;
    
    
    mapping (address => bool) internal precirculated;

    function thetatoken(uint _unlocktime) public {
        unlocktime = _unlocktime;
    }

    function transfer(address _to, uint _amount) can_transfer(msg.sender, _to) public returns (bool success) {
        return super.transfer(_to, _amount);
    }

    function transferfrom(address _from, address _to, uint _amount) can_transfer(_from, _to) public returns (bool success) {
        return super.transferfrom(_from, _to, _amount);
    }

    function mint(address _owner, uint _amount) external only_controller returns (bool) {
        totalsupply = totalsupply.add(_amount);
        balances[_owner] = balances[_owner].add(_amount);

        transfer(0, _owner, _amount);
        return true;
    }

    function allowprecirculation(address _addr) only_controller public {
        precirculated[_addr] = true;
    }

    function disallowprecirculation(address _addr) only_controller public {
        precirculated[_addr] = false;
    }

    function isprecirculationallowed(address _addr) constant public returns(bool) {
        return precirculated[_addr];
    }
    
    function changeunlocktime(uint _unlocktime) only_controller public {
        unlocktime = _unlocktime;
    }

    function getunlocktime() constant public returns (uint) {
        return unlocktime;
    }

    modifier can_transfer(address _from, address _to) {
        require((block.number >= unlocktime) || (isprecirculationallowed(_from) && isprecirculationallowed(_to)));
        _;
    }

}