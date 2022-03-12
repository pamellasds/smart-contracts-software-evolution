

pragma solidity 0.4.25;

import ;
import ;
import ;

contract synth is externstatetoken {

    

    feepool public feepool;
    synthetix public synthetix;

    
    bytes4 public currencykey;

    uint8 constant decimals = 18;

    

    constructor(address _proxy, tokenstate _tokenstate, synthetix _synthetix, feepool _feepool,
        string _tokenname, string _tokensymbol, address _owner, bytes4 _currencykey
    )
        externstatetoken(_proxy, _tokenstate, _tokenname, _tokensymbol, 0, decimals, _owner)
        public
    {
        require(_proxy != 0, );
        require(address(_synthetix) != 0, );
        require(address(_feepool) != 0, );
        require(_owner != 0, );
        require(_synthetix.synths(_currencykey) == synth(0), );

        feepool = _feepool;
        synthetix = _synthetix;
        currencykey = _currencykey;
    }

    

    function setsynthetix(synthetix _synthetix)
        external
        optionalproxy_onlyowner
    {
        synthetix = _synthetix;
        emitsynthetixupdated(_synthetix);
    }

    function setfeepool(feepool _feepool)
        external
        optionalproxy_onlyowner
    {
        feepool = _feepool;
        emitfeepoolupdated(_feepool);
    }

    

    
    function transfer(address to, uint value)
        public
        optionalproxy
        notfeeaddress(messagesender)
        returns (bool)
    {
        uint amountreceived = feepool.amountreceivedfromtransfer(value);
        uint fee = value.sub(amountreceived);

        
        synthetix.synthinitiatedfeepayment(messagesender, currencykey, fee);

        
        bytes memory empty;
        return _internaltransfer(messagesender, to, amountreceived, empty);
    }

    
    function transfer(address to, uint value, bytes data)
        public
        optionalproxy
        notfeeaddress(messagesender)
        returns (bool)
    {
        uint amountreceived = feepool.amountreceivedfromtransfer(value);
        uint fee = value.sub(amountreceived);

        
        synthetix.synthinitiatedfeepayment(messagesender, currencykey, fee);

        
        return _internaltransfer(messagesender, to, amountreceived, data);
    }

    
    function transferfrom(address from, address to, uint value)
        public
        optionalproxy
        notfeeaddress(from)
        returns (bool)
    {
        
        uint amountreceived = feepool.amountreceivedfromtransfer(value);
        uint fee = value.sub(amountreceived);

        
        
        tokenstate.setallowance(from, messagesender, tokenstate.allowance(from, messagesender).sub(value));

        
        synthetix.synthinitiatedfeepayment(from, currencykey, fee);

        bytes memory empty;
        return _internaltransfer(from, to, amountreceived, empty);
    }

    
    function transferfrom(address from, address to, uint value, bytes data)
        public
        optionalproxy
        notfeeaddress(from)
        returns (bool)
    {
        
        uint amountreceived = feepool.amountreceivedfromtransfer(value);
        uint fee = value.sub(amountreceived);

        
        
        tokenstate.setallowance(from, messagesender, tokenstate.allowance(from, messagesender).sub(value));

        
        synthetix.synthinitiatedfeepayment(from, currencykey, fee);

        return _internaltransfer(from, to, amountreceived, data);
    }

    
    function transfersenderpaysfee(address to, uint value)
        public
        optionalproxy
        notfeeaddress(messagesender)
        returns (bool)
    {
        uint fee = feepool.transferfeeincurred(value);

        
        synthetix.synthinitiatedfeepayment(messagesender, currencykey, fee);

        
        bytes memory empty;
        return _internaltransfer(messagesender, to, value, empty);
    }

    
    function transfersenderpaysfee(address to, uint value, bytes data)
        public
        optionalproxy
        notfeeaddress(messagesender)
        returns (bool)
    {
        uint fee = feepool.transferfeeincurred(value);

        
        synthetix.synthinitiatedfeepayment(messagesender, currencykey, fee);

        
        return _internaltransfer(messagesender, to, value, data);
    }

    
    function transferfromsenderpaysfee(address from, address to, uint value)
        public
        optionalproxy
        notfeeaddress(from)
        returns (bool)
    {
        uint fee = feepool.transferfeeincurred(value);

        
        
        tokenstate.setallowance(from, messagesender, tokenstate.allowance(from, messagesender).sub(value.add(fee)));

        
        synthetix.synthinitiatedfeepayment(from, currencykey, fee);

        bytes memory empty;
        return _internaltransfer(from, to, value, empty);
    }

    
    function transferfromsenderpaysfee(address from, address to, uint value, bytes data)
        public
        optionalproxy
        notfeeaddress(from)
        returns (bool)
    {
        uint fee = feepool.transferfeeincurred(value);

        
        
        tokenstate.setallowance(from, messagesender, tokenstate.allowance(from, messagesender).sub(value.add(fee)));

        
        synthetix.synthinitiatedfeepayment(from, currencykey, fee);

        return _internaltransfer(from, to, value, data);
    }

    
    function _internaltransfer(address from, address to, uint value, bytes data)
        internal
        returns (bool)
    {
        bytes4 preferredcurrencykey = synthetix.synthetixstate().preferredcurrency(to);

        
        if (preferredcurrencykey != 0 && preferredcurrencykey != currencykey) {
            return synthetix.synthinitiatedexchange(from, currencykey, value, preferredcurrencykey, to);
        } else {
            
            return super._internaltransfer(from, to, value, data);
        }
    }

    
    function issue(address account, uint amount)
        external
        onlysynthetixorfeepool
    {
        tokenstate.setbalanceof(account, tokenstate.balanceof(account).add(amount));
        totalsupply = totalsupply.add(amount);
        emittransfer(address(0), account, amount);
        emitissued(account, amount);
    }

    
    function burn(address account, uint amount)
        external
        onlysynthetixorfeepool
    {
        tokenstate.setbalanceof(account, tokenstate.balanceof(account).sub(amount));
        totalsupply = totalsupply.sub(amount);
        emittransfer(account, address(0), amount);
        emitburned(account, amount);
    }

    
    
    function triggertokenfallbackifneeded(address sender, address recipient, uint amount)
        external
        onlysynthetixorfeepool
    {
        bytes memory empty;
        calltokenfallbackifneeded(sender, recipient, amount, empty);
    }

    

    modifier onlysynthetixorfeepool() {
        bool issynthetix = msg.sender == address(synthetix);
        bool isfeepool = msg.sender == address(feepool);

        require(issynthetix || isfeepool, );
        _;
    }

    modifier notfeeaddress(address account) {
        require(account != feepool.fee_address(), );
        _;
    }

    

    event synthetixupdated(address newsynthetix);
    bytes32 constant synthetixupdated_sig = keccak256();
    function emitsynthetixupdated(address newsynthetix) internal {
        proxy._emit(abi.encode(newsynthetix), 1, synthetixupdated_sig, 0, 0, 0);
    }

    event feepoolupdated(address newfeepool);
    bytes32 constant feepoolupdated_sig = keccak256();
    function emitfeepoolupdated(address newfeepool) internal {
        proxy._emit(abi.encode(newfeepool), 1, feepoolupdated_sig, 0, 0, 0);
    }

    event issued(address indexed account, uint value);
    bytes32 constant issued_sig = keccak256();
    function emitissued(address account, uint value) internal {
        proxy._emit(abi.encode(value), 2, issued_sig, bytes32(account), 0, 0);
    }

    event burned(address indexed account, uint value);
    bytes32 constant burned_sig = keccak256();
    function emitburned(address account, uint value) internal {
        proxy._emit(abi.encode(value), 2, burned_sig, bytes32(account), 0, 0);
    }
}
