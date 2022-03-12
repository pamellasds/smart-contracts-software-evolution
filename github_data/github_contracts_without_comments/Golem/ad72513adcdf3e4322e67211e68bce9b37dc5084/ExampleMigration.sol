pragma solidity ^0.4.1;

import * as source from ;

contract gnttargettoken {

    address migrationagent;

    
    uint256 totaltokens;
    mapping (address => uint256) balances;

    
    event transfer(address indexed _from, address indexed _to, uint256 _value);

    function gnttargettoken(address _migrationagent) {
        migrationagent = _migrationagent;
        
    }

    
    function createtoken(address _target, uint256 _amount) {
        if (msg.sender != migrationagent) throw;

        balances[_target] += _amount;
        totaltokens += _amount;

        transfer(migrationagent, _target, _amount);
    }

    function finalizemigration() {
        if (msg.sender != migrationagent) throw;

        migrationagent = 0;
    }

    
    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] = _value;
            balances[_to] += _value;
            transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }

    function totalsupply() constant returns (uint256) {
        return totaltokens;
    }

    function balanceof(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
}


contract migrationagent {

    address owner;
    address gntsourcetoken;
    address gnttargettoken;

    uint256 tokensupply;

    function migrationagent(address _gntsourcetoken) {
        owner = msg.sender;
        gntsourcetoken = _gntsourcetoken;

        tokensupply = source.golemnetworktoken(gntsourcetoken).totalsupply();
    }

    function safetyinvariantcheck(uint256 _value) private {
        if (gnttargettoken == 0) throw;
        if (source.golemnetworktoken(gntsourcetoken).totalsupply() + gnttargettoken(gnttargettoken).totalsupply() != tokensupply  _value) throw;
    }

    function settargettoken(address _gnttargettoken) {
        if (msg.sender != owner) throw;
        if (gnttargettoken != 0) throw; 

        gnttargettoken = _gnttargettoken;
    }

    
    function migratefrom(address _from, uint256 _value) {
        if (msg.sender != gntsourcetoken) throw;
        if (gnttargettoken == 0) throw;

        
        safetyinvariantcheck(_value);

        gnttargettoken(gnttargettoken).createtoken(_from, _value);

        
        safetyinvariantcheck(0);
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
