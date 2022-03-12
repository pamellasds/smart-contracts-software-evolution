pragma solidity ^0.4.10;
import ;
import ;
import ;
import ;
import ;




contract crowdsalechanger is owned, safemath, itokenchanger {
    struct erc20tokendata {
        uint256 valuen; 
        uint256 valued; 
        bool isenabled; 
        bool isset;     
    }

    uint256 public constant duration = 7 days;              
    uint256 public constant btcs_ether_cap = 50000 ether;   
    uint256 public constant token_price_n = 1;              
    uint256 public constant token_price_d = 100;            

    string public version = ;
    string public changertype = ;

    uint256 public starttime = 0;                               
    uint256 public endtime = 0;                                 
    uint256 public totalethercap = 1000000 ether;               
    uint256 public totalethercontributed = 0;                   
    bytes32 public realethercaphash;                            
    iethertoken public ethertoken;                              
    address public beneficiary = 0x0;                           
    address public btcs = 0x0;                                  
    ismarttoken public token;                                   
    address[] public acceptedtokens;                            
    mapping (address => erc20tokendata) public tokendata;       
    mapping (address => uint256) public beneficiarybalances;    

    
    event change(address indexed _fromtoken, address indexed _totoken, address indexed _trader, uint256 _amount, uint256 _return);

    
    function crowdsalechanger(ismarttoken _token, iethertoken _ethertoken, uint256 _starttime, address _beneficiary, address _btcs, bytes32 _realethercaphash)
        validaddress(_token)
        validaddress(_ethertoken)
        validaddress(_beneficiary)
        validaddress(_btcs)
        earlierthan(_starttime)
        validamount(uint256(_realethercaphash))
    {
        token = _token;
        ethertoken = _ethertoken;
        starttime = _starttime;
        endtime = starttime + duration;
        beneficiary = _beneficiary;
        btcs = _btcs;
        realethercaphash = _realethercaphash;

        adderc20token(_ethertoken, 1, 1); 
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

    
    modifier validamount(uint256 _amount) {
        require(_amount > 0);
        _;
    }

    
    modifier validethercap(uint256 _cap, uint256 _key) {
        require(computerealcap(_cap, _key) == realethercaphash);
        _;
    }

    
    modifier active() {
        assert(token.changer() == this);
        _;
    }

    
    modifier inactive() {
        assert(token.changer() != this);
        _;
    }

    
    modifier earlierthan(uint256 _time) {
        assert(now < _time);
        _;
    }

    
    modifier between(uint256 _starttime, uint256 _endtime) {
        assert(now >= _starttime && now < _endtime);
        _;
    }

    
    modifier ethercapnotreached() {
        assert(totalethercontributed < totalethercap);
        _;
    }

    
    modifier btcsonly() {
        assert(msg.sender == btcs);
        _;
    }

    
    modifier btcsethercapnotreached(uint256 _ethcontribution) {
        assert(safeadd(totalethercontributed, _ethcontribution) <= btcs_ether_cap);
        _;
    }

    
    function acceptedtokencount() public constant returns (uint16 count) {
        return uint16(acceptedtokens.length);
    }

    
    function changeabletokencount() public constant returns (uint16 count) {
        return uint16(acceptedtokens.length + 1);
    }

    
    function changeabletoken(uint16 _tokenindex) public constant returns (address tokenaddress) {
        if (_tokenindex == 0)
            return token;
        return acceptedtokens[_tokenindex  1];
    }

    function initerc20tokens()
        public
        owneronly
        inactive
    {
        adderc20token(ierc20token(0xa74476443119a942de498590fe1f2454d7d4ac0d), 1, 1); 
        adderc20token(ierc20token(0x48c80f1f4d53d5951e5d5438b54cba84f29f32a5), 1, 1); 

        adderc20token(ierc20token(0x6810e776880c02933d47db1b9fc05908e5386b96), 1, 1); 
        adderc20token(ierc20token(0xaec2e87e0a235266d9c5adc9deb4b2e29b54d009), 1, 1); 
        adderc20token(ierc20token(0xe0b7927c4af23765cb51314a0e0521a9645f0e2a), 1, 1); 

        adderc20token(ierc20token(0x4993cb95c7443bdc06155c5f5688be9d8f6999a5), 1, 1); 
        adderc20token(ierc20token(0x607f4c5bb672230e8672085532f7e901544a7375), 1, 1); 
        adderc20token(ierc20token(0x888666ca69e0f178ded6d75b5726cee99a87d698), 1, 1); 
        adderc20token(ierc20token(0xaf30d2a7e90d7dc361c8c4585e9bb7d2f6f15bc7), 1, 1); 
        adderc20token(ierc20token(0xbeb9ef514a379b997e0798fdcc901ee474b6d9a1), 1, 1); 
        adderc20token(ierc20token(0x667088b212ce3d06a1b553a7221e1fd19000d9af), 1, 1); 
    }

    
    function adderc20token(ierc20token _token, uint256 _valuen, uint256 _valued)
        public
        owneronly
        inactive
        validaddress(_token)
        validamount(_valuen)
        validamount(_valued)
    {
        require(_token != address(this) && _token != token && !tokendata[_token].isset); 

        tokendata[_token].valuen = _valuen;
        tokendata[_token].valued = _valued;
        tokendata[_token].isenabled = true;
        tokendata[_token].isset = true;
        acceptedtokens.push(_token);
    }

    
    function updateerc20token(ierc20token _erc20token, uint256 _valuen, uint256 _valued)
        public
        owneronly
        validerc20token(_erc20token)
        validamount(_valuen)
        validamount(_valued)
    {
        erc20tokendata data = tokendata[_erc20token];
        data.valuen = _valuen;
        data.valued = _valued;
    }

    
    function disableerc20token(ierc20token _erc20token, bool _disable)
        public
        owneronly
        validerc20token(_erc20token)
    {
        tokendata[_erc20token].isenabled = !_disable;
    }

    
    function withdraw(ierc20token _erc20token, address _to, uint256 _amount)
        public
        owneronly
        validerc20token(_erc20token)
        validaddress(_to)
        validamount(_amount)
    {
        require(_to != address(this) && _to != address(token)); 
        assert(_erc20token.transfer(_to, _amount));
    }

    
    function enablerealcap(uint256 _cap, uint256 _key)
        public
        owneronly
        active
        between(starttime, endtime)
        validamount(_cap)
        validethercap(_cap, _key)
    {
        totalethercap = _cap;
    }

    
    function settokenchanger(itokenchanger _changer) public owneronly {
        require(_changer != this && _changer != address(token)); 
        token.setchanger(_changer);
    }

    
    function getreturn(address _fromtoken, address _totoken, uint256 _amount) public constant returns (uint256 amount) {
        require(_totoken == address(token)); 
        return getpurchasereturn(ierc20token(_fromtoken), _amount);
    }

    
    function getpurchasereturn(ierc20token _erc20token, uint256 _depositamount)
        public
        constant
        active
        ethercapnotreached
        validerc20token(_erc20token)
        validamount(_depositamount)
        returns (uint256 amount)
    {
        erc20tokendata data = tokendata[_erc20token];
        require(data.isenabled); 

        uint256 depositethvalue = safemul(_depositamount, data.valuen) / data.valued;
        if (depositethvalue == 0)
            return 0;

        
        require(safeadd(totalethercontributed, depositethvalue) <= totalethercap);
        return depositethvalue * token_price_d / token_price_n;
    }

    
    function change(address _fromtoken, address _totoken, uint256 _amount, uint256 _minreturn) public returns (uint256 amount) {
        require(_totoken == address(token)); 
        return buyerc20(ierc20token(_fromtoken), _amount, _minreturn);
    }

    
    function buyerc20(ierc20token _erc20token, uint256 _depositamount, uint256 _minreturn)
        public
        between(starttime, endtime)
        returns (uint256 amount)
    {
        amount = getpurchasereturn(_erc20token, _depositamount);
        assert(amount != 0 && amount >= _minreturn); 

        ierc20token erc20token = ierc20token(_erc20token);
        assert(erc20token.transferfrom(msg.sender, beneficiary, _depositamount)); 
        beneficiarybalances[erc20token] = safeadd(beneficiarybalances[erc20token], _depositamount); 

        erc20tokendata data = tokendata[_erc20token];
        uint256 depositethvalue = safemul(_depositamount, data.valuen) / data.valued;
        handlecontribution(msg.sender, depositethvalue, amount);
        change(_erc20token, token, msg.sender, _depositamount, amount);
        return amount;
    }

    
    function buyeth()
        public
        payable
        between(starttime, endtime)
        returns (uint256 amount)
    {
        amount = handleethdeposit(msg.sender, msg.value);
        change(ethertoken, token, msg.sender, msg.value, amount);
        return amount;
    }

    
    function buybtcs(address _contributor)
        public
        payable
        btcsonly
        btcsethercapnotreached(msg.value)
        earlierthan(starttime)
        returns (uint256 amount)
    {
        amount = handleethdeposit(_contributor, msg.value);
        change(ethertoken, token, msg.sender, msg.value, amount);
        return amount;
    }

    
    function handleethdeposit(address _contributor, uint256 _depositamount) private returns (uint256 amount) {
        amount = getpurchasereturn(ethertoken, _depositamount);
        assert(amount != 0); 

        ethertoken.deposit.value(_depositamount)(); 
        assert(ethertoken.transfer(beneficiary, _depositamount)); 
        beneficiarybalances[ethertoken] = safeadd(beneficiarybalances[ethertoken], _depositamount); 
        handlecontribution(_contributor, _depositamount, amount);
        return amount;
    }

    
    function handlecontribution(address _contributor, uint256 _depositethvalue, uint256 _return) private {
        
        totalethercontributed = safeadd(totalethercontributed, _depositethvalue);
        
        token.issue(_contributor, _return);
        
        token.issue(beneficiary, _return);
    }

    
    function computerealcap(uint256 _cap, uint256 _key) private returns (bytes32) {
        return sha3(_cap, _key);
    }

    
    function() payable {
        buyeth();
    }
}
