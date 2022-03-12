pragma solidity ^0.4.18;

import ;
import ;





contract seelecrowdsale is pausable {
    using safemath for uint;

    
    
    uint public constant seele_total_supply = 1000000000 ether;
    uint public constant max_sale_duration = 4 days;
    uint public constant stage_1 = 6 hours;
    uint public constant stage_2 = 12 hours;
    uint public constant min_limit = 0.1 ether;
    uint public constant max_stage_1_limit = 1 ether;
    uint public constant max_stage_2_limit = 2 ether;

    
    uint public  exchangerate = 12500;


    uint public constant miner_stake = 3000;    
    uint public constant open_sale_stake = 625; 
    uint public constant other_stake = 6375;    

    
    uint public constant divisor_stake = 10000;

    
    uint public constant max_open_sold = seele_total_supply * open_sale_stake / divisor_stake;
    uint public constant stake_multiplier = seele_total_supply / divisor_stake;

    
    address public wallet;
    address public mineraddress;
    address public otheraddress;

    
    uint public starttime;
    
    uint public endtime;

    
    
    uint public opensoldtokens;
    
    seeletoken public seeletoken; 

    
    mapping (address => uint) public fullwhitelist;

    mapping (address => uint) public firststagefund;
    mapping (address => uint) public secondstagefund;

    
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

    function seelecrowdsale (
        address _wallet, 
        address _mineraddress,
        address _otheraddress
        ) public 
        validaddress(_wallet) 
        validaddress(_mineraddress) 
        validaddress(_otheraddress) 
        {
        paused = true;  
        wallet = _wallet;
        mineraddress = _mineraddress;
        otheraddress = _otheraddress;     

        opensoldtokens = 0;
        
        seeletoken = new seeletoken(this, msg.sender, seele_total_supply);

        seeletoken.mint(mineraddress, miner_stake * stake_multiplier, false);
        seeletoken.mint(otheraddress, other_stake * stake_multiplier, false);
    }

    function setexchangerate(uint256 rate)
        public
        onlyowner
        earlierthan(endtime)
    {
        exchangerate = rate;
    }

    function setstarttime(uint _starttime )
        public
        onlyowner
    {
        starttime = _starttime;
        endtime = starttime + max_sale_duration;
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
        
        require(!iscontract(msg.sender));    
        require(tx.gasprice <= 100000000000 wei);
        require(msg.value >= min_limit);

        uint inwhitelisttag = fullwhitelist[receipient];
        require(inwhitelisttag>0);
        
        if ( starttime <= now && now < starttime + stage_1 ) {
            require(msg.value <= max_stage_1_limit);
        }else if ( starttime + stage_1 <= now && now < starttime + stage_2 ) {
            require(msg.value <= max_stage_2_limit);
        }else {
            
        }

        dobuy(receipient);

        return true;
    }


    
    function dobuy(address receipient) internal {
        
        
        if ( starttime <= now && now < starttime + stage_1) {
            uint fund = firststagefund[receipient];
            fund.add(msg.value);
            if (fund > 1 ether) {
                uint refund = fund.sub(max_stage_1_limit);
                msg.value.sub(refund);
                msg.sender.transfer(refund);
            }
        }else if ( starttime + stage_1 <= now && now < starttime + stage_2 ) {
            uint fund = secondstagefund[receipient];
            fund.add(msg.value);
            if (fund > 2 ether) {
                uint refund = fund.sub(2 ether);
                msg.value.sub(refund);
                msg.sender.transfer(refund);
            }            
        }

        uint tokenavailable = max_open_sold.sub(opensoldtokens);
        require(tokenavailable > 0);
        uint tofund;
        uint tocollect;
        (tofund, tocollect) = costandbuytokens(tokenavailable);
        if (tofund > 0) {
            require(seeletoken.mint(receipient, tocollect,true));         
            wallet.transfer(tofund);
            opensoldtokens = opensoldtokens.add(tocollect);
            newsale(receipient, tofund, tocollect);             
        }

        
        uint toreturn = msg.value.sub(tofund);
        if (toreturn > 0) {
            msg.sender.transfer(toreturn);
        }

        if ( starttime <= now && now < starttime + stage_1 ) {
            firststagefund[receipient].add(msg.value);
        }else if ( starttime + stage_1 <= now && now < starttime + stage_2 ) {
            secondstagefund[receipient].add(msg.value);          
        }
    }

    
    function costandbuytokens(uint availabletoken) constant internal returns (uint costvalue, uint gettokens) {
        
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
}