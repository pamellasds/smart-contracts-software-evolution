pragma solidity ^0.4.8;

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

    uint public totalcollected = 0;               
    bool public salestopped = false;              
    bool public salefinalized = false;            

    mapping (address => bool) public activated;   

    ant public token;                             
    anplaceholder public networkplaceholder;      

    uint constant public dust = 1 finney;        

    event newpresaleallocation(address holder, uint256 antamount);
    event newbuyer(address holder, uint256 antamount, uint256 etheramount);












  function aragontokensale (
      uint _initialblock,
      uint _finalblock,
      address _aragondevmultisig,
      address _communitymultisig,
      uint256 _initialprice,
      uint256 _finalprice,
      uint8 _pricestages
  )
      non_zero_address(_aragondevmultisig)
      non_zero_address(_communitymultisig)
  {
      if (_initialblock < getblocknumber()) throw;
      if (_initialblock >= _finalblock) throw;
      if (_initialprice <= _finalprice) throw;
      if (_pricestages < 1) throw;
      if (_pricestages > _initialprice  _finalprice) throw;

      
      initialblock = _initialblock;
      finalblock = _finalblock;
      aragondevmultisig = _aragondevmultisig;
      communitymultisig = _communitymultisig;
      initialprice = _initialprice;
      finalprice = _finalprice;
      pricestages = _pricestages;
  }

  
  
  

  function setant(address _token, address _networkplaceholder)
           non_zero_address(_token)
           non_zero_address(_networkplaceholder)
           only(aragondevmultisig) {

    
    if (activated[this]) throw;

    token = ant(_token);
    networkplaceholder = anplaceholder(_networkplaceholder);

    if (token.controller() != address(this)) throw; 
    if (networkplaceholder.sale() != address(this)) throw; 
    if (networkplaceholder.token() != address(token)) throw; 
    if (token.totalsupply() > 0) throw; 

    
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
           non_zero_address(receiver)
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
           minimum_value(dust)
           internal {

    uint256 boughttokens = safemul(msg.value, getprice(getblocknumber())); 

    if (!aragondevmultisig.send(msg.value)) throw; 
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

  
  

  function finalizesale()
           only_after_sale
           only(aragondevmultisig) {
    
    
    

    
    uint256 aragontokens = token.totalsupply() * 3 / 7;
    if (!token.generatetokens(aragondevmultisig, aragontokens)) throw;
    token.changecontroller(networkplaceholder); 

    salefinalized = true; 
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

  modifier only(address x) {
    if (msg.sender != x) throw;
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
