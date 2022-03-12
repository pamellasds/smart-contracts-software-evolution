pragma solidity ^0.4.15;

import ;
import ;
import ;


contract customtokens {
    using safemath for uint256;

    
    uint256 multiplier = 10000;
    erc20 enjincoin;
    uint256 index = 0;
    struct tokens {
        address creator;
        uint256 totalsupply;
        uint256 exchangerate;
        uint8 decimals;
        string name;
        string icon;
        string data;
        mapping (address => uint256) balances;
    }

    
    mapping (uint256 => tokens) types;

    
    function() { revert(); }

    
    function customtokens(address _enjincointoken) {
        enjincoin = erc20(_enjincointoken);
    }

    
    function checktokencreator(uint256 _customtokenid) {
        require(msg.sender == types[_customtokenid].creator);
    }

    
    function balanceof(uint256 _customtokenid, address _owner) constant returns (uint256) {
        return types[_customtokenid].balances[_owner];
    }

    
    function transfer(uint256 _customtokenid, address _to, uint256 _value, bytes _data) {
        uint256 codelength;

        assembly {
        
        codelength := extcodesize(_to)
        }

        types[_customtokenid].balances[msg.sender] = types[_customtokenid].balances[msg.sender].sub(_value);
        types[_customtokenid].balances[_to] = types[_customtokenid].balances[_to].add(_value);
        if(codelength>0) {
            enjinreceivingcontract receiver = enjinreceivingcontract(_to);
            receiver.tokenfallback(msg.sender, _value, _data);
        }
        transfer(_customtokenid, msg.sender, _to, _value, _data);
    }

    
    function transfer(uint256 _customtokenid, address _to, uint256 _value) {
        uint256 codelength;

        assembly {
        
        codelength := extcodesize(_to)
        }

        types[_customtokenid].balances[msg.sender] = types[_customtokenid].balances[msg.sender].sub(_value);
        types[_customtokenid].balances[_to] = types[_customtokenid].balances[_to].add(_value);

        bytes memory empty; 
        if(codelength>0) {
            enjinreceivingcontract receiver = enjinreceivingcontract(_to);
            receiver.tokenfallback(msg.sender, _value, empty);
        }
        transfer(_customtokenid, msg.sender, _to, _value, empty);
    }

    
    function transferinternal(uint256 _customtokenid, address _from, address _to, uint256 _value) private {
        require(_to != address(0));

        types[_customtokenid].balances[_from] = types[_customtokenid].balances[_from].sub(_value);
        types[_customtokenid].balances[_to] = types[_customtokenid].balances[_to].add(_value);
    }

    
    function createtoken(uint256 _totalsupply, uint256 _exchangerate, uint8 _decimals, string _name, string _icon, string _customdata)
    returns (uint256) {
        require(_totalsupply > 0);

        
        
        
        

        
        uint256 totalcost = _exchangerate / multiplier * _totalsupply;
        require(enjincoin.allowance(msg.sender, this) >= totalcost);

        
        enjincoin.transferfrom(msg.sender, this, totalcost);

        
        index++;

        types[index] = tokens(
            msg.sender,
            _totalsupply,
            _exchangerate,
            _decimals,
            _name,
            _icon,
            _customdata
        );

        
        types[index].balances[msg.sender] = _totalsupply;

        
        create(index, msg.sender);

        return index;
    }

    
    function liquidatetoken(uint256 _customtokenid, uint256 _value) {
        
        require(types[_customtokenid].balances[msg.sender] >= _value);

        transferinternal(_customtokenid, msg.sender, this, _value);
        enjincoin.transferfrom(this, msg.sender, types[_customtokenid].exchangerate / multiplier * _value); 
        liquidate(_customtokenid, msg.sender, _value);
    }

    
    function minttoken(uint256 _customtokenid, uint256 _value) {
        checktokencreator(_customtokenid);

        
        require(types[_customtokenid].balances[this] <= _value);

        
        uint256 totalcost = types[_customtokenid].exchangerate / multiplier * _value;
        require(enjincoin.allowance(msg.sender, this) >= totalcost);

        
        enjincoin.transferfrom(msg.sender, this, totalcost);

        
        transferinternal(_customtokenid, this, msg.sender, _value);

        
        mint(_customtokenid, _value);
    }

    
    function deletetoken(uint256 _customtokenid) {
        checktokencreator(_customtokenid);

        
        require(types[_customtokenid].balances[this] == types[_customtokenid].totalsupply);

        delete types[_customtokenid];

        delete(_customtokenid, msg.sender);
    }

    
    function updateparams(uint256 _customtokenid, string _name, string _icon, string _customdata) {
        checktokencreator(_customtokenid);

        types[_customtokenid].name = _name;
        types[_customtokenid].icon = _icon;
        types[_customtokenid].data = _customdata;

        update(_customtokenid, _name, _icon, _customdata);
    }

    
    function getparams(uint256 _customtokenid) constant returns (address creator, uint256 totalsupply, uint256 exchangerate, uint8 decimals, string name, string icon, string data) {
        creator = types[_customtokenid].creator;
        totalsupply = types[_customtokenid].totalsupply;
        exchangerate = types[_customtokenid].exchangerate;
        decimals = types[_customtokenid].decimals;
        name = types[_customtokenid].name;
        icon = types[_customtokenid].icon;
        data = types[_customtokenid ].data;
    }

    
    function assign(uint256 _customtokenid, address _creator) {
        checktokencreator(_customtokenid);
        if (_creator != address(0)) {
            types[_customtokenid].creator = _creator;
        }

        assign(_customtokenid, msg.sender, _creator);
    }

    
    event create(uint256 indexed _customtokenid, address indexed _creator);
    event liquidate(uint256 indexed _customtokenid, address indexed _owner, uint256 _value);
    event mint(uint256 indexed _customtokenid, uint256 _value);
    event delete(uint256 indexed _customtokenid, address indexed _creator);
    event update(uint256 indexed _customtokenid, string _name, string _icon, string _customdata);
    event transfer(uint256 indexed _customtokenid, address indexed _from, address indexed _to, uint256 _value, bytes _data);
    event assign(uint256 indexed _customtokenid, address indexed _from, address indexed _to);
}
