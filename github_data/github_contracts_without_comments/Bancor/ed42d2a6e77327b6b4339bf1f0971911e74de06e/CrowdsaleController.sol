pragma solidity ^0.4.23;
import ;
import ;


contract crowdsalecontroller is smarttokencontroller {
    uint256 public constant duration = 14 days;                 
    uint256 public constant token_price_n = 1;                  
    uint256 public constant token_price_d = 100;                
    uint256 public constant btcs_ether_cap = 50000 ether;       
    uint256 public constant max_gas_price = 50000000000 wei;    

    string public version = ;

    uint256 public starttime = 0;                   
    uint256 public endtime = 0;                     
    uint256 public totalethercap = 1000000 ether;   
    uint256 public totalethercontributed = 0;       
    bytes32 public realethercaphash;                
    address public beneficiary = address(0);        
    address public btcs = address(0);               

    
    event contribution(address indexed _contributor, uint256 _amount, uint256 _return);

    
    function crowdsalecontroller(ismarttoken _token, uint256 _starttime, address _beneficiary, address _btcs, bytes32 _realethercaphash)
        public
        smarttokencontroller(_token)
        validaddress(_beneficiary)
        validaddress(_btcs)
        earlierthan(_starttime)
        greaterthanzero(uint256(_realethercaphash))
    {
        starttime = _starttime;
        endtime = starttime + duration;
        beneficiary = _beneficiary;
        btcs = _btcs;
        realethercaphash = _realethercaphash;
    }

    
    modifier validgasprice() {
        assert(tx.gasprice <= max_gas_price);
        _;
    }

    
    modifier validethercap(uint256 _cap, uint256 _key) {
        require(computerealcap(_cap, _key) == realethercaphash);
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

    
    modifier btcsonly() {
        assert(msg.sender == btcs);
        _;
    }

    
    modifier ethercapnotreached(uint256 _contribution) {
        assert(safeadd(totalethercontributed, _contribution) <= totalethercap);
        _;
    }

    
    modifier btcsethercapnotreached(uint256 _ethcontribution) {
        assert(safeadd(totalethercontributed, _ethcontribution) <= btcs_ether_cap);
        _;
    }

    
    function computerealcap(uint256 _cap, uint256 _key) public pure returns (bytes32) {
        return keccak256(_cap, _key);
    }

    
    function enablerealcap(uint256 _cap, uint256 _key)
        public
        owneronly
        active
        between(starttime, endtime)
        validethercap(_cap, _key)
    {
        require(_cap < totalethercap); 
        totalethercap = _cap;
    }

    
    function computereturn(uint256 _contribution) public pure returns (uint256) {
        return safemul(_contribution, token_price_d) / token_price_n;
    }

    
    function contributeeth()
        public
        payable
        between(starttime, endtime)
        returns (uint256 amount)
    {
        return processcontribution();
    }

    
    function contributebtcs()
        public
        payable
        btcsonly
        btcsethercapnotreached(msg.value)
        earlierthan(starttime)
        returns (uint256 amount)
    {
        return processcontribution();
    }

    
    function processcontribution() private
        active
        ethercapnotreached(msg.value)
        validgasprice
        returns (uint256 amount)
    {
        uint256 tokenamount = computereturn(msg.value);
        beneficiary.transfer(msg.value); 
        totalethercontributed = safeadd(totalethercontributed, msg.value); 
        token.issue(msg.sender, tokenamount); 
        token.issue(beneficiary, tokenamount); 

        emit contribution(msg.sender, msg.value, tokenamount);
        return tokenamount;
    }

    
    function() payable public {
        contributeeth();
    }
}
