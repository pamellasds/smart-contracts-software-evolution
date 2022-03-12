pragma solidity ^0.4.8;

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

    mapping (address => bool) public activated;   

    ant public token;                   
    address public aragonnetwork;       

    uint public dust = 1 finney;        












  function aragontokensale (
      uint _initialblock,
      uint _finalblock,
      address _aragondevmultisig,
      address _communitymultisig,
      uint256 _initialprice,
      uint256 _finalprice,
      uint8 _pricestages
  ) {
      if (_initialblock < getblocknumber()) throw;
      if (_initialblock >= _finalblock) throw;
      if (_aragondevmultisig == 0) throw;
      if (_communitymultisig == 0) throw;
      if (_initialprice <= _finalprice) throw;
      if (_pricestages < 1) throw;

      
      initialblock = _initialblock;
      finalblock = _finalblock;
      aragondevmultisig = _aragondevmultisig;
      communitymultisig = _communitymultisig;
      initialprice = _initialprice;
      finalprice = _finalprice;
      pricestages = _pricestages;
  }

  
  
  

  function deployant(address _factory, bool _testmode) only(aragondevmultisig) {
    
    if (activated[this]) throw;

    token = new ant(_factory);
    if (!_testmode && address(token) != addressforcontract(1)) throw; 

    aragonnetwork = addressforcontract(2); 

    
    doactivatesale(this);
  }

  
  
  
  function activatesale() {
    doactivatesale(msg.sender);
  }

  function doactivatesale(address _entity) only_before_sale private {
    if (address(token) == 0x0) throw; 
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

  
  
  
  
  
  function allocatepresaletokens(address _receiver, uint _amount)
           only_before_sale_activation
           only_before_sale
           only(aragondevmultisig) {

    if (!token.generatetokens(address(this), _amount)) throw;
    token.grantvestedtokens(_receiver, _amount, uint64(now), uint64(now + 12 weeks), uint64(now + 24 weeks));
  }






  function () payable {
    return dopayment(msg.sender);
  }









  function proxypayment(address _owner) payable returns (bool) {
    dopayment(_owner);
    return true;
  }







  function ontransfer(address _from, address _to, uint _amount) returns (bool) {
    return true;
  }







  function onapprove(address _owner, address _spender, uint _amount) returns (bool) {
    return true;
  }





  function dopayment(address _owner)
           only_during_sale_period
           only_sale_not_stopped
           only_sale_activated
           internal {

    if (token.controller() != address(this)) throw; 
    if (msg.value < dust) throw; 

    totalcollected = safeadd(totalcollected, msg.value); 
    uint256 boughttokens = safemul(msg.value, getprice(getblocknumber())); 

    if (boughttokens < 1) throw;

    if (!aragondevmultisig.send(msg.value)) throw; 
    if (!token.generatetokens(_owner, boughttokens)) throw; 
    return;
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

  
  
  
  

  function finalizesale() only(aragondevmultisig) {
    if (getblocknumber() < finalblock) throw;
    
    
    

    
    uint256 aragontokens = token.totalsupply() / 3;
    if (!token.generatetokens(aragondevmultisig, aragontokens)) throw;
    token.changecontroller(aragonnetwork); 

    salestopped = true; 
  }

  
  
  function deploynetwork(bytes _networkcode, bool _testmode)
           only_finalized_sale
           only(communitymultisig) {

    address deployedaddress;
    assembly {
      deployedaddress := create(0,add(_networkcode,0x20), mload(_networkcode))
      jumpi(invalidjumplabel,iszero(extcodesize(deployedaddress)))
    }

    if (!_testmode && deployedaddress != aragonnetwork) throw;
    suicide(aragonnetwork);
  }

  function addressforcontract(uint8 n) constant returns (address) {
    return address(sha3(0xd6, 0x94, this, n));
  }

  function setaragondevmultisig(address _newmultisig) only(aragondevmultisig) {
    aragondevmultisig = _newmultisig;
  }

  function setcommunitymultisig(address _newmultisig) only(communitymultisig) {
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
    if (!salestopped) throw;
    _;
  }
}
