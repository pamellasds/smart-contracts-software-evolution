pragma solidity ^0.4.18;

import ;
import ;
import ;





contract seelecrowdsale is pausable {
    using safemath for uint;

    
    
    uint public constant seele_total_supply = 1000000000 ether;
    uint public constant max_sale_duration = 1 weeks;

    
    uint public constant lock_time =  1 years;

    
    uint public constant exchange_rate = 1000;

    
    
    
    
    


    uint256 public minbuylimit = 0.1 ether;
    uint256 public maxbuylimit = 10 ether;

    uint public constant lock_stake = 300;  
    uint public constant dev_team_stake = 100;     
    uint public constant community_stake = 100;     
    uint public constant pre_sale_stake = 400;      
    uint public constant open_sale_stake = 100;
    
    uint public constant divisor_stake = 1000;

    
    uint public constant max_open_sold = seele_total_supply * open_sale_stake / divisor_stake;
    uint public constant stake_multiplier = seele_total_supply / divisor_stake;

    
    address public wallet;
    address public presaleaddress;
    address public lockaddress;
    address public teamaddress;
    address public communityaddress;
    
    uint public starttime;
    
    uint public endtime;

    
    
    uint public opensoldtokens;
    
    seeletoken public seeletoken; 

    
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

    function seelecrowdsale (address _admin, 
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
        
        seeletoken = new seeletoken(this, _admin, seele_total_supply, starttime, endtime);

        tokentimelock = new tokentimelock(seeletoken, lockaddress, now + lock_time);

        
        seeletoken.mint(presaleaddress, pre_sale_stake * stake_multiplier);
        seeletoken.mint(tokentimelock, lock_stake * stake_multiplier);
        seeletoken.mint(teamaddress, dev_team_stake * stake_multiplier);
        seeletoken.mint(communityaddress, community_stake * stake_multiplier);  

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
      buyseele(msg.sender);
    }

    
    
    
    function buyseele(address receipient) 
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

        require(tx.gasprice <= 60000000000 wei);

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
            require(seeletoken.mint(receipient, tocollect));         
            wallet.transfer(tofund);
            opensoldtokens = opensoldtokens.add(tocollect);
            newsale(receipient, tofund, tocollect);             
        }

        
        uint toreturn = msg.value.sub(tofund);
        if (toreturn > 0) {
            msg.sender.transfer(toreturn);
        }
    }

    
    
    
    
    
    
    
    
    
    
    
    
    

    
    

    
    function costandbuytokens(uint availabletoken) constant internal returns (uint costvalue, uint gettokens) {
        
        gettokens = exchange_rate * msg.value;

        if (availabletoken >= gettokens) {
            costvalue = msg.value;
        } else {
            costvalue = availabletoken / exchange_rate;
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