pragma solidity ^0.4.8;



import ;
import ;











contract minimeirrevocablevestedtoken is minimetoken, safemath {
  
  struct tokengrant {
    address granter;
    uint256 value;
    uint64 cliff;
    uint64 vesting;
    uint64 start;
  }

  event newtokengrant(address from, address to, uint256 value, uint64 start, uint64 cliff, uint64 vesting);

  mapping (address => tokengrant[]) public grants;

  mapping (address => bool) cancreategrants;
  address vestingwhitelister;

  modifier cantransfer(address _sender, uint _value) {
    if (_value > spendablebalanceof(_sender)) throw;
    _;
  }

  modifier onlyvestingwhitelister {
    if (msg.sender != vestingwhitelister) throw;
    _;
  }

  function minimeirrevocablevestedtoken (
      address _tokenfactory,
      address _parenttoken,
      uint _parentsnapshotblock,
      string _tokenname,
      uint8 _decimalunits,
      string _tokensymbol,
      bool _transfersenabled
  ) minimetoken(_tokenfactory, _parenttoken, _parentsnapshotblock, _tokenname, _decimalunits, _tokensymbol, _transfersenabled) {
    vestingwhitelister = msg.sender;
    dosetcancreategrants(vestingwhitelister, true);
  }

  
  function transfer(address _to, uint _value)
           cantransfer(msg.sender, _value)
           returns (bool success) {
    return super.transfer(_to, _value);
  }

  function transferfrom(address _from, address _to, uint _value)
           cantransfer(_from, _value)
           returns (bool success) {
    return super.transferfrom(_from, _to, _value);
  }

  function spendablebalanceof(address _holder) constant public returns (uint) {
    return transferabletokens(_holder, uint64(now));
  }

  function grantvestedtokens(
    address _to,
    uint256 _value,
    uint64 _start,
    uint64 _cliff,
    uint64 _vesting) {

    
    if (_cliff < _start) throw;
    if (_vesting < _start) throw;
    if (_vesting < _cliff) throw;

    if (!cancreategrants[msg.sender]) throw;
    if (grants[_to].length > 20) throw;   

    tokengrant memory grant = tokengrant(msg.sender, _value, _cliff, _vesting, _start);
    grants[_to].push(grant);

    if (!transfer(_to, _value)) throw;

    newtokengrant(msg.sender, _to, _value, _cliff, _vesting, _start);
  }

  function setcancreategrants(address _addr, bool _allowed)
           onlyvestingwhitelister {
    dosetcancreategrants(_addr, _allowed);
  }

  function dosetcancreategrants(address _addr, bool _allowed)
           internal {
    cancreategrants[_addr] = _allowed;
  }

  function changevestingwhitelister(address _newwhitelister) onlyvestingwhitelister {
    dosetcancreategrants(vestingwhitelister, false);
    vestingwhitelister = _newwhitelister;
    dosetcancreategrants(vestingwhitelister, true);
  }

  
  function revoketokengrant(address _holder, uint _grantid) {
    throw;
  }

  
    return grants[_holder].length;
  }

  function tokengrant(address _holder, uint _grantid) constant returns (address granter, uint256 value, uint256 vested, uint64 start, uint64 cliff, uint64 vesting) {
    tokengrant grant = grants[_holder][_grantid];

    granter = grant.granter;
    value = grant.value;
    start = grant.start;
    cliff = grant.cliff;
    vesting = grant.vesting;

    vested = vestedtokens(grant, uint64(now));
  }

  function vestedtokens(tokengrant grant, uint64 time) internal constant returns (uint256) {
    return calculatevestedtokens(
      grant.value,
      uint256(time),
      uint256(grant.start),
      uint256(grant.cliff),
      uint256(grant.vesting)
    );
  }

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  

  function calculatevestedtokens(
    uint256 tokens,
    uint256 time,
    uint256 start,
    uint256 cliff,
    uint256 vesting) internal constant returns (uint256)
    {

    
    if (time < cliff) return 0;
    if (time >= vesting) return tokens;

    
    
    

    
    uint256 vestedtokens = safediv(
                                  safemul(
                                    tokens,
                                    safesub(time, start)
                                    ),
                                  safesub(vesting, start)
                                  );

    return vestedtokens;
  }

  function nonvestedtokens(tokengrant grant, uint64 time) internal constant returns (uint256) {
    
    
    return safesub(grant.value, vestedtokens(grant, time));
  }

  
  
  function lasttokenistransferabledate(address holder) constant public returns (uint64 date) {
    date = uint64(now);
    uint256 grantindex = grants[holder].length;
    for (uint256 i = 0; i < grantindex; i++) {
      date = max64(grants[holder][i].vesting, date);
    }
  }

  
  function transferabletokens(address holder, uint64 time) constant public returns (uint256) {
    uint256 grantindex = grants[holder].length;

    if (grantindex == 0) return balanceof(holder); 

    
    uint256 nonvested = 0;
    for (uint256 i = 0; i < grantindex; i++) {
      nonvested = safeadd(nonvested, nonvestedtokens(grants[holder][i], time));
    }

    
    return safesub(balanceof(holder), nonvested);
  }
}
