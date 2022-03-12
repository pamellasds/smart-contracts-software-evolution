pragma solidity >=0.5.0;
pragma experimental abiencoderv2;

import ;
import ;

import {vat} from ;
import {cat} from ;
import {vow} from ;
import {jug} from ;
import {gemjoin, ethjoin, daijoin} from ;

import {flipper} from ;
import {flopper} from ;
import {flapper} from ;


contract hevm {
    function warp(uint256) public;
}

contract testvat is vat {
    uint256 constant one = 10 ** 27;
    function mint(address usr, uint wad) public {
        dai[usr] += wad * one;
        debt += wad * one;
    }
    function balanceof(address usr) public view returns (uint) {
        return dai[usr] / one;
    }
    function frob(bytes32 ilk, int dink, int dart) public {
        address usr = msg.sender;
        frob(ilk, usr, usr, usr, dink, dart);
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
    function can_frob(bytes32 ilk, address u, address v, address w, int dink, int dart) public returns (bool) {
        string memory sig = ;
        bytes memory data = abi.encodewithsignature(sig, ilk, u, v, w, dink, dart);

        bytes memory can_call = abi.encodewithsignature(, vat, data);
        (bool ok, bytes memory success) = address(this).call(can_call);

        ok = abi.decode(success, (bool));
        if (ok) return true;
    }
    function can_fork(bytes32 ilk, address src, address dst, int dink, int dart) public returns (bool) {
        string memory sig = ;
        bytes memory data = abi.encodewithsignature(sig, ilk, src, dst, dink, dart);

        bytes memory can_call = abi.encodewithsignature(, vat, data);
        (bool ok, bytes memory success) = address(this).call(can_call);

        ok = abi.decode(success, (bool));
        if (ok) return true;
    }
    function frob(bytes32 ilk, address u, address v, address w, int dink, int dart) public {
        vat.frob(ilk, u, v, w, dink, dart);
    }
    function fork(bytes32 ilk, address src, address dst, int dink, int dart) public {
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
        address self = address(this);
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

        gema.join(address(this), 1000 ether);
    }

    function gem(bytes32 ilk, address urn) internal view returns (uint) {
        return vat.gem(ilk, urn);
    }
    function ink(bytes32 ilk, address urn) internal view returns (uint) {
        (uint ink_, uint art_) = vat.urns(ilk, urn); art_;
        return ink_;
    }
    function art(bytes32 ilk, address urn) internal view returns (uint) {
        (uint ink_, uint art_) = vat.urns(ilk, urn); ink_;
        return art_;
    }

    function test_setup() public {
        asserteq(gold.balanceof(address(gema)), 1000 ether);
        asserteq(gem(,    address(this)), 1000 ether);
    }
    function test_join() public {
        address urn = address(this);
        gold.mint(500 ether);
        asserteq(gold.balanceof(address(this)),    500 ether);
        asserteq(gold.balanceof(address(gema)),   1000 ether);
        gema.join(urn,                             500 ether);
        asserteq(gold.balanceof(address(this)),      0 ether);
        asserteq(gold.balanceof(address(gema)),   1500 ether);
        gema.exit(urn,                             250 ether);
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

    function rad(uint wad) internal pure returns (uint) {
        return wad * 10 ** 27;
    }
    function test_alt_callers() public {
        usr ali = new usr(vat);
        usr bob = new usr(vat);
        usr che = new usr(vat);

        address a = address(ali);
        address b = address(bob);
        address c = address(che);

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

        vat.mint(address(bob), 1 ether);
        vat.mint(address(che), 1 ether);

        
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

        address a = address(ali);
        address b = address(bob);
        address c = address(che);

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
    address me;

    function setup() public {
        vat = new testvat();
        vat.init();

        etha = new ethjoin(address(vat), );
        vat.rely(address(etha));

        dai  = new dstoken();
        daia = new daijoin(address(vat), address(dai));
        vat.rely(address(daia));
        dai.setowner(address(daia));

        me = address(this);
    }
    function () external payable {}
    function test_eth_join() public {
        etha.join.value(10 ether)(address(this));
        asserteq(vat.gem(, me), 10 ether);
    }
    function test_eth_exit() public {
        address payable urn = address(this);
        etha.join.value(50 ether)(urn);
        etha.exit(urn, 10 ether);
        asserteq(vat.gem(, me), 40 ether);
    }
    function rad(uint wad) internal pure returns (uint) {
        return wad * 10 ** 27;
    }
    function test_dai_exit() public {
        address urn = address(this);
        vat.mint(address(this), 100 ether);
        vat.hope(address(daia));
        daia.exit(urn, 60 ether);
        asserteq(dai.balanceof(address(this)), 60 ether);
        asserteq(vat.dai(me),              rad(40 ether));
    }
    function test_dai_exit_join() public {
        address urn = address(this);
        vat.mint(address(this), 100 ether);
        vat.hope(address(daia));
        daia.exit(urn, 60 ether);
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

contract fliplike {
    struct bid {
        uint256 bid;
        uint256 lot;
        address guy;  
        uint48  tic;  
        uint48  end;
        address urn;
        address gal;
        uint256 tab;
    }
    function bids(uint) public view returns (bid memory);
}

contract bitetest is dstest {
    hevm hevm;

    testvat vat;
    vow     vow;
    cat     cat;
    dstoken gold;
    jug     jug;

    gemjoin gema;

    flipper flip;
    flopper flop;
    flapper flap;

    dstoken gov;

    function try_frob(bytes32 ilk, int ink, int art) public returns (bool ok) {
        string memory sig = ;
        address self = address(this);
        (ok,) = address(vat).call(abi.encodewithsignature(sig, ilk, self, self, self, ink, art));
    }

    function ray(uint wad) internal pure returns (uint) {
        return wad * 10 ** 9;
    }
    function rad(uint wad) internal pure returns (uint) {
        return wad * 10 ** 27;
    }

    function gem(bytes32 ilk, address urn) internal view returns (uint) {
        return vat.gem(ilk, urn);
    }
    function ink(bytes32 ilk, address urn) internal view returns (uint) {
        (uint ink_, uint art_) = vat.urns(ilk, urn); art_;
        return ink_;
    }
    function art(bytes32 ilk, address urn) internal view returns (uint) {
        (uint ink_, uint art_) = vat.urns(ilk, urn); ink_;
        return art_;
    }

    function setup() public {
        hevm = hevm(0x7109709ecfa91a80626ff3989d68f67f5b1dd12d);
        hevm.warp(0);

        gov = new dstoken();
        gov.mint(100 ether);

        vat = new testvat();
        vat = vat;

        flap = new flapper(address(vat), address(gov));
        flop = new flopper(address(vat), address(gov));
        gov.setowner(address(flop));

        vow = new vow(address(vat), address(flap), address(flop));
        flop.rely(address(vow));

        jug = new jug(address(vat));
        jug.init();
        jug.file(, address(vow));
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
        gema.join(address(this), 1000 ether);

        vat.file(, , ray(1 ether));
        vat.file(, , rad(1000 ether));
        vat.file(,         rad(1000 ether));
        flip = new flipper(address(vat), );
        cat.file(, , address(flip));
        cat.file(, , ray(1 ether));

        vat.rely(address(flip));
        vat.rely(address(flap));
        vat.rely(address(flop));

        vat.hope(address(flip));
        vat.hope(address(flop));
        gold.approve(address(vat));
        gov.approve(address(flap));
    }

    function test_bite_under_lump() public {
        vat.file(, , ray(2.5 ether));
        vat.frob(,  40 ether, 100 ether);
        
        vat.file(, , ray(2 ether));  

        cat.file(, , 50 ether);
        cat.file(, , ray(1.1 ether));

        uint auction = cat.bite(, address(this));
        
        asserteq(ink(, address(this)), 0);
        asserteq(art(, address(this)), 0);
        
        asserteq(vow.awe(), rad(100 ether));
        
        fliplike.bid memory bid = fliplike(address(flip)).bids(auction);
        asserteq(bid.lot,        40 ether);
        asserteq(bid.tab,   rad(110 ether));
    }
    function test_bite_over_lump() public {
        vat.file(, , ray(2.5 ether));
        vat.frob(,  40 ether, 100 ether);
        
        vat.file(, , ray(2 ether));  

        cat.file(, , ray(1.1 ether));
        cat.file(, , 30 ether);

        uint auction = cat.bite(, address(this));
        
        asserteq(ink(, address(this)), 10 ether);
        asserteq(art(, address(this)), 25 ether);
        
        asserteq(vow.awe(), rad(75 ether));
        
        fliplike.bid memory bid = fliplike(address(flip)).bids(auction);
        asserteq(bid.lot,       30 ether);
        asserteq(bid.tab,   rad(82.5 ether));
    }

    function test_happy_bite() public {
        
        
        vat.file(, , ray(2.5 ether));
        vat.frob(,  40 ether, 100 ether);

        
        vat.file(, , ray(2 ether));  

        asserteq(ink(, address(this)),  40 ether);
        asserteq(art(, address(this)), 100 ether);
        asserteq(vow.woe(), 0 ether);
        asserteq(gem(, address(this)), 960 ether);

        cat.file(, , 100 ether);  
        uint auction = cat.bite(, address(this));
        asserteq(ink(, address(this)), 0);
        asserteq(art(, address(this)), 0);
        asserteq(vow.sin(now),   rad(100 ether));
        asserteq(gem(, address(this)), 960 ether);

        asserteq(vat.balanceof(address(vow)),    0 ether);
        flip.tend(auction, 40 ether,   rad(1 ether));
        flip.tend(auction, 40 ether, rad(100 ether));

        asserteq(vat.balanceof(address(this)),   0 ether);
        asserteq(gem(, address(this)),   960 ether);
        vat.mint(address(this), 100 ether);  
        flip.dent(auction, 38 ether,  rad(100 ether));
        asserteq(vat.balanceof(address(this)), 100 ether);
        asserteq(gem(, address(this)),   962 ether);
        asserteq(gem(, address(this)),   962 ether);
        asserteq(vow.sin(now),     rad(100 ether));

        hevm.warp(4 hours);
        flip.deal(auction);
        asserteq(vat.balanceof(address(vow)),  100 ether);
    }

    function test_floppy_bite() public {
        vat.file(, , ray(2.5 ether));
        vat.frob(,  40 ether, 100 ether);
        vat.file(, , ray(2 ether));  

        cat.file(, , 100 ether);  
        asserteq(vow.sin(now), rad(  0 ether));
        cat.bite(, address(this));
        asserteq(vow.sin(now), rad(100 ether));

        asserteq(vow.sin(), rad(100 ether));
        vow.flog(now);
        asserteq(vow.sin(), rad(  0 ether));
        asserteq(vow.woe(), rad(100 ether));
        asserteq(vow.joy(), rad(  0 ether));
        asserteq(vow.ash(), rad(  0 ether));

        vow.file(, rad(10 ether));
        uint f1 = vow.flop();
        asserteq(vow.woe(),  rad(90 ether));
        asserteq(vow.joy(),  rad( 0 ether));
        asserteq(vow.ash(),  rad(10 ether));
        flop.dent(f1, 1000 ether, rad(10 ether));
        asserteq(vow.woe(),  rad(90 ether));
        asserteq(vow.joy(),  rad(10 ether));
        asserteq(vow.ash(),  rad(10 ether));

        asserteq(gov.balanceof(address(this)),  100 ether);
        hevm.warp(4 hours);
        flop.deal(f1);
        asserteq(gov.balanceof(address(this)), 1100 ether);
    }

    function test_flappy_bite() public {
        
        vat.mint(address(vow), 100 ether);
        asserteq(vat.balanceof(address(vow)),  100 ether);
        asserteq(gov.balanceof(address(this)), 100 ether);

        vow.file(, rad(100 ether));
        asserteq(vow.awe(), 0 ether);
        uint id = vow.flap();

        asserteq(vat.balanceof(address(this)),   0 ether);
        asserteq(gov.balanceof(address(this)), 100 ether);
        flap.tend(id, rad(100 ether), 10 ether);
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
    function tab(bytes32 ilk, address urn) internal view returns (uint) {
        (uint ink_, uint art_) = vat.urns(ilk, urn); ink_;
        (uint art_, uint rate, uint spot, uint line, uint dust) = vat.ilks(ilk);
        art_; spot; line; dust;
        return art_ * rate;
    }
    function jam(bytes32 ilk, address urn) internal view returns (uint) {
        (uint ink_, uint art_) = vat.urns(ilk, urn); art_;
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
        address self = address(this);
        vat.slip(ilk, self,  10 ** 27 * 1 ether);
        vat.frob(ilk, self, self, self, int(1 ether), int(dai));
    }
    function test_fold() public {
        address self = address(this);
        address ali  = address(bytes20());
        draw(, 1 ether);

        asserteq(tab(, self), rad(1.00 ether));
        vat.fold(, ali,   int(ray(0.05 ether)));
        asserteq(tab(, self), rad(1.05 ether));
        asserteq(vat.dai(ali),      rad(0.05 ether));
    }
}
