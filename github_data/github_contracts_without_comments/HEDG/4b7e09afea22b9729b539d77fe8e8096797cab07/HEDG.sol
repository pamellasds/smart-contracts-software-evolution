pragma solidity 0.5.7;

contract dsmath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, );
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x  y) <= x, );
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, );
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant wad = 10 ** 18;
    uint constant ray = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), wad / 2) / wad;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), ray / 2) / ray;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, wad), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, ray), y / 2) / y;
    }

    
    
    
    
    
    
    
    
    
    
    
        z = n % 2 != 0 ? x : ray;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}


contract erc20events {
    event approval(address indexed src, address indexed guy, uint wad);
    event transfer(address indexed src, address indexed dst, uint wad);
}

contract erc20 is erc20events {
    function totalsupply() public view returns (uint);
    function balanceof(address guy) public view returns (uint);
    function allowance(address src, address guy) public view returns (uint);

    function approve(address guy, uint wad) public returns (bool);
    function transfer(address dst, uint wad) public returns (bool);
    function transferfrom(
        address src, address dst, uint wad
    ) public returns (bool);
}

contract dstokenbase is erc20, dsmath {
    uint256                                            _supply;
    mapping (address => uint256)                       _balances;
    mapping (address => mapping (address => uint256))  _approvals;

    constructor(uint supply) public {
        _balances[msg.sender] = supply;
        _supply = supply;
    }

    function totalsupply() public view returns (uint) {
        return _supply;
    }
    function balanceof(address src) public view returns (uint) {
        return _balances[src];
    }
    function allowance(address src, address guy) public view returns (uint) {
        return _approvals[src][guy];
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferfrom(msg.sender, dst, wad);
    }

    function transferfrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        if (src != msg.sender) {
            require(_approvals[src][msg.sender] >= wad, );
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }

        require(_balances[src] >= wad, );
        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        emit transfer(src, dst, wad);

        return true;
    }

    function approve(address guy, uint wad) public returns (bool) {
        _approvals[msg.sender][guy] = wad;

        emit approval(msg.sender, guy, wad);

        return true;
    }
}

contract dsnote {
    event lognote(
        bytes4   indexed  sig,
        address  indexed  guy,
        bytes32  indexed  foo,
        bytes32  indexed  bar,
        uint              wad,
        bytes             fax
    ) anonymous;

    modifier note {
        bytes32 foo;
        bytes32 bar;

        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
        }

        emit lognote(msg.sig, msg.sender, foo, bar, msg.value, msg.data);

        _;
    }
}

contract dsauthority {
    function cancall(
        address src, address dst, bytes4 sig
    ) public view returns (bool);
}

contract dsauthevents {
    event logsetauthority (address indexed authority);
    event logsetowner     (address indexed owner);
}

contract dsauth is dsauthevents {
    dsauthority  public  authority;
    address      public  owner;

    constructor() public {
        owner = msg.sender;
        emit logsetowner(msg.sender);
    }

    function setowner(address owner_)
        public
        auth
    {
        owner = owner_;
        emit logsetowner(owner);
    }

    function setauthority(dsauthority authority_)
        public
        auth
    {
        authority = authority_;
        emit logsetauthority(address(authority));
    }

    modifier auth {
        require(isauthorized(msg.sender, msg.sig));
        _;
    }

    function isauthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == dsauthority(0)) {
            return false;
        } else {
            return authority.cancall(src, address(this), sig);
        }
    }
}

contract dsstop is dsnote, dsauth {

    bool public stopped;

    modifier stoppable {
        require(!stopped);
        _;
    }
    function stop() public payable auth note {
        stopped = true;
    }
    function start() public payable auth note {
        stopped = false;
    }

}

contract hedgetrade is dstokenbase(0), dsstop {
		
    mapping (address => mapping (address => bool)) _trusted;

    bytes32  public  symbol;
    uint256  public  decimals = 18; 

    constructor(bytes32 symbol_) public {
        symbol = symbol_;
    }

    event trust(address indexed src, address indexed guy, bool wat);
    event mint(address indexed guy, uint wad);
    event burn(address indexed guy, uint wad);

    function trusted(address src, address guy) public view returns (bool) {
        return _trusted[src][guy];
    }
    function trust(address guy, bool wat) public stoppable {
        _trusted[msg.sender][guy] = wat;
        emit trust(msg.sender, guy, wat);
    }

    function approve(address guy, uint wad) public stoppable returns (bool) {
        return super.approve(guy, wad);
    }
    function transferfrom(address src, address dst, uint wad)
        public
        stoppable
        returns (bool)
    {
        if (src != msg.sender && !_trusted[src][msg.sender]) {
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }

        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        emit transfer(src, dst, wad);

        return true;
    }

    function push(address dst, uint wad) public {
        transferfrom(msg.sender, dst, wad);
    }
    function pull(address src, uint wad) public {
        transferfrom(src, msg.sender, wad);
    }
    function move(address src, address dst, uint wad) public {
        transferfrom(src, dst, wad);
    }

    function mint(uint wad) public {
        mint(msg.sender, wad);
    }
    function burn(uint wad) public {
        burn(msg.sender, wad);
    }
    function mint(address guy, uint wad) public auth stoppable {
        _balances[guy] = add(_balances[guy], wad);
        _supply = add(_supply, wad);
        emit mint(guy, wad);
    }
    function burn(address guy, uint wad) public auth stoppable {
        _balances[guy] = sub(_balances[guy], wad);
        _supply = sub(_supply, wad);
        emit burn(guy, wad);
    }

    
    bytes32   public  name = ;

    function setname(bytes32 name_) public auth {
        name = name_;
    }
}
