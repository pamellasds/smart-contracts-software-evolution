pragma solidity ^0.4.10;
import ;
import ;
import ;
import ;





contract ethertoken {
    function deposit() public payable returns (bool success);
    function transfer(address _to, uint256 _value) public returns (bool success);
}


contract crowdsalechanger is bancoreventsdispatcher, tokenchangerinterface, safemath {
    struct erc20tokendata {
        uint256 valuen;     
        uint256 valued;     
        uint16 limit;       
        bool isenabled;     
        bool isset;         
    }

    uint256 public constant duration = 30 days;                     
    uint256 public constant ether_cap = 1000000 ether;              
    uint256 public constant bitcoin_suisse_ether_cap = 20000 ether; 
    uint256 public constant initial_price_n = 1;                    
    uint256 public constant initial_price_d = 100;                  
    uint8 public constant reserve_ratio = 21;                       
    uint8 public constant beneficiary_percentage = 30;              

    
    uint256 public constant phase1_min_contribution = 0 ether;
    uint256 public constant phase2_min_contribution = 100000 ether;
    uint256 public constant phase3_min_contribution = 300000 ether;
    
    uint8 public constant phase1_reserve_allocation = 30;
    uint8 public constant phase2_reserve_allocation = 50;
    uint8 public constant phase3_reserve_allocation = 70;

    string public version = ;
    string public changertype = ;

    uint256 public starttime = 0;                           
    uint256 public endtime = 0;                             
    uint256 public ethercontributed = 0;                    
    uint256 public tokenreservebalance = 0;                 
    address public ethertoken = 0x0;                        
    address public beneficiary = 0x0;                       
    address public bitcoinsuisse = 0x0;                     
    smarttokeninterface public token;                       
    bool public isactive = false;                           
    address[] public acceptedtokens;                        
    mapping (address => erc20tokendata) public tokendata;   

    
    event change(address indexed _fromtoken, address indexed _totoken, address indexed _trader, uint256 _amount, uint256 _return);

    
    function crowdsalechanger(address _token, address _ethertoken, uint256 _starttime, address _beneficiary, address _bitcoinsuisse, address _events)
        bancoreventsdispatcher(_events)
        validaddress(_token)
        validaddress(_ethertoken)
        validaddress(_beneficiary)
        validaddress(_bitcoinsuisse)
        earlierthan(_starttime)
    {
        token = smarttokeninterface(_token);
        ethertoken = _ethertoken;
        starttime = _starttime;
        endtime = starttime + duration;
        beneficiary = _beneficiary;
        bitcoinsuisse = _bitcoinsuisse;

        adderc20token(_ethertoken, 0, 1, 1); 

        adderc20token(0xa74476443119a942de498590fe1f2454d7d4ac0d, 20, 1, 1); 
        adderc20token(0x48c80f1f4d53d5951e5d5438b54cba84f29f32a5, 20, 1, 1); 

        adderc20token(0x6810e776880c02933d47db1b9fc05908e5386b96, 10, 1, 1); 
        adderc20token(0xaec2e87e0a235266d9c5adc9deb4b2e29b54d009, 10, 1, 1); 
        adderc20token(0xe0b7927c4af23765cb51314a0e0521a9645f0e2a, 10, 1, 1); 

        adderc20token(0x4993cb95c7443bdc06155c5f5688be9d8f6999a5, 5, 1, 1); 
        adderc20token(0x607f4c5bb672230e8672085532f7e901544a7375, 5, 1, 1); 
        adderc20token(0x888666ca69e0f178ded6d75b5726cee99a87d698, 5, 1, 1); 
        adderc20token(0xaf30d2a7e90d7dc361c8c4585e9bb7d2f6f15bc7, 5, 1, 1); 
        adderc20token(0xbeb9ef514a379b997e0798fdcc901ee474b6d9a1, 5, 1, 1); 
        adderc20token(0x667088b212ce3d06a1b553a7221e1fd19000d9af, 5, 1, 1); 
    }

    
    modifier validaddress(address _address) {
        require(_address != 0x0);
        _;
    }

    
    modifier validerc20token(address _address) {
        require(tokendata[_address].isset);
        _;
    }

    
    modifier validtoken(address _address) {
        require(_address == address(token) || tokendata[_address].isset);
        _;
    }

    
    modifier validerc20tokenlimit(uint16 _limit) {
        require(_limit <= 1000);
        _;
    }

    
    modifier active() {
        assert(isactive);
        _;
    }

    
    modifier inactive() {
        assert(!isactive);
        _;
    }

    
    modifier earlierthan(uint256 _time) {
        assert(now < _time);
        _;
    }

    
    modifier laterthan(uint256 _time) {
        assert(now > _time);
        _;
    }

    
    modifier ethercapnotreached() {
        assert(ethercontributed < ether_cap);
        _;
    }

    
    modifier bitcoinsuisseonly() {
        assert(msg.sender == bitcoinsuisse);
        _;
    }

    
    modifier bitcoinsuisseethercapnotreached() {
        assert(ethercontributed < bitcoin_suisse_ether_cap);
        _;
    }

    
    function changeabletokencount() public constant returns (uint16 count) {
        return uint16(acceptedtokens.length + 1);
    }

    
    function changeabletoken(uint16 _tokenindex) public constant returns (address tokenaddress) {
        if (_tokenindex == 0)
            return token;
        return acceptedtokens[_tokenindex  1];
    }

    
    function adderc20token(address _token, uint16 _limit, uint256 _valuen, uint256 _valued)
        public
        owneronly
        inactive
        validaddress(_token)
        validerc20tokenlimit(_limit)
        returns (bool success)
    {
        require(_token != address(this) && _token != address(token) && !tokendata[_token].isset && _valuen != 0 && _valued != 0); 

        tokendata[_token].limit = _limit;
        tokendata[_token].valuen = _valuen;
        tokendata[_token].valued = _valued;
        tokendata[_token].isenabled = true;
        tokendata[_token].isset = true;
        acceptedtokens.push(_token);
        return true;
    }

    
    function updateerc20token(address _erc20token, uint16 _limit, uint256 _valuen, uint256 _valued)
        public
        owneronly
        validerc20token(_erc20token)
        validerc20tokenlimit(_limit)
        returns (bool success)
    {
        require(_valuen != 0 && _valued != 0); 
        erc20tokendata data = tokendata[_erc20token];
        data.limit = _limit;
        data.valuen = _valuen;
        data.valued = _valued;
        return true;
    }

    
    function disableerc20token(address _erc20token, bool _disable)
        public
        owneronly
        validerc20token(_erc20token)
    {
        tokendata[_erc20token].isenabled = !_disable;
    }

    
    function withdraw(address _erc20token, address _to, uint256 _amount)
        public
        owneronly
        validerc20token(_erc20token)
        validaddress(_to)
        returns (bool success)
    {
        require(_to != address(this) && _to != address(token) && _amount != 0); 

        erc20tokeninterface erc20token = erc20tokeninterface(_erc20token);
        assert(erc20token.transfer(_to, _amount));
        return true;
    }

    
    function settokenchanger(address _changer)
        public
        owneronly
        validaddress(_changer)
        returns (bool success)
    {
        require(_changer != address(this) && _changer != address(token)); 
        return token.setchanger(_changer);
    }

    
    function activate(bool _activate) public owneronly returns (bool success)
    {
        assert(!_activate || acceptedtokens.length > 0); 
        if (_activate)
            token.disabletransfers(true);

        isactive = _activate;
        return true;
    }

    
    function getreturn(address _fromtoken, address _totoken, uint256 _amount) public constant returns (uint256 amount) {
        require(_totoken == address(token)); 
        return getpurchasereturn(_fromtoken, _amount);
    }

    
    function getpurchasereturn(address _erc20token, uint256 _depositamount)
        public
        constant
        active
        ethercapnotreached
        validerc20token(_erc20token)
        returns (uint256 amount)
    {
        erc20tokendata data = tokendata[_erc20token];
        require(data.isenabled && _depositamount != 0); 

        uint256 depositethvalue = safemul(_depositamount, data.valuen) / data.valued;
        if (depositethvalue == 0)
            return 0;

        
        require(safeadd(ethercontributed, depositethvalue) <= ether_cap);

        
        if (data.limit != 0) {
            erc20tokeninterface erc20token = erc20tokeninterface(_erc20token);
            uint256 balance = erc20token.balanceof(beneficiary);
            uint256 balanceethvalue = safemul(balance, data.valuen) / data.valued;  
            uint256 limit = safemul(ethercontributed, data.limit) / 1000; 
            require(safeadd(balanceethvalue, depositethvalue) <= limit);
        }

        
        if (tokenreservebalance == 0 || token.totalsupply() == 0)
            return safemul(depositethvalue, initial_price_d) / initial_price_n;

        
        
        uint256 temp = safemul(depositethvalue, token.totalsupply());
        temp = safemul(temp, reserve_ratio);
        return temp / 100 / tokenreservebalance;
    }

    
    function change(address _fromtoken, address _totoken, uint256 _amount, uint256 _minreturn) public returns (uint256 amount) {
        require(_totoken == address(token)); 
        return buyerc20(_fromtoken, _amount, _minreturn);
    }

    
    function buyerc20(address _erc20token, uint256 _depositamount, uint256 _minreturn)
        public
        laterthan(starttime)
        earlierthan(endtime)
        returns (uint256 amount)
    {
        amount = getpurchasereturn(_erc20token, _depositamount);
        assert(amount != 0 && amount >= _minreturn); 

        erc20tokeninterface erc20token = erc20tokeninterface(_erc20token);
        assert(erc20token.transferfrom(msg.sender, beneficiary, _depositamount)); 

        erc20tokendata data = tokendata[_erc20token];
        uint256 depositethvalue = safemul(_depositamount, data.valuen) / data.valued;
        handlecontribution(msg.sender, depositethvalue, amount);
        dispatchchange(_erc20token, token, msg.sender, _depositamount, amount);
        return amount;
    }

    
    function buyeth()
        public
        payable
        laterthan(starttime)
        earlierthan(endtime)
        returns (uint256 amount)
    {
        amount = handleethdeposit(msg.sender, msg.value);
        dispatchchange(ethertoken, token, msg.sender, msg.value, amount);
        return amount;
    }

    
    function buybitcoinsuisse(address _contributor)
        public
        payable
        bitcoinsuisseonly
        bitcoinsuisseethercapnotreached
        earlierthan(starttime)
        returns (uint256 amount)
    {
        require(safeadd(ethercontributed, msg.value) <= bitcoin_suisse_ether_cap); 
        amount = handleethdeposit(_contributor, msg.value);
        dispatchchange(ethertoken, token, msg.sender, msg.value, amount);
        return amount;
    }

    
    function handleethdeposit(address _contributor, uint256 _depositamount) private returns (uint256 amount) {
        require(_depositamount > 0); 
        amount = getpurchasereturn(ethertoken, _depositamount);
        assert(amount != 0); 

        ethertoken ethtoken = ethertoken(ethertoken);
        assert(ethtoken.deposit.value(_depositamount)()); 
        assert(ethtoken.transfer(beneficiary, _depositamount)); 
        handlecontribution(_contributor, _depositamount, amount);
        return amount;
    }

    
    function handlecontribution(address _contributor, uint256 _depositethvalue, uint256 _return) private {
        
        uint8 reserveallocationpercentage;
        if (ethercontributed >= phase3_min_contribution)
            reserveallocationpercentage = phase3_reserve_allocation;
        else if (ethercontributed >= phase2_min_contribution)
            reserveallocationpercentage = phase2_reserve_allocation;
        else if (ethercontributed >= phase1_min_contribution)
            reserveallocationpercentage = phase1_reserve_allocation;

        uint256 addtoreserve = safemul(_depositethvalue, reserveallocationpercentage) / 100;
        tokenreservebalance = safeadd(tokenreservebalance, addtoreserve);

        
        ethercontributed = safeadd(ethercontributed, _depositethvalue);
        
        assert(token.issue(_contributor, _return));

        
        uint256 amount = safemul(100, _return) / (100  beneficiary_percentage);
        amount = safesub(amount, _return);
        if (amount == 0)
            return;

        assert(token.issue(beneficiary, amount));
    }

    

    function dispatchchange(address _fromtoken, address _totoken, address _trader, uint256 _amount, uint256 _return) private {
        change(_fromtoken, _totoken, _trader, _amount, _return);

        if (address(events) != 0x0)
            events.tokenchange(_fromtoken, _totoken, _trader, _amount, _return);
    }

    
    function() payable {
        buyeth();
    }
}
