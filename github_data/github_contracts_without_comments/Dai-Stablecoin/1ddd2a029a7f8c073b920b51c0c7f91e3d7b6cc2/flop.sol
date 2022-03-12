













pragma solidity >=0.5.0;

import ;

contract dailike {
    function move(bytes32,bytes32,uint) public;
}
contract gemlike {
    function mint(address,uint) public;
}



contract flopper is dsnote {
    
    mapping (address => uint) public wards;
    function rely(address usr) public note auth { wards[usr] = 1; }
    function deny(address usr) public note auth { wards[usr] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    
    struct bid {
        uint256 bid;
        uint256 lot;
        address guy;  
        uint48  tic;  
        uint48  end;
        address vow;
    }

    mapping (uint => bid) public bids;

    dailike  public   dai;
    gemlike  public   gem;

    uint256  constant one = 1.00e27;
    uint256  public   beg = 1.05e27;  
    uint48   public   ttl = 3 hours;  
    uint48   public   tau = 2 days;   
    uint256  public kicks = 0;

    
    event kick(
      uint256 id,
      uint256 lot,
      uint256 bid,
      address indexed gal
    );

    
    constructor(address dai_, address gem_) public {
        wards[msg.sender] = 1;
        dai = dailike(dai_);
        gem = gemlike(gem_);
    }

    
    function add(uint48 x, uint48 y) internal pure returns (uint48 z) {
        z = x + y;
        require(z >= x);
    }
    function mul(uint x, uint y) internal pure returns (int z) {
        z = int(x * y);
        require(int(z) >= 0);
        require(y == 0 || uint(z) / y == x);
    }

    function b32(address a) internal pure returns (bytes32) {
        return bytes32(bytes20(a));
    }

    
    function kick(address gal, uint lot, uint bid) public auth returns (uint id) {
        require(kicks < uint(1));
        id = ++kicks;

        bids[id].vow = msg.sender;
        bids[id].bid = bid;
        bids[id].lot = lot;
        bids[id].guy = gal;
        bids[id].end = add(uint48(now), tau);

        emit kick(id, lot, bid, gal);
    }
    function dent(uint id, uint lot, uint bid) public note {
        require(bids[id].guy != address(0));
        require(bids[id].tic > now || bids[id].tic == 0);
        require(bids[id].end > now);

        require(bid == bids[id].bid);
        require(lot <  bids[id].lot);
        require(uint(mul(beg, lot)) / one <= bids[id].lot);  

        dai.move(b32(msg.sender), b32(bids[id].guy), bid);

        bids[id].guy = msg.sender;
        bids[id].lot = lot;
        bids[id].tic = add(uint48(now), ttl);
    }
    function deal(uint id) public note {
        require(bids[id].tic < now && bids[id].tic != 0 ||
                bids[id].end < now);
        gem.mint(bids[id].guy, bids[id].lot);
        delete bids[id];
    }
}
