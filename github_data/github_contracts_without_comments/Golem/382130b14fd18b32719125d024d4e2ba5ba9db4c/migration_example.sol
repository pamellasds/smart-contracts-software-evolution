pragma solidity ^0.4.1;

contract gnttargettoken {

    address migrationagent;

    
    uint256 totalsupply;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    
    event transfer(address indexed _from, address indexed _to, uint256 _value);
    event approval(address indexed _owner, address indexed _spender, uint256 _value);

    function gnttargettoken(address _migrationagent) {
        migrationagent = _migrationagent;
        
    }

    
    function createtoken(address _target, uint256 _amount) {
        if (msg.sender != migrationagent) throw;

        balances[_target] += _amount;
        totalsupply += _amount;

        transfer(migrationagent, _target, _amount);
    }

    function finalizemigration() {
        if (msg.sender != migrationagent) throw;

        migrationagent = 0;
    }

    
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferfrom(address _from, address _to, uint256 _value);
    function totalsupply() constant returns (uint256);
    function balanceof(address _owner) constant returns (uint256 balance);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

}


contract migrationagent {

    address owner;
    address gntsourcetoken;
    address gnttargettoken;
    
    uint256 tokensupply;
    
    function migrationagent(address _gntsourcetoken) {
        owner = msg.sender;
        gntsourcetoken = _gntsourcetoken;
         
        tokensupply = golemnetworktoken(gntsourcetoken).totalsupply();
    }

    function safetyinvariantcheck(uint256 _value) private {
        if (gnttargettoken == 0) throw;
        if (golemnetworktoken(gntsourcetoken).totalsupply() + gnttargettoken(gnttargettoken).totalsupply() != tokensupply  _value) throw;
    }
    
    function settargettoken(address _gnttargettoken) {
        if (msg.sender != owner) throw;
        if (gnttargettoken != 0) throw; 
        
        gnttargettoken = _gnttargettoken;
    }
    
    
    function migratefrom(address _from, uint256 _value) {
        if (msg.sender != gntsourcetoken) throw;
        if (gnttargettoken == 0) throw;

        
        safetinvariantcheck(_value);

        gnttargettoken(gnttargettoken).createtoken(_from, _value);
    
        
        safetinvariantcheck(0);
    }

    function finalizemigration() {
        if (msg.sender != owner) throw;
        
        safetyinvariantcheck(0);
        
        
        
        
        gnttargettoken(gnttargettoken).finalizemigration();

        gntsourcetoken = 0;
        gnttargettoken = 0;
 
        tokensupply = 0;
    }

}
