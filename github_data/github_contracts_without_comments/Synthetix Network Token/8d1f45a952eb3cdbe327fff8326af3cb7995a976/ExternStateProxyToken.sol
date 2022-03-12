

pragma solidity ^0.4.20;


import ;
import ;
import ;
import ;


contract externstateproxytoken is safedecimalmath, proxyable {

    

    
    tokenstate public state;

    
    string public name;
    string public symbol;
    uint public totalsupply;


    

    function externstateproxytoken(string _name, string _symbol,
                                   uint initialsupply, address initialbeneficiary,
                                   tokenstate _state, address _owner)
        proxyable(_owner)
        public
    {
        name = _name;
        symbol = _symbol;
        totalsupply = initialsupply;

        
        if (_state == tokenstate(0)) {
            state = new tokenstate(_owner, address(this));
            state.setbalanceof(initialbeneficiary, totalsupply);
            transfer(address(0), initialbeneficiary, initialsupply);
        } else {
            state = _state;
        }
   }

    

    function allowance(address tokenowner, address spender)
        public
        view
        returns (uint)
    {
        return state.allowance(tokenowner, spender);
    }

    function balanceof(address account)
        public
        view
        returns (uint)
    {
        return state.balanceof(account);
    }

    

    function setstate(tokenstate _state)
        external
        onlyowner
    {
        state = _state;
    } 

    
    function _transfer_byproxy(address sender, address to, uint value)
        internal
        returns (bool)
    {
        require(to != address(0));

        
        state.setbalanceof(sender, safesub(state.balanceof(sender), value));
        state.setbalanceof(to, safeadd(state.balanceof(to), value));

        transfer(sender, to, value);

        return true;
    }

    
    function _transferfrom_byproxy(address sender, address from, address to, uint value)
        internal
        returns (bool)
    {
        require(from != address(0) && to != address(0));

        
        state.setbalanceof(from, safesub(state.balanceof(from), value));
        state.setallowance(from, sender, safesub(state.allowance(from, sender), value));
        state.setbalanceof(to, safeadd(state.balanceof(to), value));

        transfer(from, to, value);

        return true;
    }

    function approve(address spender, uint value)
        external
        optionalproxy
        returns (bool)
    {
        address sender = messagesender;
        state.setallowance(sender, spender, value);
        approval(sender, spender, value);
        return true;
    }

    

    event transfer(address indexed from, address indexed to, uint value);

    event approval(address indexed owner, address indexed spender, uint value);
}
