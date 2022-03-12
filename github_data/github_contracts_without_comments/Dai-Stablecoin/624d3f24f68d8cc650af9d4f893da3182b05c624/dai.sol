












pragma solidity >=0.4.24;

contract dai {
    
    mapping (address => uint) public wards;
    function rely(address guy) public auth { wards[guy] = 1; }
    function deny(address guy) public auth { wards[guy] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    
    string  public constant name     = ;
    string  public constant symbol   = ;
    string  public constant version  = ;
    uint8   public constant decimals = 18;
    uint256 public totalsupply;

    mapping (address => uint)                      public balanceof;
    mapping (address => mapping (address => uint)) public allowance;
    mapping (address => uint)                      public nonces;

    event approval(address indexed src, address indexed guy, uint wad);
    event transfer(address indexed src, address indexed dst, uint wad);

    
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x  y) <= x);
    }

    
    bytes32 public domain_separator;
    bytes32 public constant permit_typehash = keccak256(
        
    );

    constructor(uint256 chainid_) public {
        wards[msg.sender] = 1;
        domain_separator = keccak256(abi.encode(
            keccak256(),
            keccak256(bytes(name)),
            keccak256(bytes(version)),
            chainid_,
            address(this)
        ));
    }

    
    function transfer(address dst, uint wad) public returns (bool) {
        return transferfrom(msg.sender, dst, wad);
    }
    function transferfrom(address src, address dst, uint wad)
        public returns (bool)
    {
        require(balanceof[src] >= wad, );
        if (src != msg.sender && allowance[src][msg.sender] != uint(1)) {
            require(allowance[src][msg.sender] >= wad, );
            allowance[src][msg.sender] = sub(allowance[src][msg.sender], wad);
        }
        balanceof[src] = sub(balanceof[src], wad);
        balanceof[dst] = add(balanceof[dst], wad);
        emit transfer(src, dst, wad);
        return true;
    }
    function mint(address usr, uint wad) public auth {
        balanceof[usr] = add(balanceof[usr], wad);
        totalsupply    = add(totalsupply, wad);
        emit transfer(address(0), usr, wad);
    }
    function burn(address usr, uint wad) public {
        require(balanceof[usr] >= wad, );
        if (usr != msg.sender && allowance[usr][msg.sender] != uint(1)) {
            require(allowance[usr][msg.sender] >= wad, );
            allowance[usr][msg.sender] = sub(allowance[usr][msg.sender], wad);
        }
        balanceof[usr] = sub(balanceof[usr], wad);
        totalsupply    = sub(totalsupply, wad);
        emit transfer(usr, address(0), wad);
    }
    function approve(address usr, uint wad) public returns (bool) {
        allowance[msg.sender][usr] = wad;
        emit approval(msg.sender, usr, wad);
        return true;
    }

    
    function push(address usr, uint wad) public {
        transferfrom(msg.sender, usr, wad);
    }
    function pull(address usr, uint wad) public {
        transferfrom(usr, msg.sender, wad);
    }
    function move(address src, address dst, uint wad) public {
        transferfrom(src, dst, wad);
    }

    
    function permit(address holder, address spender, uint256 nonce, uint256 expiry,
                    bool allowed, uint8 v, bytes32 r, bytes32 s) public
    {
        bytes32 digest =
            keccak256(abi.encodepacked(
                ,
                domain_separator,
                keccak256(abi.encode(permit_typehash,
                                     holder,
                                     spender,
                                     nonce,
                                     expiry,
                                     allowed))
        ));
        require(holder == ecrecover(digest, v, r, s), );
        require(expiry == 0 || now <= expiry, );
        require(nonce == nonces[holder]++, );
        uint wad = allowed ? uint(1) : 0;
        allowance[holder][spender] = wad;
        emit approval(holder, spender, wad);
    }
}
