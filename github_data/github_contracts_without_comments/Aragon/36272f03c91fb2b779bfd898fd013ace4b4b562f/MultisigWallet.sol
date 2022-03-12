pragma solidity 0.4.8;




contract multisigwallet {

    uint constant public max_owner_count = 50;

    event confirmation(address indexed sender, uint indexed transactionid);
    event revocation(address indexed sender, uint indexed transactionid);
    event submission(uint indexed transactionid);
    event execution(uint indexed transactionid);
    event executionfailure(uint indexed transactionid);
    event deposit(address indexed sender, uint value);
    event owneraddition(address indexed owner);
    event ownerremoval(address indexed owner);
    event requirementchange(uint required);

    mapping (uint => transaction) public transactions;
    mapping (uint => mapping (address => bool)) public confirmations;
    mapping (address => bool) public isowner;
    address[] public owners;
    uint public required;
    uint public transactioncount;

    struct transaction {
        address destination;
        uint value;
        bytes data;
        bool executed;
    }

    modifier onlywallet() {
        if (msg.sender != address(this))
            throw;
        _;
    }

    modifier ownerdoesnotexist(address owner) {
        if (isowner[owner])
            throw;
        _;
    }

    modifier ownerexists(address owner) {
        if (!isowner[owner])
            throw;
        _;
    }

    modifier transactionexists(uint transactionid) {
        if (transactions[transactionid].destination == 0)
            throw;
        _;
    }

    modifier confirmed(uint transactionid, address owner) {
        if (!confirmations[transactionid][owner])
            throw;
        _;
    }

    modifier notconfirmed(uint transactionid, address owner) {
        if (confirmations[transactionid][owner])
            throw;
        _;
    }

    modifier notexecuted(uint transactionid) {
        if (transactions[transactionid].executed)
            throw;
        _;
    }

    modifier notnull(address _address) {
        if (_address == 0)
            throw;
        _;
    }

    modifier validrequirement(uint ownercount, uint _required) {
        if (   ownercount > max_owner_count
            || _required > ownercount
            || _required == 0
            || ownercount == 0)
            throw;
        _;
    }

    
    function()
        payable
    {
        if (msg.value > 0)
            deposit(msg.sender, msg.value);
    }

    
    
    
    
    function multisigwallet(address[] _owners, uint _required)
        public
        validrequirement(_owners.length, _required)
    {
        for (uint i=0; i<_owners.length; i++) {
            if (isowner[_owners[i]] || _owners[i] == 0)
                throw;
            isowner[_owners[i]] = true;
        }
        owners = _owners;
        required = _required;
    }

    
    
    function addowner(address owner)
        public
        onlywallet
        ownerdoesnotexist(owner)
        notnull(owner)
        validrequirement(owners.length + 1, required)
    {
        isowner[owner] = true;
        owners.push(owner);
        owneraddition(owner);
    }

    
    
    function removeowner(address owner)
        public
        onlywallet
        ownerexists(owner)
    {
        isowner[owner] = false;
        for (uint i=0; i<owners.length  1; i++)
            if (owners[i] == owner) {
                owners[i] = owners[owners.length  1];
                break;
            }
        owners.length = 1;
        if (required > owners.length)
            changerequirement(owners.length);
        ownerremoval(owner);
    }

    
    
    
    function replaceowner(address owner, address newowner)
        public
        onlywallet
        ownerexists(owner)
        ownerdoesnotexist(newowner)
    {
        for (uint i=0; i<owners.length; i++)
            if (owners[i] == owner) {
                owners[i] = newowner;
                break;
            }
        isowner[owner] = false;
        isowner[newowner] = true;
        ownerremoval(owner);
        owneraddition(newowner);
    }

    
    
    function changerequirement(uint _required)
        public
        onlywallet
        validrequirement(owners.length, _required)
    {
        required = _required;
        requirementchange(_required);
    }

    
    
    
    
    
    function submittransaction(address destination, uint value, bytes data)
        public
        returns (uint transactionid)
    {
        transactionid = addtransaction(destination, value, data);
        confirmtransaction(transactionid);
    }

    
    
    function confirmtransaction(uint transactionid)
        public
        ownerexists(msg.sender)
        transactionexists(transactionid)
        notconfirmed(transactionid, msg.sender)
    {
        confirmations[transactionid][msg.sender] = true;
        confirmation(msg.sender, transactionid);
        executetransaction(transactionid);
    }

    
    
    function revokeconfirmation(uint transactionid)
        public
        ownerexists(msg.sender)
        confirmed(transactionid, msg.sender)
        notexecuted(transactionid)
    {
        confirmations[transactionid][msg.sender] = false;
        revocation(msg.sender, transactionid);
    }

    
    
    function executetransaction(uint transactionid)
        public
        notexecuted(transactionid)
    {
        if (isconfirmed(transactionid)) {
            transaction tx = transactions[transactionid];
            tx.executed = true;
            if (tx.destination.call.value(tx.value)(tx.data))
                execution(transactionid);
            else {
                executionfailure(transactionid);
                tx.executed = false;
            }
        }
    }

    
    
    
    function isconfirmed(uint transactionid)
        public
        constant
        returns (bool)
    {
        uint count = 0;
        for (uint i=0; i<owners.length; i++) {
            if (confirmations[transactionid][owners[i]])
                count += 1;
            if (count == required)
                return true;
        }
    }

    
    
    
    
    
    
    function addtransaction(address destination, uint value, bytes data)
        internal
        notnull(destination)
        returns (uint transactionid)
    {
        transactionid = transactioncount;
        transactions[transactionid] = transaction({
            destination: destination,
            value: value,
            data: data,
            executed: false
        });
        transactioncount += 1;
        submission(transactionid);
    }

    
    
    
    
    function getconfirmationcount(uint transactionid)
        public
        constant
        returns (uint count)
    {
        for (uint i=0; i<owners.length; i++)
            if (confirmations[transactionid][owners[i]])
                count += 1;
    }

    
    
    
    
    function gettransactioncount(bool pending, bool executed)
        public
        constant
        returns (uint count)
    {
        for (uint i=0; i<transactioncount; i++)
            if (   pending && !transactions[i].executed
                || executed && transactions[i].executed)
                count += 1;
    }

    
    
    function getowners()
        public
        constant
        returns (address[])
    {
        return owners;
    }

    
    
    
    function getconfirmations(uint transactionid)
        public
        constant
        returns (address[] _confirmations)
    {
        address[] memory confirmationstemp = new address[](owners.length);
        uint count = 0;
        uint i;
        for (i=0; i<owners.length; i++)
            if (confirmations[transactionid][owners[i]]) {
                confirmationstemp[count] = owners[i];
                count += 1;
            }
        _confirmations = new address[](count);
        for (i=0; i<count; i++)
            _confirmations[i] = confirmationstemp[i];
    }

    
    
    
    
    
    
    function gettransactionids(uint from, uint to, bool pending, bool executed)
        public
        constant
        returns (uint[] _transactionids)
    {
        uint[] memory transactionidstemp = new uint[](transactioncount);
        uint count = 0;
        uint i;
        for (i=0; i<transactioncount; i++)
            if (   pending && !transactions[i].executed
                || executed && transactions[i].executed)
            {
                transactionidstemp[count] = i;
                count += 1;
            }
        _transactionids = new uint[](to  from);
        for (i=from; i<to; i++)
            _transactionids[i  from] = transactionidstemp[i];
    }
}
