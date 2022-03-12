pragma solidity ^0.4.0;




contract multisigwallet {

    event confirmation(address sender, bytes32 transactionhash);
    event revocation(address sender, bytes32 transactionhash);
    event submission(bytes32 transactionhash);
    event execution(bytes32 transactionhash);
    event deposit(address sender, uint value);
    event owneraddition(address owner);
    event ownerremoval(address owner);
    event requiredupdate(uint required);

    mapping (bytes32 => transaction) public transactions;
    mapping (bytes32 => mapping (address => bool)) public confirmations;
    mapping (address => bool) public isowner;
    address[] owners;
    bytes32[] transactionlist;
    uint public required;

    struct transaction {
        address destination;
        uint value;
        bytes data;
        uint nonce;
        bool executed;
    }

    modifier onlywallet() {
        if (msg.sender != address(this))
            throw;
        _;
    }

    modifier signaturesfromowners(bytes32 transactionhash, uint8[] v, bytes32[] rs) {
        for (uint i=0; i<v.length; i++)
            if (!isowner[ecrecover(transactionhash, v[i], rs[i], rs[v.length + i])])
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

    modifier confirmed(bytes32 transactionhash, address owner) {
        if (!confirmations[transactionhash][owner])
            throw;
        _;
    }

    modifier notconfirmed(bytes32 transactionhash, address owner) {
        if (confirmations[transactionhash][owner])
            throw;
        _;
    }

    modifier notexecuted(bytes32 transactionhash) {
        if (transactions[transactionhash].executed)
            throw;
        _;
    }

    modifier notnull(address destination) {
        if (destination == 0)
            throw;
        _;
    }

    modifier validrequired(uint _ownercount, uint _required) {
        if (   _required > _ownercount
            || _required == 0
            || _ownercount == 0)
            throw;
        _;
    }

    function addowner(address owner)
        external
        onlywallet
        ownerdoesnotexist(owner)
    {
        isowner[owner] = true;
        owners.push(owner);
        owneraddition(owner);
    }

    function removeowner(address owner)
        external
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
            updaterequired(owners.length);
        ownerremoval(owner);
    }

    function updaterequired(uint _required)
        public
        onlywallet
        validrequired(owners.length, _required)
    {
        required = _required;
        requiredupdate(_required);
    }

    function addtransaction(address destination, uint value, bytes data, uint nonce)
        private
        notnull(destination)
        returns (bytes32 transactionhash)
    {
        transactionhash = sha3(destination, value, data, nonce);
        if (transactions[transactionhash].destination == 0) {
            transactions[transactionhash] = transaction({
                destination: destination,
                value: value,
                data: data,
                nonce: nonce,
                executed: false
            });
            transactionlist.push(transactionhash);
            submission(transactionhash);
        }
    }

    function submittransaction(address destination, uint value, bytes data, uint nonce)
        external
        returns (bytes32 transactionhash)
    {
        transactionhash = addtransaction(destination, value, data, nonce);
        confirmtransaction(transactionhash);
    }

    function submittransactionwithsignatures(address destination, uint value, bytes data, uint nonce, uint8[] v, bytes32[] rs)
        external
        returns (bytes32 transactionhash)
    {
        transactionhash = addtransaction(destination, value, data, nonce);
        confirmtransactionwithsignatures(transactionhash, v, rs);
    }

    function addconfirmation(bytes32 transactionhash, address owner)
        private
        notconfirmed(transactionhash, owner)
    {
        confirmations[transactionhash][owner] = true;
        confirmation(owner, transactionhash);
    }

    function confirmtransaction(bytes32 transactionhash)
        public
        ownerexists(msg.sender)
    {
        addconfirmation(transactionhash, msg.sender);
        executetransaction(transactionhash);
    }

    function confirmtransactionwithsignatures(bytes32 transactionhash, uint8[] v, bytes32[] rs)
        public
        signaturesfromowners(transactionhash, v, rs)
    {
        for (uint i=0; i<v.length; i++)
            addconfirmation(transactionhash, ecrecover(transactionhash, v[i], rs[i], rs[i + v.length]));
        executetransaction(transactionhash);
    }

    function executetransaction(bytes32 transactionhash)
        public
        notexecuted(transactionhash)
    {
        if (isconfirmed(transactionhash)) {
            transaction tx = transactions[transactionhash];
            tx.executed = true;
            if (!tx.destination.call.value(tx.value)(tx.data))
                throw;
            execution(transactionhash);
        }
    }

    function revokeconfirmation(bytes32 transactionhash)
        external
        ownerexists(msg.sender)
        confirmed(transactionhash, msg.sender)
        notexecuted(transactionhash)
    {
        confirmations[transactionhash][msg.sender] = false;
        revocation(msg.sender, transactionhash);
    }

    function multisigwallet(address[] _owners, uint _required)
        validrequired(_owners.length, _required)
    {
        for (uint i=0; i<_owners.length; i++)
            isowner[_owners[i]] = true;
        owners = _owners;
        required = _required;
    }

    function()
        payable
    {
        if (msg.value > 0)
            deposit(msg.sender, msg.value);
    }

    function isconfirmed(bytes32 transactionhash)
        public
        constant
        returns (bool)
    {
        uint count = 0;
        for (uint i=0; i<owners.length; i++)
            if (confirmations[transactionhash][owners[i]])
                count += 1;
            if (count == required)
                return true;
    }

    function confirmationcount(bytes32 transactionhash)
        external
        constant
        returns (uint count)
    {
        for (uint i=0; i<owners.length; i++)
            if (confirmations[transactionhash][owners[i]])
                count += 1;
    }

    function filtertransactions(bool ispending)
        private
        returns (bytes32[] _transactionlist)
    {
        bytes32[] memory _transactionlisttemp = new bytes32[](transactionlist.length);
        uint count = 0;
        for (uint i=0; i<transactionlist.length; i++)
            if (   ispending && !transactions[transactionlist[i]].executed
                || !ispending && transactions[transactionlist[i]].executed)
            {
                _transactionlisttemp[count] = transactionlist[i];
                count += 1;
            }
        _transactionlist = new bytes32[](count);
        for (i=0; i<count; i++)
            if (_transactionlisttemp[i] > 0)
                _transactionlist[i] = _transactionlisttemp[i];
    }

    function getpendingtransactions()
        external
        constant
        returns (bytes32[] _transactionlist)
    {
        return filtertransactions(true);
    }

    function getexecutedtransactions()
        external
        constant
        returns (bytes32[] _transactionlist)
    {
        return filtertransactions(false);
    }
}
