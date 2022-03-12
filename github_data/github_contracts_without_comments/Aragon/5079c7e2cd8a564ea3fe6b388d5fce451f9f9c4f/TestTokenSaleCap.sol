pragma solidity ^0.4.8;

import ;
import ;
import ;
import ;
import ;
import ;

contract testtokensalecap {
  uint public initialbalance = 250 finney;

  address factory;

  throwproxy throwproxy;

  function beforeall() {
    factory = address(new minimetokenfactory());
  }

  function beforeeach() {
    throwproxy = new throwproxy(address(this));
  }

  function testcantfinalizenotendedsale() {
    testtokensalecap(throwproxy).throwswhenfinalizingnotendedsale();
    throwproxy.assertthrows();
  }

  function throwswhenfinalizingnotendedsale() {
    multisigmock ms = new multisigmock();
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(ms), address(ms), 3, 1, 2);
    ms.deployandsetant(sale);
    ms.activatesale(sale);
    sale.setmockedblocknumber(19);
    ms.finalizesale(sale);
  }

  function testcantfinalizeifnotmultisig() {
    testtokensalecap(throwproxy).throwswhenfinalizingifnotmultisig();
    throwproxy.assertthrows();
  }

  function throwswhenfinalizingifnotmultisig() {
    multisigmock ms = new multisigmock();
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(ms), address(ms), 3, 1, 2);
    ms.deployandsetant(sale);
    ms.activatesale(sale);
    sale.setmockedblocknumber(30);
    sale.finalizesale(1, 1);
  }

  function testcantfinalizewithincorrectcap() {
    testtokensalecap(throwproxy).throwswhenfinalizingwithincorrectcap();
    throwproxy.assertthrows();
  }

  function throwswhenfinalizingwithincorrectcap() {
    multisigmock ms = new multisigmock();
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(ms), address(ms), 5, 1, 2);
    ms.deployandsetant(sale);
    ms.activatesale(sale);
    sale.setmockedblocknumber(21);
    ms.finalizesale(sale, 101 finney); 
  }

  function testcanfinalizeoncap() {
    multisigmock ms = new multisigmock();
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(ms), address(ms), 5, 1, 2);
    ms.deployandsetant(sale);
    ms.activatesale(sale);
    sale.setmockedblocknumber(12);
    sale.proxypayment.value(100 finney)(address(this));

    sale.revealcap(100 finney, sale.mock_capsecret());

    assert.istrue(sale.salefinalized(), );
  }

  function testfinalizingbeforecapchangeshardcap() {
    multisigmock ms = new multisigmock();
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(ms), address(ms), 5, 1, 2);
    ms.deployandsetant(sale);
    ms.activatesale(sale);
    sale.setmockedblocknumber(12);
    sale.proxypayment.value(99 finney)(address(this));

    sale.revealcap(100 finney, sale.mock_capsecret());

    assert.equal(sale.hardcap(), 100 finney, );
  }

  function testhardcap() {
    testtokensalecap(throwproxy).throwswhenhittinghardcap();
    throwproxy.assertthrows();
  }

  function throwswhenhittinghardcap() {
    multisigmock ms = new multisigmock();
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(ms), address(ms), 5, 1, 2);
    ms.deployandsetant(sale);
    ms.activatesale(sale);
    sale.setmockedblocknumber(12);
    sale.setmockedtotalcollected(1499999 ether + 950 finney); 
    sale.proxypayment.value(60 finney)(address(this));
  }

  function testcanfinalizeendedsale() {
    multisigmock ms = new multisigmock();
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(ms), address(ms), 5, 1, 2);
    ms.deployandsetant(sale);
    ms.activatesale(sale);
    sale.setmockedblocknumber(12);
    sale.proxypayment.value(14 finney)(address(this));

    assert.equal(erc20(sale.token()).balanceof(address(this)), 70 finney, );
    assert.equal(erc20(sale.token()).totalsupply(), 70 finney, );

    sale.setmockedblocknumber(21);
    ms.finalizesale(sale);

    assert.equal(erc20(sale.token()).balanceof(address(ms)), 30 finney, );
    assert.equal(erc20(sale.token()).totalsupply(), 100 finney, );
  }

  function testtokensaretransferrableaftersale() {
    multisigmock ms = new multisigmock();
    aragontokensalemock sale = new aragontokensalemock(10, 20, address(ms), address(ms), 3, 1, 2);
    ms.deployandsetant(sale);
    ms.activatesale(sale);

    assert.equal(ant(sale.token()).controller(), address(sale), );

    sale.setmockedblocknumber(12);
    sale.proxypayment.value(15 finney)(address(this));
    sale.setmockedblocknumber(22);
    ms.finalizesale(sale);

    assert.equal(ant(sale.token()).controller(), sale.networkplaceholder(), );

    erc20(sale.token()).transfer(0x1, 10 finney);
    assert.equal(erc20(sale.token()).balanceof(0x1), 10 finney, );
  }

  function testfundsaretransferrableaftersale() {
    multisigmock ms = new multisigmock();
    aragontokensalemock sale = new aragontokensalemock(1000000, 60000000, address(ms), address(ms), 3, 1, 2);
    ms.deployandsetant(sale);
    ms.activatesale(sale);

    assert.equal(ant(sale.token()).controller(), address(sale), );

    sale.setmockedblocknumber(1000000);
    sale.proxypayment.value(15 finney)(address(this));
    sale.setmockedblocknumber(60000000);
    ms.finalizesale(sale);

    ms.withdrawwallet(sale);
    assert.equal(ms.balance, 15 finney, );
    assert.equal(sale.salewallet().balance, 0 finney, );
  }

  function testfundsarelockedduringsale() {
    multisigmock ms = new multisigmock();
    aragontokensalemock sale = new aragontokensalemock(1000000, 60000000, address(ms), address(ms), 3, 1, 2);
    ms.deployandsetant(sale);
    ms.activatesale(sale);

    assert.equal(ant(sale.token()).controller(), address(sale), );

    sale.setmockedblocknumber(1000000);
    sale.proxypayment.value(15 finney)(address(this));
    sale.setmockedblocknumber(60000000);

    ms.withdrawwallet(sale);
    assert.equal(ms.balance, 0 finney, );
    assert.equal(sale.salewallet().balance, 15 finney, );
  }
}
