

pragma solidity 0.4.25;

import ;
import ;
import ;
import ;

contract synth is externstatetoken {

    

    
    address public feepoolproxy;
    
    address public synthetixproxy;

    
    bytes32 public currencykey;

    uint8 constant decimals = 18;

    

    constructor(address _proxy, tokenstate _tokenstate, address _synthetixproxy, address _feepoolproxy,
        string _tokenname, string _tokensymbol, address _owner, bytes32 _currencykey, uint _totalsupply
    )
        externstatetoken(_proxy, _tokenstate, _tokenname, _tokensymbol, _totalsupply, decimals, _owner)
        public
    {
        require(_proxy != address(0), );
        require(_synthetixproxy != address(0), );
        require(_feepoolproxy != address(0), );
        require(_owner != 0, );
        require(isynthetix(_synthetixproxy).synths(_currencykey) == synth(0), );

        feepoolproxy = _feepoolproxy;
        synthetixproxy = _synthetixproxy;
        currencykey = _currencykey;
    }

    

    
    function setsynthetixproxy(isynthetix _synthetixproxy)
        external
        optionalproxy_onlyowner
    {
        synthetixproxy = _synthetixproxy;
        emitsynthetixupdated(_synthetixproxy);
    }

    
    function setfeepoolproxy(address _feepoolproxy)
        external
        optionalproxy_onlyowner
    {
        feepoolproxy = _feepoolproxy;
        emitfeepoolupdated(_feepoolproxy);
    }

    

    
    function transfer(address to, uint value)
        public
        optionalproxy
        returns (bool)
    {        
        return super._internaltransfer(messagesender, to, value);
    }

    
    function transferfrom(address from, address to, uint value)
        public
        optionalproxy
        returns (bool)
    {        
        
        if (tokenstate.allowance(from, messagesender) != uint(1)) {
            
            
            tokenstate.setallowance(from, messagesender, tokenstate.allowance(from, messagesender).sub(value));
        }
        
        return super._internaltransfer(from, to, value);
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

    
    function settotalsupply(uint amount)
        external
        optionalproxy_onlyowner
    {
        totalsupply = amount;
    }

    

    modifier onlysynthetixorfeepool() {
        bool issynthetix = msg.sender == address(proxy(synthetixproxy).target());
        bool isfeepool = msg.sender == address(proxy(feepoolproxy).target());

        require(issynthetix || isfeepool, );
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
