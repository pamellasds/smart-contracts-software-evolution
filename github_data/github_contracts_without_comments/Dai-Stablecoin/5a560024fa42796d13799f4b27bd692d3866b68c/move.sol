













pragma solidity >=0.5.0;

contract vatlike {
    function move(bytes32,bytes32,int) public;
    function flux(bytes32,bytes32,bytes32,int) public;
}

contract gemmove {
    vatlike public vat;
    bytes32 public ilk;
    constructor(address vat_, bytes32 ilk_) public {
        vat = vatlike(vat_);
        ilk = ilk_;
    }
    mapping(address => mapping (address => uint)) public can;
    function hope(address guy) public { can[msg.sender][guy] = 1; }
    function nope(address guy) public { can[msg.sender][guy] = 0; }
    function move(bytes32 src, bytes32 dst, uint wad) public {
        require(bytes20(src) == bytes20(msg.sender) || can[address(bytes20(src))][msg.sender] == 1);
        require(int(wad) >= 0);
        vat.flux(ilk, src, dst, int(wad));
    }
    function push(bytes32 urn, uint wad) public {
        bytes32 guy = bytes32(bytes20(msg.sender));
        require(int(wad) >= 0);
        vat.flux(ilk, guy, urn, int(wad));
    }
}

contract daimove {
    vatlike public vat;
    constructor(address vat_) public {
        vat = vatlike(vat_);
    }
    uint constant one = 10 ** 27;
    function mul(uint x, uint y) internal pure returns (int z) {
        z = int(x * y);
        require(int(z) >= 0);
        require(y == 0 || uint(z) / y == x);
    }
    mapping(address => mapping (address => uint)) public can;
    function hope(address guy) public { can[msg.sender][guy] = 1; }
    function nope(address guy) public { can[msg.sender][guy] = 0; }
    function move(bytes32 src, bytes32 dst, uint wad) public {
        require(bytes20(src) == bytes20(msg.sender) || can[address(bytes20(src))][msg.sender] == 1);
        vat.move(src, dst, mul(one, wad));
    }
}
