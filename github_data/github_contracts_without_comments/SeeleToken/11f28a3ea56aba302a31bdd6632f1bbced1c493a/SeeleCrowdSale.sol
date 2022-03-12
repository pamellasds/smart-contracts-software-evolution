pragma solidity ^0.4.18;

import ;
import ;





contract seelecrowdsale is pausable {
    using safemath for uint;

    
    
    uint public constant seele_total_supply = 1000000000 ether;
    uint public constant max_sale_duration = 4 days;
    uint public constant stage_1_time =  6 hours;
    uint public constant stage_2_time = 12 hours;
    uint public constant min_limit = 0.1 ether;
    uint public constant max_stage_1_limit = 1 ether;
    uint public constant max_stage_2_limit = 2 ether;

    uint public constant stage_1 = 1;
    uint public constant stage_2 = 2;
    uint public constant stage_3 = 3;


    
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

    
    mapping (address => bool) public fullwhitelist;

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

    
    
    function setwhitelist(address[] users, bool opentag)
        external
        onlyowner
        earlierthan(endtime)
    {
        require(salenotend());
        for (uint i = 0; i < users.length; i++) {
            fullwhitelist[users[i]] = opentag;
        }
    }


    
    
    function addwhitelist(address user, bool opentag)
        external
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
        internal 
        whennotpaused  
        ceilingnotreached 
        notearlierthan(starttime)
        earlierthan(endtime)
        validaddress(receipient)
        returns (bool) 
    {
        
        require(!iscontract(msg.sender));    
        require(tx.gasprice <= 100000000000 wei);
        require(msg.value >= min_limit);

        bool inwhitelisttag = fullwhitelist[receipient];       
        require(inwhitelisttag == true);

        uint stage = stage_3;
        if ( starttime <= now && now < starttime + stage_1_time ) {
            stage = stage_1;
            require(msg.value <= max_stage_1_limit);
            uint fund1 = firststagefund[receipient];
            require (fund1 < max_stage_1_limit );
        }else if ( starttime + stage_1_time <= now && now < starttime + stage_2_time ) {
            stage = stage_2;
            require(msg.value <= max_stage_2_limit);
            uint fund2 = secondstagefund[receipient];
            require (fund2 < max_stage_2_limit );
        }

        dobuy(receipient, stage);

        return true;
    }


    
    function dobuy(address receipient, uint stage) internal {
        
        uint value = msg.value;

        if ( stage == stage_1 ) {
            uint fund1 = firststagefund[receipient];
            fund1 = fund1.add(value);
            if (fund1 > max_stage_1_limit ) {
                uint refund1 = fund1.sub(max_stage_1_limit);
                value = value.sub(refund1);
                msg.sender.transfer(refund1);
            }
        }else if ( stage == stage_2 ) {
            uint fund2 = secondstagefund[receipient];
            fund2 = fund2.add(value);
            if (fund2 > max_stage_2_limit) {
                uint refund2 = fund2.sub(max_stage_2_limit);
                value = value.sub(refund2);
                msg.sender.transfer(refund2);
            }            
        }

        uint tokenavailable = max_open_sold.sub(opensoldtokens);
        require(tokenavailable > 0);
        uint tofund;
        uint tocollect;
        (tofund, tocollect) = costandbuytokens(tokenavailable, value);
        if (tofund > 0) {
            require(seeletoken.mint(receipient, tocollect,true));         
            wallet.transfer(tofund);
            opensoldtokens = opensoldtokens.add(tocollect);
            newsale(receipient, tofund, tocollect);             
        }

        
        uint toreturn = value.sub(tofund);
        if (toreturn > 0) {
            msg.sender.transfer(toreturn);
        }

        if ( stage == stage_1 ) {
            firststagefund[receipient] = firststagefund[receipient].add(tofund);
        }else if ( stage == stage_2 ) {
            secondstagefund[receipient] = secondstagefund[receipient].add(tofund);          
        }
    }

    
    function costandbuytokens(uint availabletoken, uint value) constant internal returns (uint costvalue, uint gettokens) {
        
        gettokens = exchangerate * value;

        if (availabletoken >= gettokens) {
            costvalue = value;
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