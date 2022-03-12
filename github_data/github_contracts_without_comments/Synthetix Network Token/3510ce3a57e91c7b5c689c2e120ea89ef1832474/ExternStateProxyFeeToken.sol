

pragma solidity ^0.4.21;


import ;
import ;
import ;
import ;



contract externstateproxyfeetoken is proxyable, safedecimalmath {

    

    
    tokenstate public state;

    
    string public name;
    string public symbol;
    uint public totalsupply;

    
    uint public transferfeerate;
    
    uint constant max_transfer_fee_rate = unit / 10;
    
    address public feeauthority;


    

    
    function externstateproxyfeetoken(string _name, string _symbol,
                                      uint _transferfeerate, address _feeauthority,
                                      tokenstate _state, address _owner)
        proxyable(_owner)
        public
    {
        if (_state == tokenstate(0)) {
            state = new tokenstate(_owner, address(this));
        } else {
            state = _state;
        }

        name = _name;
        symbol = _symbol;
        feeauthority = _feeauthority;

        
        require(_transferfeerate <= max_transfer_fee_rate);
        transferfeerate = _transferfeerate;
    }

    

    function settransferfeerate(uint _transferfeerate)
        external
        optionalproxy_onlyowner
    {
        require(_transferfeerate <= max_transfer_fee_rate);
        transferfeerate = _transferfeerate;
        emit transferfeerateupdated(_transferfeerate);
    }

    function setfeeauthority(address _feeauthority)
        external
        optionalproxy_onlyowner
    {
        feeauthority = _feeauthority;
        emit feeauthorityupdated(_feeauthority);
    }

    function setstate(tokenstate _state)
        external
        optionalproxy_onlyowner
    {
        state = _state;
        emit stateupdated(_state);
    }

    

    function balanceof(address account)
        public
        view
        returns (uint)
    {
        return state.balanceof(account);
    }

    function allowance(address from, address to)
        public
        view
        returns (uint)
    {
        return state.allowance(from, to);
    }

    
    function transferfeeincurred(uint value)
        public
        view
        returns (uint)
    {
        return safemul_dec(value, transferfeerate);
        
    }

    
    
    function transferplusfee(uint value)
        external
        view
        returns (uint)
    {
        return safeadd(value, transferfeeincurred(value));
    }

    
    function pricetospend(uint value)
        external
        view
        returns (uint)
    {
        return safediv_dec(value, safeadd(unit, transferfeerate));
    }

    
    
    function feepool()
        external
        view
        returns (uint)
    {
        return state.balanceof(address(this));
    }


    

    
    function _transfer_byproxy(address sender, address to, uint value)
        internal
        returns (bool)
    {
        require(to != address(0));

        
        
        uint fee = transferfeeincurred(value);
        uint totalcharge = safeadd(value, fee);

        
        state.setbalanceof(sender, safesub(state.balanceof(sender), totalcharge));
        state.setbalanceof(to, safeadd(state.balanceof(to), value));
        state.setbalanceof(address(this), safeadd(state.balanceof(address(this)), fee));

        emit transfer(sender, to, value);
        emit transferfeepaid(sender, fee);
        emit transfer(sender, address(this), fee);

        return true;
    }

    
    function _transferfrom_byproxy(address sender, address from, address to, uint value)
        internal
        returns (bool)
    {
        require(to != address(0));

        
        
        uint fee = transferfeeincurred(value);
        uint totalcharge = safeadd(value, fee);

        
        state.setbalanceof(from, safesub(state.balanceof(from), totalcharge));
        state.setallowance(from, sender, safesub(state.allowance(from, sender), totalcharge));
        state.setbalanceof(to, safeadd(state.balanceof(to), value));
        state.setbalanceof(address(this), safeadd(state.balanceof(address(this)), fee));

        emit transfer(from, to, value);
        emit transferfeepaid(from, fee);
        emit transfer(from, address(this), fee);

        return true;
    }

    function approve(address spender, uint value)
        external
        optionalproxy
        returns (bool)
    {
        address sender = messagesender;
        state.setallowance(sender, spender, value);

        emit approval(sender, spender, value);

        return true;
    }

    
    function withdrawfee(address account, uint value)
        external
        returns (bool)
    {
        require(msg.sender == feeauthority && account != address(0));
        
        
        if (value == 0) {
            return false;
        }

        
        state.setbalanceof(address(this), safesub(state.balanceof(address(this)), value));
        state.setbalanceof(account, safeadd(state.balanceof(account), value));

        emit feeswithdrawn(account, account, value);
        emit transfer(address(this), account, value);

        return true;
    }

    
    function donatetofeepool(uint n)
        external
        optionalproxy
        returns (bool)
    {
        address sender = messagesender;

        
        uint balance = state.balanceof(sender);
        require(balance != 0);

        
        state.setbalanceof(sender, safesub(balance, n));
        state.setbalanceof(address(this), safeadd(state.balanceof(address(this)), n));

        emit feesdonated(sender, sender, n);
        emit transfer(sender, address(this), n);

        return true;
    }

    

    event transfer(address indexed from, address indexed to, uint value);

    event transferfeepaid(address indexed account, uint value);

    event approval(address indexed owner, address indexed spender, uint value);

    event transferfeerateupdated(uint newfeerate);

    event feeauthorityupdated(address feeauthority);

    event stateupdated(address newstate);

    event feeswithdrawn(address account, address indexed accountindex, uint value);

    event feesdonated(address donor, address indexed donorindex, uint value);
}
