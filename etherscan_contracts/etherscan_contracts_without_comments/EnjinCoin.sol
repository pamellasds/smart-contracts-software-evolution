

pragma solidity ^0.4.15;

contract utils {
    
    function utils() {
    }

    
    modifier validaddress(address _address) {
        require(_address != 0x0);
        _;
    }

    
    modifier notthis(address _address) {
        require(_address != address(this));
        _;
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


contract ierc20token {
    
    function name() public constant returns (string) { name; }
    function symbol() public constant returns (string) { symbol; }
    function decimals() public constant returns (uint8) { decimals; }
    function totalsupply() public constant returns (uint256) { totalsupply; }
    function balanceof(address _owner) public constant returns (uint256 balance) { _owner; balance; }
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) { _owner; _spender; remaining; }

    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferfrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
}



contract erc20token is ierc20token, utils {
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


contract iowned {
    
    function owner() public constant returns (address) { owner; }

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


contract tokenholder is itokenholder, owned, utils {
    
    function tokenholder() {
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


contract enjtoken is erc20token, tokenholder {



    uint256 constant public enj_unit = 10 ** 18;
    uint256 public totalsupply = 1 * (10**9) * enj_unit;

    
    uint256 constant public maxpresalesupply = 600 * 10**6 * enj_unit;           
    uint256 constant public mincrowdsaleallocation = 200 * 10**6 * enj_unit;     
    uint256 constant public incentivisationallocation = 100 * 10**6 * enj_unit;  
    uint256 constant public advisorsallocation = 26 * 10**6 * enj_unit;          
    uint256 constant public enjinteamallocation = 74 * 10**6 * enj_unit;         

    address public crowdfundaddress;                                             
    address public advisoraddress;                                               
    address public incentivisationfundaddress;                                   
    address public enjinteamaddress;                                             

    

    uint256 public totalallocatedtoadvisors = 0;                                 
    uint256 public totalallocatedtoteam = 0;                                     
    uint256 public totalallocated = 0;                                           
    uint256 constant public endtime = 1509494340;                                

    bool internal isreleasedtopublic = false;                         

    uint256 internal teamtranchesreleased = 0;                          
    uint256 internal maxteamtranches = 8;                               



    
    modifier safetimelock() {
        require(now >= endtime + 6 * 4 weeks);
        _;
    }

    
    modifier advisortimelock() {
        require(now >= endtime + 2 * 4 weeks);
        _;
    }

    
    modifier crowdfundonly() {
        require(msg.sender == crowdfundaddress);
        _;
    }

    

    
    function enjtoken(address _crowdfundaddress, address _advisoraddress, address _incentivisationfundaddress, address _enjinteamaddress)
    erc20token(, , 18)
     {
        crowdfundaddress = _crowdfundaddress;
        advisoraddress = _advisoraddress;
        enjinteamaddress = _enjinteamaddress;
        incentivisationfundaddress = _incentivisationfundaddress;
        balanceof[_crowdfundaddress] = mincrowdsaleallocation + maxpresalesupply; 
        balanceof[_incentivisationfundaddress] = incentivisationallocation;       
        totalallocated += incentivisationallocation;                              
    }



    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (istransferallowed() == true || msg.sender == crowdfundaddress || msg.sender == incentivisationfundaddress) {
            assert(super.transfer(_to, _value));
            return true;
        }
        revert();        
    }

    
    function transferfrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (istransferallowed() == true || msg.sender == crowdfundaddress || msg.sender == incentivisationfundaddress) {        
            assert(super.transferfrom(_from, _to, _value));
            return true;
        }
        revert();
    }



    
    function releaseenjinteamtokens() safetimelock owneronly returns(bool success) {
        require(totalallocatedtoteam < enjinteamallocation);

        uint256 enjinteamalloc = enjinteamallocation / 1000;
        uint256 currenttranche = uint256(now  endtime) / 12 weeks;     

        if(teamtranchesreleased < maxteamtranches && currenttranche > teamtranchesreleased) {
            teamtranchesreleased++;

            uint256 amount = safemul(enjinteamalloc, 125);
            balanceof[enjinteamaddress] = safeadd(balanceof[enjinteamaddress], amount);
            transfer(0x0, enjinteamaddress, amount);
            totalallocated = safeadd(totalallocated, amount);
            totalallocatedtoteam = safeadd(totalallocatedtoteam, amount);
            return true;
        }
        revert();
    }

    
    function releaseadvisortokens() advisortimelock owneronly returns(bool success) {
        require(totalallocatedtoadvisors == 0);
        balanceof[advisoraddress] = safeadd(balanceof[advisoraddress], advisorsallocation);
        totalallocated = safeadd(totalallocated, advisorsallocation);
        totalallocatedtoadvisors = advisorsallocation;
        transfer(0x0, advisoraddress, advisorsallocation);
        return true;
    }

    
    function retrieveunsoldtokens() safetimelock owneronly returns(bool success) {
        uint256 amountoftokens = balanceof[crowdfundaddress];
        balanceof[crowdfundaddress] = 0;
        balanceof[incentivisationfundaddress] = safeadd(balanceof[incentivisationfundaddress], amountoftokens);
        totalallocated = safeadd(totalallocated, amountoftokens);
        transfer(crowdfundaddress, incentivisationfundaddress, amountoftokens);
        return true;
    }

    
    function addtoallocation(uint256 _amount) crowdfundonly {
        totalallocated = safeadd(totalallocated, _amount);
    }

    
    function allowtransfers() owneronly {
        isreleasedtopublic = true;
    } 

    
    function istransferallowed() internal constant returns(bool) {
        if (now > endtime || isreleasedtopublic == true) {
            return true;
        }
        return false;
    }
}