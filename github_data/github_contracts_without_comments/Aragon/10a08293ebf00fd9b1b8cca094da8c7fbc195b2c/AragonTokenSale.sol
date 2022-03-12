pragma solidity ^0.4.8;

import ;
import ;
import ;
import ;
import ;



contract aragontokensale is controller, safemath {
    uint public initialblock;             
    uint public finalblock;               
    uint public initialprice;             
    uint public finalprice;               
    uint8 public pricestages;             
    address public aragondevmultisig;     
    address public communitymultisig;     
    bytes32 public capcommitment;

    uint public totalcollected = 0;               
    bool public salestopped = false;              
    bool public salefinalized = false;            

    mapping (address => bool) public activated;   

    ant public token;                             
    anplaceholder public networkplaceholder;      
    salewallet public salewallet;                    

    uint constant public dust = 1 finney;         
    uint public hardcap = 1500000 ether;          

    event newpresaleallocation(address indexed holder, uint256 antamount);
    event newbuyer(address indexed holder, uint256 antamount, uint256 etheramount);
    event caprevealed(uint value, uint secret, address revealer);











  function aragontokensale (
      uint _initialblock,
      uint _finalblock,
      address _aragondevmultisig,
      address _communitymultisig,
      uint256 _initialprice,
      uint256 _finalprice,
      uint8 _pricestages,
      bytes32 _capcommitment
  )
      non_zero_address(_aragondevmultisig)
      non_zero_address(_communitymultisig)
  {
      if (_initialblock < getblocknumber()) throw;
      if (_initialblock >= _finalblock) throw;
      if (_initialprice <= _finalprice) throw;
      if (_pricestages < 2) throw;
      if (_pricestages > _initialprice  _finalprice) throw;
      if (uint(_capcommitment) == 0) throw;

      
      initialblock = _initialblock;
      finalblock = _finalblock;
      aragondevmultisig = _aragondevmultisig;
      communitymultisig = _communitymultisig;
      initialprice = _initialprice;
      finalprice = _finalprice;
      pricestages = _pricestages;
      capcommitment = _capcommitment;
  }

  
  
  
  

  function setant(address _token, address _networkplaceholder, address _salewallet)
           non_zero_address(_token)
           non_zero_address(_networkplaceholder)
           non_zero_address(_salewallet)
           only(aragondevmultisig) {

    
    if (activated[this]) throw;

    token = ant(_token);
    networkplaceholder = anplaceholder(_networkplaceholder);
    salewallet = salewallet(_salewallet);

    if (token.controller() != address(this)) throw; 
    if (networkplaceholder.sale() != address(this)) throw; 
    if (networkplaceholder.token() != address(token)) throw; 
    if (token.totalsupply() > 0) throw; 
    if (salewallet.finalblock() != finalblock) throw; 
    if (salewallet.multisig() != aragondevmultisig) throw; 

    
    doactivatesale(this);
  }

  
  
  
  function activatesale() {
    doactivatesale(msg.sender);
  }

  function doactivatesale(address _entity)
    non_zero_address(token)               
    only_before_sale
    private {
    activated[_entity] = true;
  }

  
  
  function isactivated() constant returns (bool) {
    return activated[this] && activated[aragondevmultisig] && activated[communitymultisig];
  }

  
  
  
  
  function getprice(uint _blocknumber) constant returns (uint256) {
    if (_blocknumber < initialblock || _blocknumber >= finalblock) return 0;

    return priceforstage(stageforblock(_blocknumber));
  }

  
  
  
  function stageforblock(uint _blocknumber) constant returns (uint8) {
    uint blockn = safesub(_blocknumber, initialblock);
    uint totalblocks = safesub(finalblock, initialblock);

    return uint8(safediv(safemul(pricestages, blockn), totalblocks));
  }

  
  
  
  
  function priceforstage(uint8 _stage) constant returns (uint256) {
    if (_stage >= pricestages) return 0;
    uint pricedifference = safesub(initialprice, finalprice);
    uint stagedelta = safediv(pricedifference, uint(pricestages  1));
    return safesub(initialprice, safemul(uint256(_stage), stagedelta));
  }

  
  
  
  
  
  function allocatepresaletokens(address _receiver, uint _amount, uint64 cliffdate, uint64 vestingdate)
           only_before_sale_activation
           only_before_sale
           non_zero_address(_receiver)
           only(aragondevmultisig) {

    if (_amount > 10 ** 24) throw; 

    if (!token.generatetokens(address(this), _amount)) throw;
    token.grantvestedtokens(_receiver, _amount, uint64(now), cliffdate, vestingdate);

    newpresaleallocation(_receiver, _amount);
  }






  function () payable {
    return dopayment(msg.sender);
  }









  function proxypayment(address _owner) payable returns (bool) {
    dopayment(_owner);
    return true;
  }







  function ontransfer(address _from, address _to, uint _amount) returns (bool) {
    
    
    return _from == address(this);
  }







  function onapprove(address _owner, address _spender, uint _amount) returns (bool) {
    
    return false;
  }





  function dopayment(address _owner)
           only_during_sale_period
           only_sale_not_stopped
           only_sale_activated
           non_zero_address(_owner)
           minimum_value(dust)
           internal {

    if (totalcollected + msg.value > hardcap) throw; 

    uint256 boughttokens = safemul(msg.value, getprice(getblocknumber())); 

    if (!salewallet.send(msg.value)) throw; 
    if (!token.generatetokens(_owner, boughttokens)) throw; 

    totalcollected = safeadd(totalcollected, msg.value); 

    newbuyer(_owner, boughttokens, msg.value);
  }

  
  
  function emergencystopsale()
           only_sale_activated
           only_sale_not_stopped
           only(aragondevmultisig) {

    salestopped = true;
  }

  
  
  function restartsale()
           only_during_sale_period
           only_sale_stopped
           only(aragondevmultisig) {

    salestopped = false;
  }

  function revealcap(uint256 _cap, uint256 _cap_secure)
           only_during_sale_period
           only_sale_activated
           verify_cap(_cap, _cap_secure) {

    if (_cap > hardcap) throw;

    caprevealed(_cap, _cap_secure, msg.sender);

    if (totalcollected < _cap) {
      hardcap = _cap;
    } else {
      dofinalizesale(_cap, _cap_secure);
    }
  }

  
  
  function finalizesale(uint256 _cap, uint256 _cap_secure)
           only_after_sale
           only(aragondevmultisig) {

    dofinalizesale(_cap, _cap_secure);
  }

  function dofinalizesale(uint256 _cap, uint256 _cap_secure)
           verify_cap(_cap, _cap_secure)
           internal {
    
    
    

    
    uint256 aragontokens = token.totalsupply() * 3 / 7;
    if (!token.generatetokens(aragondevmultisig, aragontokens)) throw;
    token.changecontroller(networkplaceholder); 

    salefinalized = true;  
    salestopped = true;
  }

  
  
  function deploynetwork(address networkaddress)
           only_finalized_sale
           non_zero_address(networkaddress)
           only(communitymultisig) {

    networkplaceholder.changecontroller(networkaddress);
    suicide(networkaddress);
  }

  function setaragondevmultisig(address _newmultisig)
           non_zero_address(_newmultisig)
           only(aragondevmultisig) {

    aragondevmultisig = _newmultisig;
  }

  function setcommunitymultisig(address _newmultisig)
           non_zero_address(_newmultisig)
           only(communitymultisig) {

    communitymultisig = _newmultisig;
  }

  function getblocknumber() constant returns (uint) {
    return block.number;
  }

  function computecap(uint256 _cap, uint256 _cap_secure) constant returns (bytes32) {
    return sha3(_cap, _cap_secure);
  }

  function isvalidcap(uint256 _cap, uint256 _cap_secure) constant returns (bool) {
    return computecap(_cap, _cap_secure) == capcommitment;
  }

  modifier only(address x) {
    if (msg.sender != x) throw;
    _;
  }

  modifier verify_cap(uint256 _cap, uint256 _cap_secure) {
    if (!isvalidcap(_cap, _cap_secure)) throw;
    _;
  }

  modifier only_before_sale {
    if (getblocknumber() >= initialblock) throw;
    _;
  }

  modifier only_during_sale_period {
    if (getblocknumber() < initialblock) throw;
    if (getblocknumber() >= finalblock) throw;
    _;
  }

  modifier only_after_sale {
    if (getblocknumber() < finalblock) throw;
    _;
  }

  modifier only_sale_stopped {
    if (!salestopped) throw;
    _;
  }

  modifier only_sale_not_stopped {
    if (salestopped) throw;
    _;
  }

  modifier only_before_sale_activation {
    if (isactivated()) throw;
    _;
  }

  modifier only_sale_activated {
    if (!isactivated()) throw;
    _;
  }

  modifier only_finalized_sale {
    if (getblocknumber() < finalblock) throw;
    if (!salefinalized) throw;
    _;
  }

  modifier non_zero_address(address x) {
    if (x == 0) throw;
    _;
  }

  modifier minimum_value(uint256 x) {
    if (msg.value < x) throw;
    _;
  }
}
