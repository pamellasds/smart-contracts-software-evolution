pragma solidity ^0.4.18;


import ;
import ;




contract thetatokensale {

    using safemath for uint;

    address internal root;

    address internal admin;

    address internal whitelistcontroller;

    address internal exchangeratecontroller;

    address internal thetalabsreserve;

    address internal funddeposit;

    uint public initialblock;             

    uint public finalblock;               

    mapping (address => bool) public whitelistmap; 

    uint public exchangerate;                      

    uint internal fundcollected = 0;              
    bool public salestopped = false;               
    bool public salefinalized = false;             
    bool public activated = false;                 

    thetatoken public token;                       

    uint constant public decimals = 18;
    uint constant public dust = 1 ether;           
    uint public tokensalehardcap = 30 * (10**6) * (10**decimals); 
    uint public fundcollectedhardcap = 25000 * (10**18); 

    event whitelist(address addr);

    event removefromwhitelist(address addr);


    function thetatokensale(
        address _root,
        address _admin,
        address _whitelistcontroller,
        address _exchangeratecontroller,
        address _thetalabsreserve,
        address _funddeposit,
        uint _initialblock,
        uint _finalblock,
        uint _exchangerate)
        non_zero_address(_root)
        non_zero_address(_admin)
        non_zero_address(_whitelistcontroller)
        non_zero_address(_exchangeratecontroller)
        non_zero_address(_thetalabsreserve) 
        non_zero_address(_funddeposit) public {
        require(_initialblock >= getblocknumber());
        require(_initialblock < _finalblock);
        require(_exchangerate > 0);
        require(_root != _admin);
        require(_admin != _whitelistcontroller);
        require(_admin != _exchangeratecontroller);

        
        root  = _root;
        admin = _admin;
        whitelistcontroller = _whitelistcontroller;
        exchangeratecontroller = _exchangeratecontroller;
        thetalabsreserve = _thetalabsreserve;
        funddeposit = _funddeposit;
        initialblock = _initialblock;
        finalblock = _finalblock;
        exchangerate = _exchangerate;
    }

    function setthetatoken(address _token)
        non_zero_address(_token)
        only(admin)
        public {

        token = thetatoken(_token);
        require(token.controller() == address(this)); 
    }

    
    function activatesale() only(admin) public {
        require(token.controller() == address(this));
        activated = true;
    }

    function deactivatesale() only(admin) public {
        activated = false;
    }

    
    function allowprecirculation(address _addr) only(admin) public {
        token.allowprecirculation(_addr);
    }

    function disallowprecirculation(address _addr) only(admin) public {
        token.disallowprecirculation(_addr);
    }

    function isprecirculationallowed(address _addr) constant public returns (bool) {
        return token.isprecirculationallowed(_addr);
    }    

    function setexchangerate(uint _newexchangerate) only(exchangeratecontroller) public {
        require(_newexchangerate > 0);
        exchangerate = _newexchangerate;
    }

    function getfundcollected() only(admin) constant public returns (uint) {
        return fundcollected;
    }

    
    function allocatepresaletokens(address _recipient, uint _amount)
        only_before_sale
        non_zero_address(_recipient)
        only(admin)
        public {
        uint reserveamount = calcreserve(_amount);
        require(token.mint(thetalabsreserve, reserveamount));
        require(token.mint(_recipient, _amount));
    }

    function iswhitelisted(address account) constant public returns (bool) {
        return whitelistmap[account];
    }

    
    function addaccountstowhitelist(address[] _accounts) only(whitelistcontroller) public {
        for (uint i = 0; i < _accounts.length; i ++) {
            address account = _accounts[i];
            if (whitelistmap[account]) {
                continue;
            }
            whitelistmap[account] = true;
            whitelist(account);
        }
    }
 
    function deleteaccountsfromwhitelist(address[] _accounts) only(whitelistcontroller) public {
        for (uint i = 0; i < _accounts.length; i ++) {
            address account = _accounts[i];
            whitelistmap[account] = false;
            removefromwhitelist(account);
        }
    }

    
    function() public payable {
        dopayment(msg.sender);
    }

    
    
    function dopayment(address _owner)
        only_sale_activated
        only_during_sale_period
        only_sale_not_stopped
        non_zero_address(_owner)
        at_least(dust)
        internal {

        uint fundreceived = msg.value;
        require(fundcollected <= fundcollectedhardcap);

        
        uint boughttokens = msg.value.mul(exchangerate);

        
        uint tokensoldamount = token.totalsupply().mul(40).div(100); 
        require((tokensoldamount <= tokensalehardcap));
        require(whitelistmap[_owner]);

        
        require(funddeposit.send(fundreceived));

        
        uint reservetokens = calcreserve(boughttokens);
        require(token.mint(thetalabsreserve, reservetokens));
        require(token.mint(_owner, boughttokens));

        
        fundcollected = fundcollected.add(msg.value);
    }

    
    function emergencystopsale()
        only_sale_activated
        only_sale_not_stopped
        only(admin)
        public {

        salestopped = true;
    }

    
    function restartsale()
        only_sale_activated
        only_sale_stopped
        only(admin)
        public {

        salestopped = false;
    }

    
    
    function finalizesale()
        only_after_sale
        only(root)
        public {

        
        token.changecontroller(0);

        salefinalized = true;
        salestopped = true;
    }

    function changethetalabsreserve(address _newthetalabsreserve) 
        non_zero_address(_newthetalabsreserve)
        only(admin) public {
        thetalabsreserve = _newthetalabsreserve;
    }

    function changefunddeposit(address _newfunddeposit) 
        non_zero_address(_newfunddeposit)
        only(admin) public {
        funddeposit = _newfunddeposit;
    }

    function changetokensalehardcap(uint _newtokensalehardcap) only(admin) public {
        tokensalehardcap = _newtokensalehardcap;
    }

    function changefundcollectedhardcap(uint _newfundcollectedhardcap) only(admin) public {
        fundcollectedhardcap = _newfundcollectedhardcap;
    }

    function setendtimeofsale(uint _finalblock) only(admin) public {
        require(_finalblock > initialblock);
        finalblock = _finalblock;
    }

    function setstarttimeofsale(uint _initialblock) only(admin) public {
        require(_initialblock < finalblock);
        initialblock = _initialblock;
    }

    function changeunlocktime(uint _unlocktime) non_zero_address(address(token)) only(admin) public {
        token.changeunlocktime(_unlocktime);
    }

    function changeroot(address _newroot)
        non_zero_address(_newroot)
        only(root) public {
        require(_newroot != admin);
        require(_newroot != whitelistcontroller);
        require(_newroot != exchangeratecontroller);
        root = _newroot;
    }

    function changeadmin(address _newadmin)
        non_zero_address(_newadmin)
        only(root) public {
        require(_newadmin != root);
        require(_newadmin != whitelistcontroller);
        require(_newadmin != exchangeratecontroller);
        admin = _newadmin;
    }

    function changewhitelistcontroller(address _newwhitelistcontroller)
        non_zero_address(_newwhitelistcontroller)
        only(admin) public {
        require(_newwhitelistcontroller != root);
        require(_newwhitelistcontroller != admin);
        whitelistcontroller = _newwhitelistcontroller;
    }

    function changeexchangeratecontroller(address _newexchangeratecontroller)
        non_zero_address(_newexchangeratecontroller)
        only(admin) public {
        require(_newexchangeratecontroller != root);
        require(_newexchangeratecontroller != admin);
        exchangeratecontroller = _newexchangeratecontroller;
    }

    function getblocknumber() constant internal returns (uint) {
        return block.number;
    }

    function getroot() constant public only(admin) returns (address) {
        return root;
    }

    function getadmin() constant public only(admin) returns (address) {
        return admin;
    }

    function getwhitelistcontroller() constant public only(admin) returns (address) {
        return whitelistcontroller;
    }

    function getexchangeratecontroller() constant public only(admin) returns (address) {
        return exchangeratecontroller;
    }

    function getthetalabsreserve() constant public only(admin) returns (address) {
        return thetalabsreserve;
    }

    function getfunddeposit() constant public only(admin) returns (address) {
        return funddeposit;
    }

    function calcreserve(uint _amount) pure internal returns(uint) {
        uint reserveamount = _amount.mul(60).div(40);
        return reserveamount;
    }

    modifier only(address x) {
        require(msg.sender == x);
        _;
    }

    modifier only_before_sale {
        require(getblocknumber() < initialblock);
        _;
    }

    modifier only_during_sale_period {
        require(getblocknumber() >= initialblock);
        require(getblocknumber() < finalblock);
        _;
    }

    modifier only_after_sale {
        require(getblocknumber() >= finalblock);
        _;
    }

    modifier only_sale_stopped {
        require(salestopped);
        _;
    }

    modifier only_sale_not_stopped {
        require(!salestopped);
        _;
    }

    modifier only_sale_activated {
        require(activated);
        _;
    }

    modifier non_zero_address(address x) {
        require(x != 0);
        _;
    }

    modifier at_least(uint x) {
        require(msg.value >= x);
        _;
    }
}
