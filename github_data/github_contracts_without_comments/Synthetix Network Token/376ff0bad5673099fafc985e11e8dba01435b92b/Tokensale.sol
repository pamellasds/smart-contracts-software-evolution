


pragma solidity ^0.4.19



contract havvenconfig {

    string public        name               = ;
    string public        symbol             = ;
    address public       owner              = msg.sender;
    address public       fund_wallet        = 0x0;
    uint public constant max_tokens         = 150000000;
    uint public constant start_date         = 1502668800;
    uint public constant max_funding_period = 60 days;
}

library safemath {

    
    function add(uint a, uint b) internal returns (uint c) {
        c = a + b;
        assert(c >= a);
    }
    
    
    function sub(uint a, uint b) internal returns (uint c) {
        c = a  b;
        assert(c <= a);
    }
    
    
    function mul(uint a, uint b) internal returns (uint c) {
        c = a * b;
        assert(a == 0 || c / a == b);
    }
    
    
    function div(uint a, uint b) internal returns (uint c) {
        c = a / b;
        
    }

}

contract havven {

    

}
