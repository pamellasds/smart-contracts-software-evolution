pragma solidity ^0.4.18;

import ;
import ;
import ;





contract mcopcrowdsale is pausable {
    using safemath for uint;

    
    
    uint public constant mcop_total_supply = 5000000000 ether;

    
    uint public constant lock_time =  180 days;

    uint public constant lock_stake = 48;  
    uint public constant team_stake = 8;     
    uint public constant base_stake = 4;     
    uint public constant org_stake = 15;      
    uint public constant personal_stake = 25;

    
    uint public constant stake_multiplier = mcop_total_supply / 100;


    address public lockaddress;
    address public teamaddress;
    address public baseaddress;
    address public orgaddress;
    address public personaladdress;

    mcoptoken public mcoptoken; 

    
    tokentimelock public tokentimelock; 

    
    event lockaddress(address onwer);

    modifier validaddress( address addr ) {
        require(addr != address(0x0));
        require(addr != address(this));
        _;
    }

    function mcopcrowdsale( 
        address _lockaddress,
        address _teamaddress,
        address _baseaddress,
        address _orgaddress,
        address _personaladdress

        ) public 
        validaddress(_lockaddress) 
        validaddress(_teamaddress) 
        validaddress(_baseaddress) 
        validaddress(_orgaddress) 
        validaddress(_personaladdress) 
        {

        lockaddress = _lockaddress;
        teamaddress = _teamaddress;
        baseaddress = _baseaddress;
        orgaddress = _orgaddress;
        personaladdress = _personaladdress;

        mcoptoken = new mcoptoken(this, msg.sender);

        tokentimelock = new tokentimelock(mcoptoken, lockaddress, now + lock_time);

        mcoptoken.mint(tokentimelock, lock_stake * stake_multiplier);
        mcoptoken.mint(teamaddress, team_stake * stake_multiplier);
        mcoptoken.mint(baseaddress, base_stake * stake_multiplier);
        mcoptoken.mint(orgaddress, org_stake * stake_multiplier);  
        mcoptoken.mint(personaladdress, personal_stake * stake_multiplier); 
    
    }
    
    function() external payable {
        
    }
    
    function releaselocktoken() external {
        tokentimelock.release();
    }

    
    function withdrawbalance() external {
        uint256 balance = this.balance;
        owner.transfer(balance);
    }
}