

pragma solidity 0.4.24;

import ;
import ;


contract newrequestvoting {
    using safemath for uint256;

    

    
    powerledger public powerledger;

    
    mapping ( address => string ) public requests;

    
    mapping ( address => vote[] ) public votes;

    
    mapping ( string => uint256 ) totalvotes;

    
    struct vote {
        string requestname;
        bool votetype;
        bool hasvoted;
        uint256 vote;        
    }
    
    
    
    
    modifier ispowrholder() {
        require(powerledger.balanceof(msg.sender) > 0);
        _;
    }

    
    modifier isvalidvoter(string _requestname) {
        
        
        require( !(comparestring(requests[msg.sender],_requestname)), );

        
        for ( uint i = 0 ; i < votes[msg.sender].length ; i++ ) {
            if( comparestring(votes[msg.sender][i].requestname, _requestname) ) {
                require( !(votes[msg.sender][i].hasvoted) );
            }   
        }
        _;
    }

    
     
    
    constructor(powerledger _powerledger) public {
        powerledger = _powerledger;
    }

    
     
    
    function newfunctionalityrequest(string _requestname)
        ispowrholder public returns (bool) {

            
            require(bytes(_requestname).length > 0);

            
            require( totalvotes[_requestname] == 0 );
            
            requests[msg.sender] = _requestname;

            return true;
    }
    
    
    function voteforrequest(string _requestname, bool _isupvote)
        ispowrholder
        isvalidvoter(_requestname)
        public returns (bool) {

            vote memory newvote;

            
            newvote.requestname = _requestname;
            newvote.vote = powerledger.balanceof(msg.sender);
            newvote.votetype = _isupvote;
            newvote.hasvoted = true;

            
            votes[msg.sender].push(newvote);
            
            if ( _isupvote ) {
                totalvotes[_requestname] += newvote.vote;
                return true;
            }
            else if ( !_isupvote ) {
                totalvotes[_requestname] = newvote.vote;
                return true;
            }
            return false;
    }
    
    
    function gettotalvotes(string _requestname)
        public view returns (uint256) {            
            return totalvotes[_requestname];
    }

    
    function comparestring(string a, string b) pure internal returns (bool) {
        if(bytes(a).length != bytes(b).length) {
            return false;
        } else {
            return keccak256(bytes(a)) == keccak256(bytes(b));
        }
    }
}