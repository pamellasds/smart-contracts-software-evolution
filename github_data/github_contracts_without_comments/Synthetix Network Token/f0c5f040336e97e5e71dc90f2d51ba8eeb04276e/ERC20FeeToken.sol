

pragma solidity ^0.4.19;


import ;
import ;


contract erc20feetoken is owned, safedecimalmath {

    

    
    
    uint public totalsupply;
    string public name;
    string public symbol;
    mapping(address => uint) public balanceof;
    mapping(address => mapping (address => uint256)) public allowance;

    
    
    uint public transferfeerate;
    
    uint constant maxtransferfeerate = unit / 10;

    
    uint public feepool = 0;

    
    address public feeauthority;


    

    function erc20feetoken(string _name, string _symbol,
                           uint initialsupply, address initialbeneficiary,
                           uint _feerate, address _feeauthority,
                           address _owner)
        owned(_owner)
        public
    {
        name = _name;
        symbol = _symbol;
        totalsupply = initialsupply;
        balanceof[initialbeneficiary] = initialsupply;
        transferfeerate = _feerate;
        feeauthority = _feeauthority;
    }


    

    function settransferfeerate(uint newfeerate)
        public
        onlyowner
    {
        require(newfeerate <= maxtransferfeerate);
        transferfeerate = newfeerate;
        transferfeerateupdate(newfeerate);
    }

    function setfeeauthority(address newfeeauthority)
        public
        onlyowner
    {
        feeauthority = newfeeauthority;
        feeauthorityupdate(newfeeauthority);
    }


    

    
    function transferfeeincurred(uint _value)
        public
        view
        returns (uint)
    {
        return safedecmul(_value, transferfeerate);
        
        
        
        
        
        
        
    }

    
    
    function transferplusfee(uint _value)
        public
        view
        returns (uint)
    {
        return safeadd(_value, transferfeeincurred(_value));
    }

    
    function pricetospend(uint value)
        public
        view
        returns (uint)
    {
        return safedecdiv(value, safeadd(unit, transferfeerate));
    }


    

    function transfer(address _to, uint _value)
        public
        returns (bool)
    {
        
        
        uint fee = transferfeeincurred(_value);
        uint totalcharge = safeadd(_value, fee);

        
        transfer(msg.sender, _to, _value);
        transferfeepaid(msg.sender, fee);

        
        if (_value == 0) {
            return true;
        }

        
        balanceof[msg.sender] = safesub(balanceof[msg.sender], totalcharge);
        balanceof[_to] = safeadd(balanceof[_to], _value);
        feepool = safeadd(feepool, fee);

        return true;
    }

    function transferfrom(address _from, address _to, uint _value)
        public
        returns (bool)
    {
        
        
        uint fee = transferfeeincurred(_value);
        uint totalcharge = safeadd(_value, fee);

        
        transfer(_from, _to, _value);
        transferfeepaid(msg.sender, fee);

        
        if (_value == 0) {
            return true;
        }

        
        balanceof[_from] = safesub(balanceof[_from], totalcharge);
        allowance[_from][msg.sender] = safesub(allowance[_from][msg.sender], totalcharge);
        balanceof[_to] = safeadd(balanceof[_to], _value);
        feepool = safeadd(feepool, fee);

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

    
    function withdrawfee(address account, uint value)
        public
        returns (bool)
    {
        require(msg.sender == feeauthority);
        
        feepool = safesub(feepool, value);
        balanceof[account] = safeadd(balanceof[account], value);
        feewithdrawal(account, value);
        return true;
    }

    
    function donatetofeepool(uint n)
        public
        returns (bool)
    {
        uint balance = balanceof[msg.sender];
        require(balance != 0);

        
        balanceof[msg.sender] = safesub(balance, n);
        feepool = safeadd(feepool, n);
        feedonation(msg.sender, msg.sender, n);
        return true;
    }


    

    event transfer(address indexed _from, address indexed _to, uint _value);

    event transferfeepaid(address indexed account, uint value);

    event approval(address indexed _owner, address indexed _spender, uint _value);

    event transferfeerateupdate(uint newfeerate);

    event feewithdrawal(address indexed account, uint value);

    event feedonation(address donor, address indexed donorindex, uint value);

    event feeauthorityupdate(address feeauthority);
}

