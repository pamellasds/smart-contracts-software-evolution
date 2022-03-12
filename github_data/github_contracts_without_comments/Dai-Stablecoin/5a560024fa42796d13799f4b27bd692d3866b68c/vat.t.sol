pragma solidity >=0.5.0;

import ;
import ;

import {vat} from ;
import {cat} from ;
import {vow} from ;
import {jug} from ;
import {gemjoin, ethjoin, daijoin} from ;
import {gemmove, daimove} from ;

import {flipper} from ;
import {flopper} from ;
import {flapper} from ;


contract hevm {
    function warp(uint256) public;
}

contract testvat is vat {
    uint256 constant one = 10 ** 27;
    function mint(address guy, uint wad) public {
        dai[bytes32(bytes20(guy))] += wad * one;
        debt += wad * one;
    }
    function balanceof(address guy) public view returns (uint) {
        return dai[bytes32(bytes20(guy))] / one;
    }
    function frob(bytes32 ilk, int dink, int dart) public {
        bytes32 guy = bytes32(bytes20(msg.sender));
        frob(ilk, guy, guy, guy, dink, dart);
    }
}

contract usr {
    vat public vat;
    constructor(vat vat_) public {
        vat = vat_;
    }
    function try_call(address addr, bytes calldata data) external returns (bool) {
        bytes memory _data = data;
        assembly {
            let ok := call(gas, addr, 0, add(_data, 0x20), mload(_data), 0, 0)
            let free := mload(0x40)
            mstore(free, ok)
            mstore(0x40, add(free, 32))
            revert(free, 32)
        }
    }
    function can_frob(bytes32 ilk, bytes32 u, bytes32 v, bytes32 w, int dink, int dart) public returns (bool) {
        string memory sig = ;
        bytes memory data = abi.encodewithsignature(sig, ilk, u, v, w, dink, dart);

        bytes memory can_call = abi.encodewithsignature(, vat, data);
        (bool ok, bytes memory success) = address(this).call(can_call);

        ok = abi.decode(success, (bool));
        if (ok) return true;
    }
    function can_fork(bytes32 ilk, bytes32 src, bytes32 dst, int dink, int dart) public returns (bool) {
        string memory sig = ;
        bytes memory data = abi.encodewithsignature(sig, ilk, src, dst, dink, dart);

        bytes memory can_call = abi.encodewithsignature(, vat, data);
        (bool ok, bytes memory success) = address(this).call(can_call);

        ok = abi.decode(success, (bool));
        if (ok) return true;
    }
    function frob(bytes32 ilk, bytes32 u, bytes32 v, bytes32 w, int dink, int dart) public {
        vat.frob(ilk, u, v, w, dink, dart);
    }
    function fork(bytes32 ilk, bytes32 src, bytes32 dst, int dink, int dart) public {
        vat.fork(ilk, src, dst, dink, dart);
    }
    function hope(address usr) public {
        vat.hope(usr);
    }
}


contract frobtest is dstest {
    testvat vat;
    dstoken gold;
    jug     jug;

    gemjoin gema;

    function try_frob(bytes32 ilk, int ink, int art) public returns (bool ok) {
        string memory sig = ;
        bytes32 self = bytes32(bytes20(address(this)));
        (ok,) = address(vat).call(abi.encodewithsignature(sig, ilk, self, self, self, ink, art));
    }

    function ray(uint wad) internal pure returns (uint) {
        return wad * 10 ** 9;
    }

    function setup() public {
        vat = new testvat();

        gold = new dstoken();
        gold.mint(1000 ether);

        vat.init();
        gema = new gemjoin(address(vat), , address(gold));

        vat.file(, ,    ray(1 ether));
        vat.file(, , rad(1000 ether));
        vat.file(,         rad(1000 ether));
        jug = new jug(address(vat));
        jug.init();
        vat.rely(address(jug));

        gold.approve(address(gema));
        gold.approve(address(vat));

        vat.rely(address(vat));
        vat.rely(address(gema));

        gema.join(bytes32(bytes20(address(this))), 1000 ether);
    }

    function gem(bytes32 ilk, address urn) internal view returns (uint) {
        return vat.gem(ilk, bytes32(bytes20(urn)));
    }
    function ink(bytes32 ilk, address urn) internal view returns (uint) {
        (uint ink_, uint art_) = vat.urns(ilk, bytes32(bytes20(urn))); art_;
        return ink_;
    }
    function art(bytes32 ilk, address urn) internal view returns (uint) {
        (uint ink_, uint art_) = vat.urns(ilk, bytes32(bytes20(urn))); ink_;
        return art_;
    }

    function test_setup() public {
        asserteq(gold.balanceof(address(gema)), 1000 ether);
        asserteq(gem(,    address(this)), 1000 ether);
    }
    function test_join() public {
        bytes32 urn = bytes32(bytes20(address(this)));
        gold.mint(500 ether);
        asserteq(gold.balanceof(address(this)),    500 ether);
        asserteq(gold.balanceof(address(gema)),   1000 ether);
        gema.join(urn,                             500 ether);
        asserteq(gold.balanceof(address(this)),      0 ether);
        asserteq(gold.balanceof(address(gema)),   1500 ether);
        gema.exit(urn, address(this),              250 ether);
        asserteq(gold.balanceof(address(this)),    250 ether);
        asserteq(gold.balanceof(address(gema)),   1250 ether);
    }
    function test_lock() public {
        asserteq(ink(, address(this)),    0 ether);
        asserteq(gem(, address(this)), 1000 ether);
        vat.frob(, 6 ether, 0);
        asserteq(ink(, address(this)),   6 ether);
        asserteq(gem(, address(this)), 994 ether);
        vat.frob(, 6 ether, 0);
        asserteq(ink(, address(this)),    0 ether);
        asserteq(gem(, address(this)), 1000 ether);
    }
    function test_calm() public {
        
        
        vat.file(, , rad(10 ether));
        asserttrue( try_frob(, 10 ether, 9 ether));
        
        asserttrue(!try_frob(,  0 ether, 2 ether));
    }
    function test_cool() public {
        
        
        vat.file(, , rad(10 ether));
        asserttrue(try_frob(, 10 ether,  8 ether));
        vat.file(, , rad(5 ether));
        
        asserttrue(try_frob(,  0 ether, 1 ether));
    }
    function test_safe() public {
        
        
        vat.frob(, 10 ether, 5 ether);                
        asserttrue(!try_frob(, 0 ether, 6 ether));  
    }
    function test_nice() public {
        
        

        vat.frob(, 10 ether, 10 ether);
        vat.file(, , ray(0.5 ether));  

        
        asserttrue(!try_frob(,  0 ether,  1 ether));
        
        asserttrue( try_frob(,  0 ether, 1 ether));
        
        asserttrue(!try_frob(, 1 ether,  0 ether));
        
        asserttrue( try_frob(,  1 ether,  0 ether));

        
        
        asserttrue(!this.try_frob(, 2 ether, 4 ether));
        
        asserttrue(!this.try_frob(,  5 ether,  1 ether));

        
        asserttrue( this.try_frob(, 1 ether, 4 ether));
        vat.file(, , ray(0.4 ether));  
        
        asserttrue( this.try_frob(,  5 ether, 1 ether));
    }

    function b32(address addr) internal pure returns (bytes32) {
        return bytes32(bytes20(addr));
    }
    function rad(uint wad) internal pure returns (uint) {
        return wad * 10 ** 27;
    }
    function test_alt_callers() public {
        usr ali = new usr(vat);
        usr bob = new usr(vat);
        usr che = new usr(vat);

        bytes32 a = b32(address(ali));
        bytes32 b = b32(address(bob));
        bytes32 c = b32(address(che));

        vat.slip(, a, int(rad(20 ether)));
        vat.slip(, b, int(rad(20 ether)));
        vat.slip(, c, int(rad(20 ether)));

        ali.frob(, a, a, a, 10 ether, 5 ether);

        
        asserttrue( ali.can_frob(, a, a, a,  1 ether,  0 ether));
        asserttrue( bob.can_frob(, a, b, b,  1 ether,  0 ether));
        asserttrue( che.can_frob(, a, c, c,  1 ether,  0 ether));
        
        asserttrue(!ali.can_frob(, a, b, a,  1 ether,  0 ether));
        asserttrue(!bob.can_frob(, a, c, b,  1 ether,  0 ether));
        asserttrue(!che.can_frob(, a, a, c,  1 ether,  0 ether));

        
        asserttrue( ali.can_frob(, a, a, a, 1 ether,  0 ether));
        asserttrue(!bob.can_frob(, a, b, b, 1 ether,  0 ether));
        asserttrue(!che.can_frob(, a, c, c, 1 ether,  0 ether));
        
        asserttrue( ali.can_frob(, a, b, a, 1 ether,  0 ether));
        asserttrue( ali.can_frob(, a, c, a, 1 ether,  0 ether));

        
        asserttrue( ali.can_frob(, a, a, a,  0 ether,  1 ether));
        asserttrue(!bob.can_frob(, a, b, b,  0 ether,  1 ether));
        asserttrue(!che.can_frob(, a, c, c,  0 ether,  1 ether));
        
        asserttrue( ali.can_frob(, a, a, b,  0 ether,  1 ether));
        asserttrue( ali.can_frob(, a, a, c,  0 ether,  1 ether));

        vat.move(a, b, int(rad(1 ether)));
        vat.move(a, c, int(rad(1 ether)));

        
        asserttrue( ali.can_frob(, a, a, a,  0 ether, 1 ether));
        asserttrue( bob.can_frob(, a, b, b,  0 ether, 1 ether));
        asserttrue( che.can_frob(, a, c, c,  0 ether, 1 ether));
        
        asserttrue(!ali.can_frob(, a, a, b,  0 ether, 1 ether));
        asserttrue(!bob.can_frob(, a, b, c,  0 ether, 1 ether));
        asserttrue(!che.can_frob(, a, c, a,  0 ether, 1 ether));
    }

    function test_hope() public {
        usr ali = new usr(vat);
        usr bob = new usr(vat);
        usr che = new usr(vat);

        bytes32 a = b32(address(ali));
        bytes32 b = b32(address(bob));
        bytes32 c = b32(address(che));

        vat.slip(, a, int(rad(20 ether)));
        vat.slip(, b, int(rad(20 ether)));
        vat.slip(, c, int(rad(20 ether)));

        ali.frob(, a, a, a, 10 ether, 5 ether);

        
        asserttrue( ali.can_frob(, a, a, a,  0 ether,  1 ether));
        asserttrue(!bob.can_frob(, a, b, b,  0 ether,  1 ether));
        asserttrue(!che.can_frob(, a, c, c,  0 ether,  1 ether));

        ali.hope(address(bob));

        
        asserttrue( ali.can_frob(, a, a, a,  0 ether,  1 ether));
        asserttrue( bob.can_frob(, a, b, b,  0 ether,  1 ether));
        asserttrue(!che.can_frob(, a, c, c,  0 ether,  1 ether));
    }

    function test_dust() public {
        asserttrue( try_frob(, 9 ether,  1 ether));
        vat.file(, , rad(5 ether));
        asserttrue(!try_frob(, 5 ether,  2 ether));
        asserttrue( try_frob(, 0 ether,  5 ether));
        asserttrue(!try_frob(, 0 ether, 5 ether));
        asserttrue( try_frob(, 0 ether, 6 ether));
    }
}

contract jointest is dstest {
    testvat vat;
    ethjoin etha;
    daijoin daia;
    dstoken dai;
    bytes32 me;

    function setup() public {
        vat = new testvat();
        vat.init();

        etha = new ethjoin(address(vat), );
        vat.rely(address(etha));

        dai  = new dstoken();
        daia = new daijoin(address(vat), address(dai));
        vat.rely(address(daia));
        dai.setowner(address(daia));

        me = bytes32(bytes20(address(this)));
    }
    function () external payable {}
    function test_eth_join() public {
        etha.join.value(10 ether)(bytes32(bytes20(address(this))));
        asserteq(vat.gem(, me), 10 ether);
    }
    function test_eth_exit() public {
        bytes32 urn = bytes32(bytes20(address(this)));
        etha.join.value(50 ether)(urn);
        etha.exit(urn, address(this), 10 ether);
        asserteq(vat.gem(, me), 40 ether);
    }
    function rad(uint wad) internal pure returns (uint) {
        return wad * 10 ** 27;
    }
    function test_dai_exit() public {
        bytes32 urn = bytes32(bytes20(address(this)));
        vat.mint(address(this), 100 ether);
        daia.exit(urn, address(this), 60 ether);
        asserteq(dai.balanceof(address(this)), 60 ether);
        asserteq(vat.dai(me),              rad(40 ether));
    }
    function test_dai_exit_join() public {
        bytes32 urn = bytes32(bytes20(address(this)));
        vat.mint(address(this), 100 ether);
        daia.exit(urn, address(this), 60 ether);
        dai.approve(address(daia), uint(1));
        daia.join(urn, 30 ether);
        asserteq(dai.balanceof(address(this)),     30 ether);
        asserteq(vat.dai(me),                  rad(70 ether));
    }
    function test_fallback_reverts() public {
        (bool ok,) = address(etha).call();
        asserttrue(!ok);
    }
    function test_nonzero_fallback_reverts() public {
        (bool ok,) = address(etha).call.value(10)();
        asserttrue(!ok);
    }
}

contract bitetest is dstest {
    hevm hevm;

    testvat vat;
    vow     vow;
    cat     cat;
    dstoken gold;
    jug     jug;

    gemjoin gema;
    gemmove gemm;
    daimove daim;

    flipper flip;
    flopper flop;
    flapper flap;

    dstoken gov;

    function try_frob(bytes32 ilk, int ink, int art) public returns (bool ok) {
        string memory sig = ;
        bytes32 self = bytes32(bytes20(address(this)));
        (ok,) = address(vat).call(abi.encodewithsignature(sig, ilk, self, self, self, ink, art));
    }

    function ray(uint wad) internal pure returns (uint) {
        return wad * 10 ** 9;
    }
    function rad(uint wad) internal pure returns (uint) {
        return wad * 10 ** 27;
    }

    function gem(bytes32 ilk, address urn) internal view returns (uint) {
        return vat.gem(ilk, bytes32(bytes20(urn)));
    }
    function ink(bytes32 ilk, address urn) internal view returns (uint) {
        (uint ink_, uint art_) = vat.urns(ilk, bytes32(bytes20(urn))); art_;
        return ink_;
    }
    function art(bytes32 ilk, address urn) internal view returns (uint) {
        (uint ink_, uint art_) = vat.urns(ilk, bytes32(bytes20(urn))); ink_;
        return art_;
    }

    function setup() public {
        hevm = hevm(0x7109709ecfa91a80626ff3989d68f67f5b1dd12d);
        hevm.warp(0);

        gov = new dstoken();
        gov.mint(100 ether);

        vat = new testvat();
        vat = vat;

        daim = new daimove(address(vat));
        vat.rely(address(daim));

        flap = new flapper(address(daim), address(gov));
        flop = new flopper(address(daim), address(gov));
        gov.setowner(address(flop));

        vow = new vow();
        vow.file(,  address(vat));
        vow.file(, address(flap));
        vow.file(, address(flop));
        flop.rely(address(vow));

        jug = new jug(address(vat));
        jug.init();
        jug.file(, bytes32(bytes20(address(vow))));
        vat.rely(address(jug));

        cat = new cat(address(vat));
        cat.file(, address(vow));
        vat.rely(address(cat));
        vow.rely(address(cat));

        gold = new dstoken();
        gold.mint(1000 ether);

        vat.init();
        gema = new gemjoin(address(vat), , address(gold));
        vat.rely(address(gema));
        gold.approve(address(gema));
        gema.join(bytes32(bytes20(address(this))), 1000 ether);

        gemm = new gemmove(address(vat), );
        vat.rely(address(gemm));

        vat.file(, , ray(1 ether));
        vat.file(, , rad(1000 ether));
        vat.file(,         rad(1000 ether));
        flip = new flipper(address(daim), address(gemm));
        cat.file(, , address(flip));
        cat.file(, , ray(1 ether));

        vat.rely(address(flip));
        vat.rely(address(flap));
        vat.rely(address(flop));

        daim.hope(address(flip));
        daim.hope(address(flop));
        gold.approve(address(vat));
        gov.approve(address(flap));
    }
    function test_happy_bite() public {
        
        
        vat.file(, , ray(2.5 ether));
        vat.frob(,  40 ether, 100 ether);

        
        vat.file(, , ray(2 ether));  

        asserteq(ink(, address(this)),  40 ether);
        asserteq(art(, address(this)), 100 ether);
        asserteq(vow.woe(), 0 ether);
        asserteq(gem(, address(this)), 960 ether);
        uint id = cat.bite(, bytes32(bytes20(address(this))));
        asserteq(ink(, address(this)), 0);
        asserteq(art(, address(this)), 0);
        asserteq(vow.sin(uint48(now)),      100 ether);
        asserteq(gem(, address(this)), 960 ether);

        cat.file(, , uint(100 ether));
        uint auction = cat.flip(id, 100 ether);  

        asserteq(vat.balanceof(address(vow)),   0 ether);
        flip.tend(auction, 40 ether,   1 ether);
        asserteq(vat.balanceof(address(vow)),   1 ether);
        flip.tend(auction, 40 ether, 100 ether);
        asserteq(vat.balanceof(address(vow)), 100 ether);

        asserteq(vat.balanceof(address(this)),       0 ether);
        asserteq(gem(, address(this)), 960 ether);
        vat.mint(address(this), 100 ether);  
        flip.dent(auction, 38 ether,  100 ether);
        asserteq(vat.balanceof(address(this)), 100 ether);
        asserteq(vat.balanceof(address(vow)),  100 ether);
        asserteq(gem(, address(this)), 962 ether);
        asserteq(gem(, address(this)), 962 ether);

        asserteq(vow.sin(uint48(now)),       100 ether);
        asserteq(vat.balanceof(address(vow)), 100 ether);
    }

    function test_floppy_bite() public {
        vat.file(, , ray(2.5 ether));
        vat.frob(,  40 ether, 100 ether);
        vat.file(, , ray(2 ether));  

        asserteq(vow.sin(uint48(now)),   0 ether);
        cat.bite(, bytes32(bytes20(address(this))));
        asserteq(vow.sin(uint48(now)), 100 ether);

        asserteq(vow.sin(), 100 ether);
        vow.flog(uint48(now));
        asserteq(vow.sin(),   0 ether);
        asserteq(vow.woe(), 100 ether);
        asserteq(vow.joy(),   0 ether);
        asserteq(vow.ash(),   0 ether);

        vow.file(, uint(10 ether));
        uint f1 = vow.flop();
        asserteq(vow.woe(),  90 ether);
        asserteq(vow.joy(),   0 ether);
        asserteq(vow.ash(),  10 ether);
        flop.dent(f1, 1000 ether, 10 ether);
        asserteq(vow.woe(),  90 ether);
        asserteq(vow.joy(),  10 ether);
        asserteq(vow.ash(),  10 ether);

        asserteq(gov.balanceof(address(this)),  100 ether);
        hevm.warp(4 hours);
        flop.deal(f1);
        asserteq(gov.balanceof(address(this)), 1100 ether);
    }

    function test_flappy_bite() public {
        
        vat.mint(address(vow), 100 ether);
        asserteq(vat.balanceof(address(vow)),  100 ether);
        asserteq(gov.balanceof(address(this)), 100 ether);

        vow.file(, uint(100 ether));
        asserteq(vow.awe(), 0 ether);
        uint id = vow.flap();

        asserteq(vat.balanceof(address(this)),   0 ether);
        asserteq(gov.balanceof(address(this)), 100 ether);
        flap.tend(id, 100 ether, 10 ether);
        hevm.warp(4 hours);
        flap.deal(id);
        asserteq(vat.balanceof(address(this)),   100 ether);
        asserteq(gov.balanceof(address(this)),    90 ether);
    }
}

contract foldtest is dstest {
    vat vat;

    function ray(uint wad) internal pure returns (uint) {
        return wad * 10 ** 9;
    }
    function rad(uint wad) internal pure returns (uint) {
        return wad * 10 ** 27;
    }
    function tab(bytes32 ilk, bytes32 urn) internal view returns (uint) {
        (uint ink_, uint art_) = vat.urns(ilk, bytes32(bytes20(urn))); ink_;
        (uint art_, uint rate, uint spot, uint line, uint dust) = vat.ilks(ilk);
        art_; spot; line; dust;
        return art_ * rate;
    }
    function jam(bytes32 ilk, bytes32 urn) internal view returns (uint) {
        (uint ink_, uint art_) = vat.urns(ilk, bytes32(bytes20(urn))); art_;
        return ink_;
    }

    function setup() public {
        vat = new vat();
        vat.init();
        vat.file(, rad(100 ether));
        vat.file(, , rad(100 ether));
    }
    function draw(bytes32 ilk, uint dai) internal {
        vat.file(, rad(dai));
        vat.file(ilk, , rad(dai));
        vat.file(ilk, , 10 ** 27 * 10000 ether);
        bytes32 self = bytes32(bytes20(address(this)));
        vat.slip(ilk, self,  10 ** 27 * 1 ether);
        vat.frob(ilk, self, self, self, int(1 ether), int(dai));
    }
    function test_fold() public {
        bytes32 self = bytes32(bytes20(address(this)));
        draw(, 1 ether);

        asserteq(tab(, self), rad(1.00 ether));
        vat.fold(, ,  int(ray(0.05 ether)));
        asserteq(tab(, self), rad(1.05 ether));
        asserteq(vat.dai(),     rad(0.05 ether));
    }
}
