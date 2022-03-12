













pragma solidity ^0.4.24;

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
    mapping(address => mapping (address => bool)) public can;
    function hope(address guy) public { can[msg.sender][guy] = true; }
    function nope(address guy) public { can[msg.sender][guy] = false; }
    function move(address src, address dst, uint wad) public {
        require(int(wad) >= 0);
        require(src == msg.sender || can[src][msg.sender]);
        vat.flux(ilk, bytes32(src), bytes32(dst), int(wad));
    }
    function push(bytes32 urn, uint wad) public {
        require(int(wad) >= 0);
        vat.flux(ilk, bytes32(msg.sender), urn, int(wad));
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
    mapping(address => mapping (address => bool)) public can;
    function hope(address guy) public { can[msg.sender][guy] = true; }
    function nope(address guy) public { can[msg.sender][guy] = false; }
    function move(address src, address dst, uint wad) public {
        require(src == msg.sender || can[src][msg.sender]);
        vat.move(bytes32(src), bytes32(dst), mul(one, wad));
    }
}
