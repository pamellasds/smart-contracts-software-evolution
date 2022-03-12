pragma solidity ^0.4.11;



contract token 
{


    function totalsupply() constant returns (uint256) {}

    function balanceof(address) constant returns (uint256) {}

    function transfer(address, uint256) returns (bool) {}

    function transferfrom(address, address, uint256) returns (bool) {}

    function approve(address, uint256) returns (bool) {}

    function allowance(address, address) constant returns (uint256) {}


    event transfer(address indexed _from, address indexed _to, uint256 _value);
    event approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract stdtoken is token 
{

     mapping(address => uint256) balances;
     mapping (address => mapping (address => uint256)) allowed;

     uint256 public allsupply = 0;


     function transfer(address _to, uint256 _value) returns (bool success) 
     {
          if((balances[msg.sender] >= _value) && (balances[_to] + _value > balances[_to])) 
          {
               balances[msg.sender] = _value;
               balances[_to] += _value;

               transfer(msg.sender, _to, _value);
               return true;
          } 
          else 
          { 
               return false; 
          }
     }

     function transferfrom(address _from, address _to, uint256 _value) returns (bool success) 
     {
          if((balances[_from] >= _value) && (allowed[_from][msg.sender] >= _value) && (balances[_to] + _value > balances[_to])) 
          {
               balances[_to] += _value;
               balances[_from] = _value;
               allowed[_from][msg.sender] = _value;

               transfer(_from, _to, _value);
               return true;
          } 
          else 
          { 
               return false; 
          }
     }

     function balanceof(address _owner) constant returns (uint256) 
     {
          return balances[_owner];
     }

     function approve(address _spender, uint256 _value) returns (bool success) 
     {
          allowed[msg.sender][_spender] = _value;
          approval(msg.sender, _spender, _value);

          return true;
     }

     function allowance(address _owner, address _spender) constant returns (uint256 remaining) 
     {
          return allowed[_owner][_spender];
     }

     function totalsupply() constant returns (uint256 supplyout) 
     {
          supplyout = allsupply;
          return;
     }
}

contract reputationtoken is stdtoken {
     string public name = ;
     uint public decimals = 18;
     string public symbol = ;

     address public creator = 0x0;
     address public ledger = 0x0;
     mapping(address => uint256) balanceslocked;

     function reputationtoken(){
          creator = msg.sender;
          ledger = msg.sender;
     }

     function lockedof(address _owner) constant returns (uint256) 
     {
          return balanceslocked[_owner];
     }
     

     function changecreator(address newcreator){
          if(msg.sender!=creator)throw;

          creator = newcreator;
     }

     function changeledger(address newledger){
          if(msg.sender!=creator)throw;

          ledger = newledger;
     }

     function issuetokens(address foraddress, uint tokencount) returns (bool success){
          if(msg.sender!=ledger)throw;
          
          if(tokencount==0) {
               success = false;
               return ;
          }

          balances[foraddress]+=tokencount;
          allsupply+=tokencount;

          success = true;
          return;
     }

     function burntokens(address foraddress) returns (bool success){
          if(msg.sender!=ledger)throw;

          allsupply=balances[foraddress];

          balances[foraddress]=0;
          success = true;
          return;
     }

     function locktokens(address foraddress, uint tokencount) returns (bool success){
          if(msg.sender!=ledger) throw;
          if(balances[foraddress]balanceslocked[foraddress]<tokencount) throw;
          balanceslocked[foraddress]+=tokencount;
          success = true;
          return;
     }

     function unlocktokens(address foraddress, uint tokencount) returns (bool success){
          if(msg.sender!=ledger) throw;
          if(balanceslocked[foraddress]<tokencount) throw;
          balanceslocked[foraddress]=tokencount;
          success = true;
          return;
     }

     function nonlockedtokenscount(address foraddress) constant returns (uint tokencount){
          if ( balanceslocked[foraddress] > balances[foraddress] ){
               tokencount = 0;
               return;
          } else {
               tokencount = balances[foraddress]  balanceslocked[foraddress];
               return;
          }

     }

     function transferfrom(address, address, uint256) returns (bool success){
          success = false;
          return;
     }

     function transfer(address, uint256) returns (bool success){
          success = false;
          return;      
     }
}
