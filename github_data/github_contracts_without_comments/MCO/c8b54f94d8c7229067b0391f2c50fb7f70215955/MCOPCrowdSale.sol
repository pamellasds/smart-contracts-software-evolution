pragma solidity ^0.4.19;

import ;
import ;
import ;






contract mcopcrowdsale is pausable {
    using safemath for uint;

    
    
    uint public constant mcop_total_supply = 10000000000 ether;
    uint public constant max_sale_duration = 3 weeks;

    
    uint public constant lock_time =  5 years;

    
    uint public constant price_rate_first = 20833;
    
    uint public constant price_rate_second = 18518;
    
    uint public constant price_rate_last = 16667;


    uint256 public minbuylimit = 0.1 ether;
    uint256 public maxbuylimit = 100 ether;

    uint public constant lock_stake = 800;  
    uint public constant dev_team_stake = 98;     
    uint public constant community_stake = 2;     
    uint public constant pre_sale_stake = 60;      
    uint public constant open_sale_stake = 40;

    
    uint public constant divisor_stake = 1000;

    
    uint public constant max_open_sold = mcop_total_supply * open_sale_stake / divisor_stake;
    uint public constant stake_multiplier = mcop_total_supply / divisor_stake;

    
    address public wallet;
    address public presaleaddress;
    address public lockaddress;
    address public teamaddress;
    address public communityaddress;
    
    uint public starttime;
    
    uint public endtime;

    
    
    uint public opensoldtokens;
    
    mcoptoken public mcoptoken; 

    
    tokentimelock public tokentimelock; 

    
    mapping (address => uint) public fullwhitelist;

    
    event newsale(address indexed destaddress, uint ethcost, uint gottokens);
    event newwallet(address onwer, address oldwallet, address newwallet);
    
    

    modifier notearlierthan(uint x) {
        require(now >= x);
        _;
    }

    modifier earlierthan(uint x) {
        require(now < x);
        _;
    }

    modifier ceilingnotreached() {
        require(opensoldtokens < max_open_sold);
        _;
    }  

    modifier issaleended() {
        require(now > endtime || opensoldtokens >= max_open_sold);
        _;
    }

    modifier validaddress( address addr ) {
        require(addr != address(0x0));
        require(addr != address(this));
        _;
    }

    function mcopcrowdsale (address _admin, 
        address _wallet, 
        address _presaleaddress,
        address _lockaddress,
        address _teamaddress,
        address _communityaddress,
        uint _starttime 
        ) public 
        validaddress(_admin) 
        validaddress(_wallet) 
        validaddress(_presaleaddress) 
        validaddress(_lockaddress) 
        validaddress(_teamaddress) 
        validaddress(_communityaddress) 
        {

        wallet = _wallet;
        presaleaddress = _presaleaddress;
        lockaddress = _lockaddress;
        teamaddress = _teamaddress;
        communityaddress = _communityaddress;        
        starttime = _starttime;
        endtime = starttime + max_sale_duration;

        opensoldtokens = 0;
        
        mcoptoken = new mcoptoken(this, _admin, mcop_total_supply, starttime, endtime);

        tokentimelock = new tokentimelock(mcoptoken, lockaddress, now + lock_time);

        
        mcoptoken.mint(presaleaddress, pre_sale_stake * stake_multiplier);
        mcoptoken.mint(tokentimelock, lock_stake * stake_multiplier);
        mcoptoken.mint(teamaddress, dev_team_stake * stake_multiplier);
        mcoptoken.mint(communityaddress, community_stake * stake_multiplier);  

        transferownership(_admin);
    }

    function setmaxbuylimit(uint256 limit)
        public
        onlyowner
        earlierthan(endtime)
    {
        maxbuylimit = limit;
    }

    function setminbuylimit(uint256 limit)
        public
        onlyowner
        earlierthan(endtime)
    {
        minbuylimit = limit;
    }

    
    
    function setwhitelist(address[] users, uint opentag)
        public
        onlyowner
        earlierthan(endtime)
    {
        require(salenotend());
        
        for (uint i = 0; i < users.length; i++) {
            
            fullwhitelist[users[i]] = opentag;
        }
    }


    
    
    function addwhitelist(address user, uint opentag)
        public
        onlyowner
        earlierthan(endtime)
    {
        require(salenotend());
        
        fullwhitelist[user] = opentag;

    }

    
    function setwallet(address newaddress)  external onlyowner { 
        newwallet(owner, wallet, newaddress);
        wallet = newaddress; 
    }

    
    function salenotend() constant internal returns (bool) {
        return now < endtime && opensoldtokens < max_open_sold;
    }

    
    function () public payable {
      buympc(msg.sender);
    }

    
    
    
    function buympc(address receipient) 
        public 
        payable 
        whennotpaused  
        ceilingnotreached 
        earlierthan(endtime)
        validaddress(receipient)
        returns (bool) 
    {
        require(msg.value >= minbuylimit);
        require(msg.value <= maxbuylimit);
        
        require(!iscontract(msg.sender));        

        require(tx.gasprice <= 50000000000 wei);

        uint inwhitelisttag = fullwhitelist[receipient];
        
        require(inwhitelisttag>0);
        
        dobuy(receipient);

        return true;
    }


    
    function dobuy(address receipient) internal {
        
        uint tokenavailable = max_open_sold.sub(opensoldtokens);
        require(tokenavailable > 0);
        uint tofund;
        uint tocollect;
        (tofund, tocollect) = costandbuytokens(tokenavailable);
        if (tofund > 0) {
            require(mcoptoken.mint(receipient, tocollect));         
            wallet.transfer(tofund);
            opensoldtokens = opensoldtokens.add(tocollect);
            newsale(receipient, tofund, tocollect);             
        }

        
        uint toreturn = msg.value.sub(tofund);
        if (toreturn > 0) {
            msg.sender.transfer(toreturn);
        }
    }

    
    
    function pricerate() public view returns (uint) {
        if (starttime <= now && now < starttime + 1 weeks ) {
            return  price_rate_first;
        }else if (starttime + 1 weeks <= now && now < starttime + 2 weeks ) {
            return price_rate_second;
        }else if (starttime + 2 weeks <= now && now < endtime) {
            return price_rate_last;
        }else {
            assert(false);
        }
        return now;
    }

    
    function costandbuytokens(uint availabletoken) constant internal returns (uint costvalue, uint gettokens) {
        
        uint exchangerate = pricerate();
        gettokens = exchangerate * msg.value;

        if (availabletoken >= gettokens) {
            costvalue = msg.value;
        } else {
            costvalue = availabletoken / exchangerate;
            gettokens = availabletoken;
        }
    }

    
    
    
    function iscontract(address _addr) constant internal returns(bool) {
        uint size;
        if (_addr == 0) {
            return false;
        }

        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }

    
    function releaselocktoken()  external onlyowner {
        tokentimelock.release();
    }
}