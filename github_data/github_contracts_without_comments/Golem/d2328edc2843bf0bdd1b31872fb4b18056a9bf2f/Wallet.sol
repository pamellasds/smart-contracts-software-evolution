pragma solidity ^0.4.4;











contract multiowned {

    

    
    struct pendingstate {
        uint yetneeded;
        uint ownersdone;
        uint index;
    }

    

    
    
    event confirmation(address owner, bytes32 operation);
    event revoke(address owner, bytes32 operation);
    
    event ownerchanged(address oldowner, address newowner);
    event owneradded(address newowner);
    event ownerremoved(address oldowner);
    
    event requirementchanged(uint newrequirement);

    

    
    modifier onlyowner {
        if (isowner(msg.sender))
            _;
    }
    
    
    
    modifier onlymanyowners(bytes32 _operation) {
        if (confirmandcheck(_operation))
            _;
    }

    

    
    
    function multiowned(address[] _owners, uint _required) {
        m_numowners = _owners.length + 1;
        m_owners[1] = uint(msg.sender);
        m_ownerindex[uint(msg.sender)] = 1;
        for (uint i = 0; i < _owners.length; ++i)
        {
            m_owners[2 + i] = uint(_owners[i]);
            m_ownerindex[uint(_owners[i])] = 2 + i;
        }
        m_required = _required;
    }
    
    
    function revoke(bytes32 _operation) external {
        uint ownerindex = m_ownerindex[uint(msg.sender)];
        
        if (ownerindex == 0) return;
        uint ownerindexbit = 2**ownerindex;
        var pending = m_pending[_operation];
        if (pending.ownersdone & ownerindexbit > 0) {
            pending.yetneeded++;
            pending.ownersdone = ownerindexbit;
            revoke(msg.sender, _operation);
        }
    }
    
    
    function changeowner(address _from, address _to) onlymanyowners(sha3(msg.data, block.number)) external {
        if (isowner(_to)) return;
        uint ownerindex = m_ownerindex[uint(_from)];
        if (ownerindex == 0) return;

        clearpending();
        m_owners[ownerindex] = uint(_to);
        m_ownerindex[uint(_from)] = 0;
        m_ownerindex[uint(_to)] = ownerindex;
        ownerchanged(_from, _to);
    }
    
    function addowner(address _owner) onlymanyowners(sha3(msg.data, block.number)) external {
        if (isowner(_owner)) return;

        clearpending();
        if (m_numowners >= c_maxowners)
            reorganizeowners();
        if (m_numowners >= c_maxowners)
            return;
        m_numowners++;
        m_owners[m_numowners] = uint(_owner);
        m_ownerindex[uint(_owner)] = m_numowners;
        owneradded(_owner);
    }
    
    function removeowner(address _owner) onlymanyowners(sha3(msg.data, block.number)) external {
        uint ownerindex = m_ownerindex[uint(_owner)];
        if (ownerindex == 0) return;
        if (m_required > m_numowners  1) return;

        m_owners[ownerindex] = 0;
        m_ownerindex[uint(_owner)] = 0;
        clearpending();
        reorganizeowners(); 
        ownerremoved(_owner);
    }
    
    function changerequirement(uint _newrequired) onlymanyowners(sha3(msg.data, block.number)) external {
        if (_newrequired > m_numowners) return;
        m_required = _newrequired;
        clearpending();
        requirementchanged(_newrequired);
    }
    
    function isowner(address _addr) returns (bool) {
        return m_ownerindex[uint(_addr)] > 0;
    }
    
    function hasconfirmed(bytes32 _operation, address _owner) constant returns (bool) {
        var pending = m_pending[_operation];
        uint ownerindex = m_ownerindex[uint(_owner)];

        
        if (ownerindex == 0) return false;

        
        uint ownerindexbit = 2**ownerindex;
        if (pending.ownersdone & ownerindexbit == 0) {
            return false;
        } else {
            return true;
        }
    }
    
    

    function confirmandcheck(bytes32 _operation) internal returns (bool) {
        
        uint ownerindex = m_ownerindex[uint(msg.sender)];
        
        if (ownerindex == 0) return;

        var pending = m_pending[_operation];
        
        if (pending.yetneeded == 0) {
            
            pending.yetneeded = m_required;
            
            pending.ownersdone = 0;
            pending.index = m_pendingindex.length++;
            m_pendingindex[pending.index] = _operation;
        }
        
        uint ownerindexbit = 2**ownerindex;
        
        if (pending.ownersdone & ownerindexbit == 0) {
            confirmation(msg.sender, _operation);
            
            if (pending.yetneeded <= 1) {
                
                delete m_pendingindex[m_pending[_operation].index];
                delete m_pending[_operation];
                return true;
            }
            else
            {
                
                pending.yetneeded;
                pending.ownersdone |= ownerindexbit;
            }
        }
    }

    function reorganizeowners() private returns (bool) {
        uint free = 1;
        while (free < m_numowners)
        {
            while (free < m_numowners && m_owners[free] != 0) free++;
            while (m_numowners > 1 && m_owners[m_numowners] == 0) m_numowners;
            if (free < m_numowners && m_owners[m_numowners] != 0 && m_owners[free] == 0)
            {
                m_owners[free] = m_owners[m_numowners];
                m_ownerindex[m_owners[free]] = free;
                m_owners[m_numowners] = 0;
            }
        }
    }
    
    function clearpending() internal {
        uint length = m_pendingindex.length;
        for (uint i = 0; i < length; ++i)
            if (m_pendingindex[i] != 0)
                delete m_pending[m_pendingindex[i]];
        delete m_pendingindex;
    }
        
    

    
    uint public m_required;
    
    uint public m_numowners;
    
    
    uint[256] m_owners;
    uint constant c_maxowners = 250;
    
    mapping(uint => uint) m_ownerindex;
    
    mapping(bytes32 => pendingstate) m_pending;
    bytes32[] m_pendingindex;
}




contract daylimit is multiowned {

    

    
    modifier limiteddaily(uint _value) {
        if (underlimit(_value))
            _;
    }

    

    
    function daylimit(uint _limit) {
        m_dailylimit = _limit;
        m_lastday = today();
    }
    
    function setdailylimit(uint _newlimit) onlymanyowners(sha3(msg.data, block.number)) external {
        m_dailylimit = _newlimit;
    }
    
    function resetspenttoday() onlymanyowners(sha3(msg.data, block.number)) external {
        m_spenttoday = 0;
    }
    
    
    
    
    
    function underlimit(uint _value) internal onlyowner returns (bool) {
        
        if (today() > m_lastday) {
            m_spenttoday = 0;
            m_lastday = today();
        }
        
        if (m_spenttoday + _value >= m_spenttoday && m_spenttoday + _value <= m_dailylimit) {
            m_spenttoday += _value;
            return true;
        }
        return false;
    }
    
    function today() private constant returns (uint) { return now / 1 days; }

    

    uint public m_dailylimit;
    uint public m_spenttoday;
    uint public m_lastday;
}


contract multisig {

    

    
    
    event deposit(address from, uint value);
    
    event singletransact(address owner, uint value, address to, bytes data);
    
    event multitransact(address owner, bytes32 operation, uint value, address to, bytes data);
    
    event confirmationneeded(bytes32 operation, address initiator, uint value, address to, bytes data);
    
    
    
    
    function changeowner(address _from, address _to) external;
    function execute(address _to, uint _value, bytes _data) external returns (bytes32);
    function confirm(bytes32 _h) returns (bool);
}




contract wallet is multisig, multiowned, daylimit {

    uint public version = 2;

    

    
    struct transaction {
        address to;
        uint value;
        bytes data;
    }

    

    
    
    function wallet(address[] _owners, uint _required, uint _daylimit)
            multiowned(_owners, _required) daylimit(_daylimit) {
    }
    
    
    function kill(address _to) onlymanyowners(sha3(msg.data, block.number)) external {
        suicide(_to);
    }
    
    
    function() payable {
        
        if (msg.value > 0)
            deposit(msg.sender, msg.value);
    }
    
    
    
    
    
    function execute(address _to, uint _value, bytes _data) external onlyowner returns (bytes32 _r) {
        
        if (underlimit(_value)) {
            
            
            _to.call.value(_value)(_data);
            return 0;
        }
        
        _r = sha3(msg.data, block.number);
        if (!confirm(_r) && m_txs[_r].to == 0) {
            m_txs[_r].to = _to;
            m_txs[_r].value = _value;
            m_txs[_r].data = _data;
            confirmationneeded(_r, msg.sender, _value, _to, _data);
        }
    }
    
    
    
    function confirm(bytes32 _h) onlymanyowners(_h) returns (bool) {
        if (m_txs[_h].to != 0) {
            m_txs[_h].to.call.value(m_txs[_h].value)(m_txs[_h].data);
            multitransact(msg.sender, _h, m_txs[_h].value, m_txs[_h].to, m_txs[_h].data);
            delete m_txs[_h];
            return true;
        }
    }
    
    
    
    function clearpending() internal {
        uint length = m_pendingindex.length;
        for (uint i = 0; i < length; ++i)
            delete m_txs[m_pendingindex[i]];
        super.clearpending();
    }

    

    
    mapping (bytes32 => transaction) m_txs;
}
