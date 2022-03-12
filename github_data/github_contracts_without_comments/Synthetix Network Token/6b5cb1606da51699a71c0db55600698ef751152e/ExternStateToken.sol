

pragma solidity 0.4.24;


import ;
import ;
import ;
import ;
import ;


contract externstatetoken is safedecimalmath, selfdestructible, proxyable, reentrancypreventer {

    

    
    tokenstate public tokenstate;

    
    string public name;
    string public symbol;
    uint public totalsupply;

    
    constructor(address _proxy, tokenstate _tokenstate,
                string _name, string _symbol, uint _totalsupply,
                address _owner)
        selfdestructible(_owner)
        proxyable(_proxy, _owner)
        public
    {
        name = _name;
        symbol = _symbol;
        totalsupply = _totalsupply;
        tokenstate = _tokenstate;
    }

    

    
    function allowance(address owner, address spender)
        public
        view
        returns (uint)
    {
        return tokenstate.allowance(owner, spender);
    }

    
    function balanceof(address account)
        public
        view
        returns (uint)
    {
        return tokenstate.balanceof(account);
    }

    

     
    function settokenstate(tokenstate _tokenstate)
        external
        optionalproxy_onlyowner
    {
        tokenstate = _tokenstate;
        emittokenstateupdated(_tokenstate);
    }

    function _internaltransfer(address from, address to, uint value) 
        internal
        preventreentrancy
        returns (bool)
    { 
        
        require(to != address(0), );
        require(to != address(this), );
        require(to != address(proxy), );

        
        tokenstate.setbalanceof(from, safesub(tokenstate.balanceof(from), value));
        tokenstate.setbalanceof(to, safeadd(tokenstate.balanceof(to), value));

        

        
        uint length;

        
        assembly {
            
            length := extcodesize(to)
        }

        
        if (length > 0) {
            
            
            
            

            
            to.call(0xcbff5d96, messagesender, value);

            
        }

        
        emittransfer(from, to, value);

        return true;
    }

    
    function _transfer_byproxy(address from, address to, uint value)
        internal
        returns (bool)
    {
        return _internaltransfer(from, to, value);
    }

    
    function _transferfrom_byproxy(address sender, address from, address to, uint value)
        internal
        returns (bool)
    {
        
        tokenstate.setallowance(from, sender, safesub(tokenstate.allowance(from, sender), value));
        return _internaltransfer(from, to, value);
    }

    
    function approve(address spender, uint value)
        public
        optionalproxy
        returns (bool)
    {
        address sender = messagesender;

        tokenstate.setallowance(sender, spender, value);
        emitapproval(sender, spender, value);
        return true;
    }

    

    event transfer(address indexed from, address indexed to, uint value);
    bytes32 constant transfer_sig = keccak256();
    function emittransfer(address from, address to, uint value) internal {
        proxy._emit(abi.encode(value), 3, transfer_sig, bytes32(from), bytes32(to), 0);
    }

    event approval(address indexed owner, address indexed spender, uint value);
    bytes32 constant approval_sig = keccak256();
    function emitapproval(address owner, address spender, uint value) internal {
        proxy._emit(abi.encode(value), 3, approval_sig, bytes32(owner), bytes32(spender), 0);
    }

    event tokenstateupdated(address newtokenstate);
    bytes32 constant tokenstateupdated_sig = keccak256();
    function emittokenstateupdated(address newtokenstate) internal {
        proxy._emit(abi.encode(newtokenstate), 1, tokenstateupdated_sig, 0, 0, 0);
    }
}
