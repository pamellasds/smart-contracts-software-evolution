

pragma solidity ^0.4.16;

contract safemath {
     function safemul(uint a, uint b) internal returns (uint) {
          uint c = a * b;
          assert(a == 0 || c / a == b);
          return c;
     }

     function safesub(uint a, uint b) internal returns (uint) {
          assert(b <= a);
          return a  b;
     }

     function safeadd(uint a, uint b) internal returns (uint) {
          uint c = a + b;
          assert(c>=a && c>=b);
          return c;
     }
}



contract token is safemath {
     
     
     function totalsupply() constant returns (uint256 supply);

     
     
     function balanceof(address _owner) constant returns (uint256 balance);

     
     
     
     function transfer(address _to, uint256 _value) returns(bool);

     
     
     
     
     
     function transferfrom(address _from, address _to, uint256 _value) returns(bool);

     
     
     
     
     function approve(address _spender, uint256 _value) returns (bool success);

     
     
     
     function allowance(address _owner, address _spender) constant returns (uint256 remaining);

     
     event transfer(address indexed _from, address indexed _to, uint256 _value);
     event approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract stdtoken is token {
     
     mapping(address => uint256) balances;
     mapping (address => mapping (address => uint256)) allowed;
     uint public supply = 0;

     
     function transfer(address _to, uint256 _value) returns(bool) {
          require(balances[msg.sender] >= _value);
          require(balances[_to] + _value > balances[_to]);

          balances[msg.sender] = safesub(balances[msg.sender],_value);
          balances[_to] = safeadd(balances[_to],_value);

          transfer(msg.sender, _to, _value);
          return true;
     }

     function transferfrom(address _from, address _to, uint256 _value) returns(bool){
          require(balances[_from] >= _value);
          require(allowed[_from][msg.sender] >= _value);
          require(balances[_to] + _value > balances[_to]);

          balances[_to] = safeadd(balances[_to],_value);
          balances[_from] = safesub(balances[_from],_value);
          allowed[_from][msg.sender] = safesub(allowed[_from][msg.sender],_value);

          transfer(_from, _to, _value);
          return true;
     }

     function totalsupply() constant returns (uint256) {
          return supply;
     }

     function balanceof(address _owner) constant returns (uint256) {
          return balances[_owner];
     }

     function approve(address _spender, uint256 _value) returns (bool) {
          
          
          
          
          require((_value == 0) || (allowed[msg.sender][_spender] == 0));

          allowed[msg.sender][_spender] = _value;
          approval(msg.sender, _spender, _value);

          return true;
     }

     function allowance(address _owner, address _spender) constant returns (uint256) {
          return allowed[_owner][_spender];
     }
}

contract ethlendtoken is stdtoken
{

    string public constant name = ;
    string public constant symbol = ;
    uint public constant decimals = 18;

    
    uint public constant total_supply = 1300000000 * (1 ether / 1 wei);
    uint public constant developers_bonus = 300000000 * (1 ether / 1 wei);

    uint public constant presale_price = 30000;  
    uint public constant presale_max_eth = 2000;
    
    uint public constant presale_token_supply_limit = presale_price * presale_max_eth * (1 ether / 1 wei);

    uint public constant ico_price1 = 27500;     
    uint public constant ico_price2 = 26250;     
    uint public constant ico_price3 = 25000;     

    
    uint public constant total_sold_token_supply_limit = 1000000000* (1 ether / 1 wei);

    enum state{
       init,
       paused,

       presalerunning,
       presalefinished,

       icorunning,
       icofinished
    }

    state public currentstate = state.init;
    bool public enabletransfers = false;

    address public teamtokenbonus = 0;

    
    address public escrow = 0;

    
    
    address public tokenmanager = 0;

    uint public presalesoldtokens = 0;
    uint public icosoldtokens = 0;
    uint public totalsoldtokens = 0;


    modifier onlytokenmanager()
    {
        require(msg.sender==tokenmanager); 
        _; 
    }

    modifier onlyinstate(state state)
    {
        require(state==currentstate); 
        _; 
    }


    event logbuy(address indexed owner, uint value);
    event logburn(address indexed owner, uint value);


    
    
    function ethlendtoken(address _tokenmanager, address _escrow, address _teamtokenbonus) 
    {
        tokenmanager = _tokenmanager;
        teamtokenbonus = _teamtokenbonus;
        escrow = _escrow;

        
        uint teambonus = developers_bonus;
        balances[_teamtokenbonus] += teambonus;
        supply+= teambonus;

        assert(presale_token_supply_limit==60000000 * (1 ether / 1 wei));
        assert(total_sold_token_supply_limit==1000000000 * (1 ether / 1 wei));
    }

    function buytokens() public payable
    {
        require(currentstate==state.presalerunning || currentstate==state.icorunning);

        if(currentstate==state.presalerunning){
            return buytokenspresale();
        }else{
            return buytokensico();
        }
    }

    function buytokenspresale() public payable onlyinstate(state.presalerunning)
    {
        
        require(msg.value >= (1 ether / 1 wei));
        uint newtokens = msg.value * presale_price;

        require(presalesoldtokens + newtokens <= presale_token_supply_limit);

        balances[msg.sender] += newtokens;
        supply+= newtokens;
        presalesoldtokens+= newtokens;
        totalsoldtokens+= newtokens;

        logbuy(msg.sender, newtokens);
    }

    function buytokensico() public payable onlyinstate(state.icorunning)
    {
        
        require(msg.value >= ((1 ether / 1 wei) / 100));
        uint newtokens = msg.value * getprice();

        require(totalsoldtokens + newtokens <= total_sold_token_supply_limit);

        balances[msg.sender] += newtokens;
        supply+= newtokens;
        icosoldtokens+= newtokens;
        totalsoldtokens+= newtokens;

        logbuy(msg.sender, newtokens);
    }

    function getprice()constant returns(uint)
    {
        if(currentstate==state.icorunning){
             if(icosoldtokens<(200000000 * (1 ether / 1 wei))){
                  return ico_price1;
             }
             
             if(icosoldtokens<(300000000 * (1 ether / 1 wei))){
                  return ico_price2;
             }

             return ico_price3;
        }else{
             return presale_price;
        }
    }

    function setstate(state _nextstate) public onlytokenmanager
    {
        
        require(currentstate != state.icofinished);
        
        currentstate = _nextstate;
        
        
        enabletransfers = (currentstate==state.icofinished);
    }

    function withdrawether() public onlytokenmanager
    {
        if(this.balance > 0) 
        {
            require(escrow.send(this.balance));
        }
    }


    function transfer(address _to, uint256 _value) returns(bool){
        require(enabletransfers);
        return super.transfer(_to,_value);
    }

    function transferfrom(address _from, address _to, uint256 _value) returns(bool){
        require(enabletransfers);
        return super.transferfrom(_from,_to,_value);
    }

    function approve(address _spender, uint256 _value) returns (bool) {
        require(enabletransfers);
        return super.approve(_spender,_value);
    }


    function settokenmanager(address _mgr) public onlytokenmanager
    {
        tokenmanager = _mgr;
    }

    
    function() payable 
    {
        buytokens();
    }
}