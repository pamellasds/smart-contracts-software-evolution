pragma solidity ^0.4.8;

import ;
import ;
import ;
import ;
import ;

contract testtokenpresale {
  uint public initialbalance = 200 finney;

  ant token;

  throwproxy throwproxy;

  function beforeeach() {
    throwproxy = new throwproxy(address(this));
  }

  function deployandsetant(aragontokensale sale) {
    ant a = new ant(new minimetokenfactory());
    a.changecontroller(sale);
    sale.setant(a, new anplaceholder(address(sale), a));
  }

  function testcreatesale() {
    aragontokensalemock sale = new aragontokensalemock(10, 20, 0x1, 0x2, 3, 1, 2);

    assert.isfalse(sale.isactivated(), );
    assert.equal(sale.totalcollected(), 0, );
  }

  function testcantinitiateincorrectsale() {
    testtokenpresale(throwproxy).throwifstartpastblocktime();
    throwproxy.assertthrows();
  }

  function throwifstartpastblocktime() {
    new aragontokensalemock(0, 20, 0x1, 0x2, 3, 1, 2);
  }

  function testactivatesale() {
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(this), address(this), 3, 1, 2);
    deployandsetant(sale);
    sale.activatesale();
    assert.istrue(sale.isactivated(), );
  }

  function testcannotactivatebeforedeployingant() {
    testtokenpresale(throwproxy).throwswhenactivatingbeforedeployingant();
    throwproxy.assertthrows();
  }

  function throwswhenactivatingbeforedeployingant() {
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(this), address(this), 3, 1, 2);
    sale.activatesale();
  }

  function testcannotredeployant() {
    testtokenpresale(throwproxy).throwswhenredeployingant();
    throwproxy.assertthrows();
  }

  function throwswhenredeployingant() {
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(this), address(this), 3, 1, 2);
    deployandsetant(sale);
    deployandsetant(sale);
  }

  function testonlymultisigcandeployant() {
    testtokenpresale(throwproxy).throwswhennonmultisigdeploysant();
    throwproxy.assertthrows();
  }

  function throwswhennonmultisigdeploysant() {
    aragontokensalemock sale = new aragontokensalemock(10, 20, 0x1, 0x3, 3, 1, 2);
    deployandsetant(sale);
  }

  function testthrowsifplaceholderisbad() {
    testtokenpresale(throwproxy).throwswhennetworkplaceholderisbad();
    throwproxy.assertthrows();
  }

  function throwswhennetworkplaceholderisbad() {
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(this), address(this), 3, 1, 2);
    ant a = new ant(new minimetokenfactory());
    a.changecontroller(sale);
    sale.setant(a, new anplaceholder(address(sale), address(sale))); 
  }

  function testthrowsifsaleisnottokencontroller() {
    testtokenpresale(throwproxy).throwswhensaleisnottokencontroller();
    throwproxy.assertthrows();
  }

  function throwswhensaleisnottokencontroller() {
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(this), address(this), 3, 1, 2);
    ant a = new ant(new minimetokenfactory());
    
    sale.setant(a, new anplaceholder(address(sale), a)); 
  }

  function testsetpresaletokens() {
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(this), 0x2, 3, 1, 2);
    deployandsetant(sale);
    sale.allocatepresaletokens(0x1, 100 finney, uint64(now + 12 weeks), uint64(now + 24 weeks));
    sale.allocatepresaletokens(0x2, 30 finney, uint64(now + 12 weeks), uint64(now + 24 weeks));
    sale.allocatepresaletokens(address(this), 20 finney, uint64(now + 12 weeks), uint64(now + 24 weeks));
    assert.equal(erc20(sale.token()).balanceof(0x1), 100 finney, );
    assert.equal(irrevocablevestedtoken(sale.token()).transferabletokens(0x1, uint64(now)), 0, );
    assert.equal(irrevocablevestedtoken(sale.token()).transferabletokens(0x1, uint64(now + 12 weeks  1)), 0, );
    assert.equal(irrevocablevestedtoken(sale.token()).transferabletokens(0x1, uint64(now + 12 weeks)), 50 finney, );
    assert.equal(irrevocablevestedtoken(sale.token()).transferabletokens(0x1, uint64(now + 18 weeks)), 75 finney, );
    assert.equal(irrevocablevestedtoken(sale.token()).transferabletokens(0x1, uint64(now + 21 weeks)), 87500 szabo, );
    assert.equal(irrevocablevestedtoken(sale.token()).transferabletokens(0x1, uint64(now + 24 weeks)), 100 finney, );
    assert.equal(erc20(sale.token()).totalsupply(), 150 finney, );

    assert.equal(erc20(sale.token()).balanceof(this), 20 finney, );
    testtokenpresale(throwproxy).throwswhentransferingpresaletokensbeforecliff(sale.token());
    throwproxy.assertthrows();
  }

  function throwswhentransferingpresaletokensbeforecliff(address token) {
    erc20(token).transfer(0xdead, 1);
  }

  function testcannotsetpresaletokensafteractivation() {
    testtokenpresale(throwproxy).throwifsetpresaletokensafteractivation();
    throwproxy.assertthrows();
  }

  function throwifsetpresaletokensafteractivation() {
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(this), address(this), 3, 1, 2);
    deployandsetant(sale);
    sale.activatesale(); 
    sale.allocatepresaletokens(0x1, 100, uint64(now + 12 weeks), uint64(now + 24 weeks));
  }

  function testcannotsetpresaletokensaftersalestarts() {
    testtokenpresale(throwproxy).throwifsetpresaletokensaftersalestarts();
    throwproxy.assertthrows();
  }

  function throwifsetpresaletokensaftersalestarts() {
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(this), address(this), 3, 1, 2);
    deployandsetant(sale);
    sale.setmockedblocknumber(13);
    sale.allocatepresaletokens(0x1, 100, uint64(now + 12 weeks), uint64(now + 24 weeks));
  }
}
